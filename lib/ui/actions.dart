import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../core/api/api_exception.dart';
import '../core/offline/action_queue.dart';
import '../data/models.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/nav_launcher.dart';
import '../state/providers.dart';
import 'sheets.dart';
import 'widgets.dart';

/// Where the phone is now, for the status log; empty when unknown (never blocks the action).
Future<Map<String, dynamic>> currentPoint() async {
  try {
    final p = await Geolocator.getLastKnownPosition();
    return p == null ? {} : {'lat': p.latitude, 'lng': p.longitude};
  } catch (_) {
    return {};
  }
}

/// Runs a courier action and tells the courier what happened: done, saved offline, or refused.
/// Returns the updated task when the server answered with one.
Future<TaskDetail?> runTaskAction(BuildContext context, WidgetRef ref, Future<ActResult> Function(Map<String, dynamic> point) action) async {
  final t = AppLocalizations.of(context);
  try {
    final result = await action(await currentPoint());
    if (!context.mounted) return null;

    if (result.queued) {
      showMessage(context, t.queuedAction);
      return null;
    }

    final data = result.data;
    final task = data != null && data['id'] != null ? TaskDetail.fromJson(data) : null;
    if (task != null) ref.read(taskProvider(task.id).notifier).replace(task);
    await ref.read(boardProvider.notifier).refresh();
    return task;
  } on ApiException catch (e) {
    if (context.mounted) showMessage(context, errorText(t, e), error: true);
    return null;
  }
}

/// Opens directions in the saved app, or asks which one.
Future<void> openDirections(BuildContext context, WidgetRef ref, TaskDetail task) async {
  final launcher = ref.read(navLauncherProvider);
  final saved = launcher.saved;
  if (saved != null) {
    await launcher.open(saved, googleUrl: task.googleUrl, wazeUrl: task.wazeUrl);
    return;
  }

  final choice = await showModalBottomSheet<({NavApp app, bool remember})>(context: context, builder: (_) => const NavChoiceSheet());
  if (choice == null) return;
  if (choice.remember) await launcher.remember(choice.app);
  await launcher.open(choice.app, googleUrl: task.googleUrl, wazeUrl: task.wazeUrl);
}
