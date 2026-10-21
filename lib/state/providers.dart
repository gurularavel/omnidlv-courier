import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' show LocationPermission;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/config.dart';
import '../core/offline/action_queue.dart';
import '../core/storage/token_store.dart';
import '../data/courier_repository.dart';
import '../data/models.dart';
import '../services/location_tracker.dart';
import '../services/nav_launcher.dart';

/// Overridden in main() with the instance loaded before the app starts.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('override in main'));

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(ref.watch(tokenStoreProvider));
  client.locale = ref.watch(localeProvider).languageCode;
  return client;
});

final actionQueueProvider = Provider<ActionQueue>((ref) => ActionQueue(ref.watch(apiClientProvider), ref.watch(sharedPrefsProvider)));

final repositoryProvider = Provider<CourierRepository>((ref) => CourierRepository(ref.watch(apiClientProvider), ref.watch(actionQueueProvider)));

final navLauncherProvider = Provider<NavLauncher>((ref) => NavLauncher(ref.watch(sharedPrefsProvider)));

final locationTrackerProvider = Provider<LocationTracker>((ref) {
  final tracker = LocationTracker(ref.watch(repositoryProvider), ref.watch(sharedPrefsProvider));
  ref.onDispose(tracker.stop);
  return tracker;
});

/// Authorization header for images the server serves only to signed-in users (proof photos).
final authHeadersProvider = FutureProvider<Map<String, String>>((ref) async {
  final token = await ref.watch(tokenStoreProvider).read();
  return token == null ? const {} : {'Authorization': 'Bearer $token'};
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

/// Server-side app settings; falls back to defaults when the server cannot be reached.
final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  try {
    return await ref.watch(repositoryProvider).appConfig();
  } catch (_) {
    return AppSettings.fallback();
  }
});

/// True when this build is older than the server's minimum.
final updateRequiredProvider = FutureProvider<bool>((ref) async {
  final settings = await ref.watch(appSettingsProvider.future);
  final info = await ref.watch(packageInfoProvider.future);
  return compareVersions(info.version, settings.minVersion) < 0;
});

