import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';

import '../data/models.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/nav_launcher.dart';
import '../state/providers.dart';
import 'theme.dart';
import 'widgets.dart';

EdgeInsets _sheetPadding(BuildContext context) => EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom);

/// Option rows with a radio, sized for a thumb.
class _Choice<T> extends StatelessWidget {
  const _Choice({required this.value, required this.group, required this.label, required this.onChanged});
  final T value;
  final T group;
  final String label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == group;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(radiusPlate),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusPlate),
            border: Border.all(color: selected ? Palette.outline : Palette.hairline, width: 1.5),
          ),
          child: Row(children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? Palette.night : Palette.text3),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: Typo.body)),
          ]),
        ),
      ),
    );
  }
}

/// "How was it handed over?" Returns (status, receivedBy) or null.
class HandoverSheet extends StatefulWidget {
  const HandoverSheet({super.key});

  @override
  State<HandoverSheet> createState() => _HandoverSheetState();
}

class _HandoverSheetState extends State<HandoverSheet> {
  String _status = 'delivered';
  final _receivedBy = TextEditingController();

  @override
  void dispose() {
    _receivedBy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final options = {'delivered': t.handedToRecipient, 'left_at_door': t.leftAtDoor, 'delivered_to_other': t.handedToOther};
    return SingleChildScrollView(
      padding: _sheetPadding(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        SheetHeader(t.handoverTitle),
        const SizedBox(height: 12),
        for (final e in options.entries) _Choice(value: e.key, group: _status, label: e.value, onChanged: (v) => setState(() => _status = v)),
        if (_status == 'delivered_to_other')
          TextField(controller: _receivedBy, decoration: InputDecoration(hintText: t.whoReceived), textCapitalization: TextCapitalization.words),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((status: _status, receivedBy: _status == 'delivered_to_other' ? _receivedBy.text.trim() : null)),
          child: Text(t.confirmHandover.toUpperCase()),
        ),
      ]),
    );
  }
}

/// "Why not?" Returns (status, notes) or null.
class FailSheet extends StatefulWidget {
  const FailSheet({super.key});

  @override
  State<FailSheet> createState() => _FailSheetState();
}

class _FailSheetState extends State<FailSheet> {
  String? _status;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final options = {
      'recipient_not_available': t.failNotAvailable,
      'wrong_address': t.failWrongAddress,
      'refused': t.failRefused,
      'damaged': t.failDamaged,
      'failed': t.failOther,
    };
    return SingleChildScrollView(
      padding: _sheetPadding(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        SheetHeader(t.failTitle),
        const SizedBox(height: 12),
        for (final e in options.entries) _Choice<String?>(value: e.key, group: _status, label: e.value, onChanged: (v) => setState(() => _status = v)),
        TextField(controller: _notes, maxLength: 255, maxLines: 2, decoration: InputDecoration(labelText: t.notes)),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _status == null ? null : () => Navigator.of(context).pop((status: _status!, notes: _notes.text.trim().isEmpty ? null : _notes.text.trim())),
          child: Text(t.confirmFail.toUpperCase()),
        ),
      ]),
    );
  }
}

/// Google Maps or Waze, optionally remembered.
class NavChoiceSheet extends StatefulWidget {
  const NavChoiceSheet({super.key});

  @override
  State<NavChoiceSheet> createState() => _NavChoiceSheetState();
}

class _NavChoiceSheetState extends State<NavChoiceSheet> {
  bool _remember = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    void pick(NavApp app) => Navigator.of(context).pop((app: app, remember: _remember));
    return Padding(
      padding: _sheetPadding(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        SheetHeader(t.openDirectionsIn),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => pick(NavApp.google), child: const Text('GOOGLE MAPS'))),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton(onPressed: () => pick(NavApp.waze), child: const Text('WAZE'))),
        ]),
        CheckboxListTile(
          value: _remember,
          onChanged: (v) => setState(() => _remember = v ?? false),
          title: Text(t.alwaysUseApp),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: Palette.action,
        ),
        Text(t.changeLater, style: const TextStyle(fontSize: 14, color: Palette.text3)),
      ]),
    );
  }
}

/// Recipient signs on the screen; returns PNG bytes.
class SignatureSheet extends StatefulWidget {
  const SignatureSheet({super.key});

  @override
  State<SignatureSheet> createState() => _SignatureSheetState();
}

class _SignatureSheetState extends State<SignatureSheet> {
  final _controller = SignatureController(penStrokeWidth: 3, penColor: Palette.night, exportBackgroundColor: Colors.white);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: _sheetPadding(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        SheetHeader(t.signature),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Palette.outline, width: 1.5), borderRadius: BorderRadius.circular(radiusPlate)),
          clipBehavior: Clip.antiAlias,
          child: Signature(controller: _controller, height: 220, backgroundColor: Colors.white),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: _controller.clear, child: Text(t.clear.toUpperCase()))),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () async {
                if (_controller.isEmpty) return;
                final Uint8List? png = await _controller.toPngBytes();
                if (context.mounted) Navigator.of(context).pop(png);
              },
              child: Text(t.save.toUpperCase()),
            ),
          ),
        ]),
      ]),
    );
  }
}

