import 'dart:async';
import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_exception.dart';
import '../data/courier_repository.dart';
import '../data/models.dart';

/// Texts for the Android foreground-service notification, which must be visible while the
/// app tracks location in the background.
class TrackingNotice {
  const TrackingNotice(this.title, this.text);
  final String title;
  final String text;
}

/// GPS while the shift is open, also with the screen off or another app in front (Android
/// foreground service, iOS background location). Fixes are buffered on the phone and sent in
/// batches, so a dead network loses nothing; the server sorts them by `recorded_at`.
class LocationTracker {
  LocationTracker(this._repo, this._prefs, {Battery? battery}) : _battery = battery ?? Battery();

  static const _bufferKey = 'courier.gps_buffer';
  static const _maxBuffered = 2000; // ~8 h of fixes at 15 s

  final CourierRepository _repo;
  final SharedPreferences _prefs;
  final Battery _battery;

  StreamSubscription<Position>? _sub;
  Timer? _flushTimer;
  bool _onTask = false;
  AppSettings _settings = AppSettings.fallback();
  TrackingNotice _notice = const TrackingNotice('OmniDLV', '');
  int? _batteryLevel;
  DateTime? _batteryReadAt;
  bool _sending = false;

  bool get isRunning => _sub != null;
  int get buffered => _readBuffer().length;

  /// What the courier's permission state allows right now.
  static Future<LocationPermission> permission() => Geolocator.checkPermission();

  static Future<LocationPermission> requestPermission() => Geolocator.requestPermission();

  static Future<bool> serviceEnabled() => Geolocator.isLocationServiceEnabled();

  static Future<Position?> currentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)));
    } catch (_) {
      return Geolocator.getLastKnownPosition();
    }
  }

  Future<void> start({required AppSettings settings, required bool onTask, required TrackingNotice notice}) async {
    _settings = settings;
    _notice = notice;
    _onTask = onTask;
    await _subscribe();
    _flushTimer ??= Timer.periodic(Duration(seconds: settings.onTaskInterval), (_) => flush());
  }

  /// Faster updates while a task is on the road, slower while waiting for one.
  Future<void> setOnTask(bool onTask) async {
    if (onTask == _onTask || !isRunning) return;
    _onTask = onTask;
    await _subscribe();
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _flushTimer?.cancel();
    _flushTimer = null;
    await flush();
  }

  Future<void> _subscribe() async {
    await _sub?.cancel();
    final interval = Duration(seconds: _onTask ? _settings.onTaskInterval : _settings.idleInterval);
    final distance = _onTask ? _settings.onTaskDistance : _settings.idleDistance;

    _sub = Geolocator.getPositionStream(locationSettings: _platformSettings(interval, distance)).listen(
      _record,
      onError: (Object e) => debugPrint('GPS error: $e'),
    );
  }

  LocationSettings _platformSettings(Duration interval, int distance) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distance,
        intervalDuration: interval,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: _notice.title,
          notificationText: _notice.text,
          notificationChannelName: _notice.title,
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distance,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    }
    return LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: distance);
  }

  Future<void> _record(Position p) async {
    final buffer = _readBuffer()
      ..add({
        'lat': double.parse(p.latitude.toStringAsFixed(6)),
        'lng': double.parse(p.longitude.toStringAsFixed(6)),
        'recorded_at': p.timestamp.toUtc().toIso8601String(),
        'accuracy': p.accuracy.round(),
        'speed': p.speed < 0 ? -1 : double.parse(p.speed.toStringAsFixed(2)),
        'heading': p.heading < 0 ? -1 : p.heading.round(),
        'battery': await _batteryPercent(),
        'is_mock': p.isMocked,
      });
    _writeBuffer(buffer.length > _maxBuffered ? buffer.sublist(buffer.length - _maxBuffered) : buffer);

    if (buffer.length >= _settings.batchSize) unawaited(flush());
  }

  /// Sends buffered fixes, oldest first, in batches. Stops quietly when offline.
  Future<void> flush() async {
    if (_sending) return;
    _sending = true;
    try {
      while (true) {
        final buffer = _readBuffer();
        if (buffer.isEmpty) break;
        final batch = buffer.take(_settings.batchSize).toList();
        try {
          await _repo.sendLocations(batch);
        } on ApiException catch (e) {
          if (e.isNetwork || (e.status ?? 500) >= 500) break; // try again later
          // 4xx: these fixes will never be accepted; drop them rather than block the queue.
        }
        _writeBuffer(_readBuffer().skip(batch.length).toList());
      }
    } finally {
      _sending = false;
    }
  }

  Future<int?> _batteryPercent() async {
    final now = DateTime.now();
    if (_batteryReadAt == null || now.difference(_batteryReadAt!) > const Duration(minutes: 2)) {
      try {
        _batteryLevel = await _battery.batteryLevel;
      } catch (_) {
        _batteryLevel = null;
      }
      _batteryReadAt = now;
    }
    return _batteryLevel;
  }

  List<Map<String, dynamic>> _readBuffer() {
    final raw = _prefs.getString(_bufferKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    } catch (_) {
      return [];
    }
  }

  void _writeBuffer(List<Map<String, dynamic>> items) => _prefs.setString(_bufferKey, jsonEncode(items));
}
