import 'package:flutter/material.dart';

import '../core/api/api_exception.dart';
import '../data/models.dart';
import '../l10n/generated/app_localizations.dart';
import 'theme.dart';

/// Small labelled chip, outlined like the web "tag".
class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.strong = false, this.color});
  final String text;
  final bool strong;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color ?? (strong ? Palette.outline : Palette.hairline), width: 1.5),
        ),
        child: Text(text, style: TextStyle(fontSize: 14, fontWeight: strong ? FontWeight.w700 : FontWeight.w500, color: color ?? Palette.text)),
      );
}

Color urgencyColor(Urgency u) => switch (u) { Urgency.late => Palette.danger, Urgency.risk => Palette.risk, Urgency.ok => Palette.text };

/// "47 min left" / "2s 10d left" / "−14 min late": the unit is dropped when the label has its own.
String minutesKicker(AppLocalizations t, TaskSummary s) {
  final late = s.urgency == Urgency.late;
  if (s.minutesInHours) return late ? t.late : t.left;
  return late ? t.minLate : t.minLeft;
}

String errorText(AppLocalizations t, Object error) => error is ApiException && !error.isNetwork ? error.message : t.errorGeneric;

void showMessage(BuildContext context, String text, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), backgroundColor: error ? Palette.danger : Palette.night));
}

/// Full-width banner for "waiting to send" and similar states.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner(this.text, {super.key, this.icon = Icons.sync, this.color = Palette.risk});
  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(radiusPlate), border: Border.all(color: color, width: 1.5)),
        child: Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontSize: 14)))]),
      );
}

/// A sheet's title row with a close button.
class SheetHeader extends StatelessWidget {
  const SheetHeader(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, style: Typo.title)),
        IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close), tooltip: AppLocalizations.of(context).close),
      ]);
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator(color: Palette.action));
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(errorText(t, error), textAlign: TextAlign.center, style: Typo.body),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: Text(t.retry.toUpperCase())),
        ]),
      ),
    );
  }
}