/// "My day": active, pool and finished stops. Taking from the pool happens here.
class MyDaySheet extends ConsumerStatefulWidget {
  const MyDaySheet({super.key, required this.onOpen, required this.onTake});
  final void Function(TaskSummary task) onOpen;
  final Future<void> Function(TaskSummary task) onTake;

  @override
  ConsumerState<MyDaySheet> createState() => _MyDaySheetState();
}

class _MyDaySheetState extends ConsumerState<MyDaySheet> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final board = ref.watch(boardProvider).value;
    if (board == null) return const SizedBox(height: 200, child: LoadingView());

    final lists = [board.active, board.pool, board.done];
    final items = lists[_tab];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Text(t.myDay, style: Typo.title),
            const Spacer(),
            Text(t.deliveredCount(board.delivered), style: const TextStyle(color: Palette.text2)),
          ]),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 0, label: Text('${t.tabActive} ${board.active.length}')),
              ButtonSegment(value: 1, label: Text('${t.tabPool} ${board.pool.length}')),
              ButtonSegment(value: 2, label: Text('${t.tabDone} ${board.done.length}')),
            ],
            selected: {_tab},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _tab = s.first),
          ),
        ),
        if (board.cash > 0 && _tab == 0)
          Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Tag(t.cashToCollect(board.cash.toStringAsFixed(2)), strong: true)),
        const SizedBox(height: 8),
        Expanded(
          child: items.isEmpty
              ? Center(child: Text(t.emptyList, style: const TextStyle(color: Palette.text3)))
              : ListView.separated(
                  controller: scroll,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, i) {
                    final s = items[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      onTap: _tab == 1 ? null : () => widget.onOpen(s),
                      leading: SizedBox(
                        width: 64,
                        child: Text(s.minutesLabel, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _tab == 2 ? Palette.text3 : urgencyColor(s.urgency))),
                      ),
                      title: Text(s.address ?? '—', maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${s.code} · ${s.status}', style: Typo.code),
                      trailing: _tab == 1 ? FilledButton(style: FilledButton.styleFrom(minimumSize: const Size(80, 44)), onPressed: () => widget.onTake(s), child: Text(t.take.toUpperCase())) : null,
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

/// Menu: shift, language, directions app, account.
class MenuSheet extends ConsumerWidget {
  const MenuSheet({super.key, required this.onEndShift, required this.onDeleteAccount});
  final Future<void> Function() onEndShift;
  final Future<void> Function() onDeleteAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final board = ref.watch(boardProvider).value;
    final locale = ref.watch(localeProvider).languageCode;
    final launcher = ref.watch(navLauncherProvider);
    final version = ref.watch(packageInfoProvider).value?.version ?? '';

    return SingleChildScrollView(
      padding: _sheetPadding(context),
      child: StatefulBuilder(
        builder: (context, setState) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          if (board != null) ...[
            Text(board.courier.name, style: Typo.title),
            if (board.company != null) Text(board.company!, style: const TextStyle(color: Palette.text2)),
            const SizedBox(height: 16),
            if (board.shiftActive) OutlinedButton(onPressed: onEndShift, child: Text(t.endShift.toUpperCase())),
          ],
          const SizedBox(height: 16),
          Text(t.language.toUpperCase(), style: Typo.label),
          const SizedBox(height: 8),
          Row(children: [
            for (final code in const ['az', 'en', 'ru', 'tr'])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), side: BorderSide(color: code == locale ? Palette.outline : Palette.hairline, width: 1.5)),
                    onPressed: () => ref.read(localeProvider.notifier).set(code),
                    child: Text(code.toUpperCase()),
                  ),
                ),
              ),
          ]),
          if (launcher.saved != null) ...[
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.navigation_outlined, size: 18, color: Palette.text2),
              const SizedBox(width: 8),
              Expanded(child: Text('${t.directions}: ${launcher.saved == NavApp.waze ? 'Waze' : 'Google Maps'}')),
              TextButton(
                onPressed: () async {
                  await launcher.remember(null);
                  setState(() {});
                },
                child: Text(t.askEveryTime),
              ),
            ]),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: Text(t.signOut.toUpperCase()),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Palette.hairline, width: 1.5)),
          ),
          TextButton(onPressed: onDeleteAccount, child: Text(t.deleteAccount, style: const TextStyle(color: Palette.danger, fontSize: 14))),
          if (version.isNotEmpty) Center(child: Text(t.version(version), style: const TextStyle(fontSize: 12, color: Palette.text3))),
        ]),
      ),
    );
  }
}
