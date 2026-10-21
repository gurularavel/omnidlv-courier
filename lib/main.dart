import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);

  // Network back: replay actions and GPS fixes saved while offline.
  Connectivity().onConnectivityChanged.listen((results) {
    if (results.any((r) => r != ConnectivityResult.none)) {
      container.read(actionQueueProvider).flush();
      container.read(locationTrackerProvider).flush();
    }
  });

  runApp(UncontrolledProviderScope(container: container, child: const CourierApp()));
}
