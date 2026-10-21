import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/config.dart';
import 'l10n/generated/app_localizations.dart';
import 'services/location_tracker.dart';
import 'state/providers.dart';
import 'ui/auth/login_screens.dart';
import 'ui/home/home_screen.dart';
import 'ui/permission_screen.dart';
import 'ui/scan_screen.dart';
import 'ui/task/task_screen.dart';
import 'ui/theme.dart';
import 'ui/update_screen.dart';
import 'ui/widgets.dart';

/// Re-runs the router's redirect whenever the session or the update check changes.
class _RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(sessionProvider, (_, _) => refresh.ping());
  ref.listen(updateRequiredProvider, (_, _) => refresh.ping());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final path = state.matchedLocation;

      if (ref.read(updateRequiredProvider).value == true) return path == '/update' ? null : '/update';
      if (!session.ready) return path == '/' ? null : '/';

      final inLogin = path.startsWith('/login');
      if (!session.signedIn) return inLogin ? null : '/login';
      if (inLogin || path == '/' || path == '/update') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: LoadingView())),
      GoRoute(path: '/update', builder: (_, _) => const UpdateScreen()),
      GoRoute(path: '/login', builder: (_, _) => const PhoneScreen()),
      GoRoute(
        path: '/login/code',
        builder: (_, state) {
          final extra = state.extra is ({String phone, String? demoCode}) ? state.extra! as ({String phone, String? demoCode}) : (phone: '', demoCode: null);
          return CodeScreen(phone: extra.phone, demoCode: extra.demoCode);
        },
      ),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/task/:id',
        builder: (_, state) => TaskScreen(
          taskId: int.parse(state.pathParameters['id']!),
          openHandover: state.uri.queryParameters['handover'] == '1',
        ),
      ),
      GoRoute(path: '/scan', builder: (_, _) => const ScanScreen()),
      GoRoute(path: '/permissions', builder: (_, _) => const PermissionScreen()),
    ],
  );
});

class CourierApp extends ConsumerWidget {
  const CourierApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: locale,
      supportedLocales: AppConfig.supportedLocales.map(Locale.new),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        // The Android tracking notification speaks the courier's language.
        final t = AppLocalizations.of(context);
        WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(trackingNoticeProvider.notifier).update(TrackingNotice(t.trackingTitle, t.trackingText)));
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