int compareVersions(String a, String b) {
  List<int> parts(String v) => v.split('+').first.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  final pa = parts(a), pb = parts(b);
  for (var i = 0; i < 3; i++) {
    final x = i < pa.length ? pa[i] : 0, y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}

// ---------------------------------------------------------------------------------------------
// Language

class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'courier.locale';

  @override
  Locale build() {
    final saved = ref.watch(sharedPrefsProvider).getString(_key);
    if (saved != null && AppConfig.supportedLocales.contains(saved)) return Locale(saved);
    final device = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return Locale(AppConfig.supportedLocales.contains(device) ? device : 'az');
  }

  Future<void> set(String code) async {
    await ref.read(sharedPrefsProvider).setString(_key, code);
    state = Locale(code);
    if (ref.read(sessionProvider).signedIn) {
      unawaited(ref.read(repositoryProvider).setLocale(code).catchError((_) {}));
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

// ---------------------------------------------------------------------------------------------
// Session

class Session {
  const Session({required this.ready, required this.signedIn, this.courier});
  final bool ready;
  final bool signedIn;
  final Courier? courier;
}

class SessionNotifier extends Notifier<Session> {
  @override
  Session build() {
    ref.read(apiClientProvider).onUnauthenticated = () => unawaited(signOut(local: true));
    unawaited(_restore());
    return const Session(ready: false, signedIn: false);
  }

  Future<void> _restore() async {
    final token = await ref.read(tokenStoreProvider).read();
    state = Session(ready: true, signedIn: token != null);
    if (token != null) unawaited(registerDevice());
  }

  Future<String?> requestCode(String phone) => ref.read(repositoryProvider).requestCode(phone);

  Future<void> verify(String phone, String code) async {
    final device = await _deviceName();
    final result = await ref.read(repositoryProvider).verify(phone, code, device);
    await ref.read(tokenStoreProvider).write(result.token);
    state = Session(ready: true, signedIn: true, courier: result.courier);
    unawaited(registerDevice());
  }

  /// Tells the server which phone and app version this is (and, later, the FCM push token).
  Future<void> registerDevice({String? pushToken}) async {
    try {
      final info = await ref.read(packageInfoProvider.future);
      await ref.read(repositoryProvider).registerDevice({
        'platform': Platform.isIOS ? 'ios' : 'android',
        'push_token': ?pushToken,
        'app_version': info.version,
        'os_version': Platform.operatingSystemVersion,
        'model': await _deviceName(),
        'locale': ref.read(localeProvider).languageCode,
      });
    } catch (_) {
      // Not critical: retried at next start.
    }
  }

  Future<void> signOut({bool local = false}) async {
    await ref.read(locationTrackerProvider).stop();
    if (!local) {
      try {
        await ref.read(repositoryProvider).logout();
      } on ApiException catch (_) {}
    }
    await ref.read(tokenStoreProvider).clear();
    state = const Session(ready: true, signedIn: false);
  }

  Future<String> _deviceName() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        return '${a.manufacturer} ${a.model}';
      }
      if (Platform.isIOS) {
        final i = await info.iosInfo;
        return i.utsname.machine;
      }
    } catch (_) {}
    return 'phone';
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, Session>(SessionNotifier.new);

// ---------------------------------------------------------------------------------------------
// Work

/// The home screen. Refreshes every 30 s and whenever an action changes something.
class BoardNotifier extends AsyncNotifier<Board> {
  Timer? _timer;

  @override
  Future<Board> build() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
    ref.onDispose(() => _timer?.cancel());

    final board = await ref.read(repositoryProvider).board();
    unawaited(_syncTracking(board));
    return board;
  }

  Future<void> refresh() async {
    unawaited(ref.read(actionQueueProvider).flush());
    try {
      final board = await ref.read(repositoryProvider).board();
      if (!ref.mounted) return;
      state = AsyncData(board);
      unawaited(_syncTracking(board));
    } catch (e, st) {
      if (!ref.mounted) return;
      // Keep showing the last board when a refresh fails; only the first load shows an error.
      if (state.value == null) state = AsyncError(e, st);
    }
  }

  void replace(Board board) {
    state = AsyncData(board);
    unawaited(_syncTracking(board));
  }

  /// GPS runs exactly while the shift is open.
  Future<void> _syncTracking(Board board) async {
    final tracker = ref.read(locationTrackerProvider);
    final onTask = board.active.any((t) => t.category == 'on_delivery' || t.category == 'in_progress');

    if (!board.shiftActive) {
      if (tracker.isRunning) await tracker.stop();
      return;
    }

    final permission = await LocationTracker.permission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    if (tracker.isRunning) {
      await tracker.setOnTask(onTask);
    } else {
      final settings = await ref.read(appSettingsProvider.future);
      await tracker.start(settings: settings, onTask: onTask, notice: ref.read(trackingNoticeProvider));
    }
  }
}

final boardProvider = AsyncNotifierProvider<BoardNotifier, Board>(BoardNotifier.new);

/// Texts of the Android tracking notification, set by the app shell from the current translations.
class TrackingNoticeNotifier extends Notifier<TrackingNotice> {
  @override
  TrackingNotice build() => const TrackingNotice('OmniDLV', '');

  void update(TrackingNotice notice) => state = notice;
}

final trackingNoticeProvider = NotifierProvider<TrackingNoticeNotifier, TrackingNotice>(TrackingNoticeNotifier.new);

class TaskNotifier extends AsyncNotifier<TaskDetail> {
  TaskNotifier(this.id);
  final int id;

  @override
  Future<TaskDetail> build() => ref.read(repositoryProvider).task(id);

  void replace(TaskDetail task) => state = AsyncData(task);

  Future<void> reload() async {
    try {
      final task = await ref.read(repositoryProvider).task(id);
      if (ref.mounted) state = AsyncData(task);
    } catch (_) {}
  }
}

final taskProvider = AsyncNotifierProvider.family<TaskNotifier, TaskDetail, int>(TaskNotifier.new);
