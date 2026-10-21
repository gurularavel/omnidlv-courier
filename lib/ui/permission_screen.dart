import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/generated/app_localizations.dart';
import 'theme.dart';

/// Prominent disclosure before any location prompt (Google Play requires it for background
/// location), then the system prompts: location, "all the time", notifications, battery.
/// Pops true when the shift may start.
class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _busy = false;
  bool _denied = false;

  Future<void> _continue() async {
    setState(() => _busy = true);
    try {
      final whileInUse = await Permission.locationWhenInUse.request();
      if (!whileInUse.isGranted) {
        setState(() => _denied = true);
        return;
      }

      // Android 11+ and iOS only offer "all the time" as a second step.
      await Permission.locationAlways.request();

      if (Platform.isAndroid) {
        // Android 13+: the tracking notification needs this; without it tracking still works.
        await Permission.notification.request();
        if (!await Permission.ignoreBatteryOptimizations.isGranted && mounted) {
          await _batteryHint();
        }
      }

      if (mounted) context.pop(true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _batteryHint() async {
    final t = AppLocalizations.of(context);
    final go = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(t.batteryTitle),
        content: Text(t.batteryBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.notNow)),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(t.allow)),
        ],
      ),
    );
    if (go == true) await Permission.ignoreBatteryOptimizations.request();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          const Icon(Icons.location_on_outlined, size: 48, color: Palette.action),
          const SizedBox(height: 16),
          Text(t.permissionTitle, style: Typo.display),
          const SizedBox(height: 12),
          Text(t.permissionBody, style: Typo.body),
          const SizedBox(height: 12),
          Text(t.permissionBackground, style: const TextStyle(color: Palette.text2)),
          if (_denied) ...[
            const SizedBox(height: 16),
            Text(t.locationDenied, style: const TextStyle(color: Palette.danger)),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: openAppSettings, child: Text(t.openSettings.toUpperCase())),
          ],
          const SizedBox(height: 24),
          FilledButton(onPressed: _busy ? null : _continue, child: Text(t.allow.toUpperCase())),
          TextButton(onPressed: () => context.pop(false), child: Text(t.notNow)),
        ]),
      ),
    );
  }
}
