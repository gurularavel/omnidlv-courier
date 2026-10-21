
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_exception.dart';
import '../../data/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/nav_launcher.dart';
import '../../state/providers.dart';
import '../actions.dart';
import '../sheets.dart';
import '../theme.dart';
import '../widgets.dart';

/// One task: details, forward steps, proof of delivery, handover or failure.
class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key, required this.taskId, this.openHandover = false});
  final int taskId;

  /// Arrived from "Hand over" on the home screen: open the confirmation straight away.
  final bool openHandover;

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  bool _busy = false;
  bool _handoverOffered = false;
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _guard(Future<void> Function() body) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await body();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _primary(TaskDetail task) async {
    if (task.next == 'complete') return _handover(task);
    await _guard(() async {
      final repo = ref.read(repositoryProvider);
      await runTaskAction(context, ref, (point) => task.next == 'claim' ? repo.claim(task.id) : repo.step(task.id, task.next!, point: point));
    });
  }

  Future<void> _handover(TaskDetail task) async {
    final t = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<({String status, String? receivedBy})>(context: context, isScrollControlled: true, builder: (_) => const HandoverSheet());
    if (choice == null || !mounted) return;

    await _guard(() async {
      final repo = ref.read(repositoryProvider);
      final done = await runTaskAction(context, ref, (point) => repo.complete(task.id, choice.status, receivedBy: choice.receivedBy, point: point));
      if (done != null && done.finalState && mounted) {
        showMessage(context, t.handedOver);
        context.go('/home');
      }
    });
  }

  Future<void> _fail(TaskDetail task) async {
    final choice = await showModalBottomSheet<({String status, String? notes})>(context: context, isScrollControlled: true, builder: (_) => const FailSheet());
    if (choice == null || !mounted) return;
    await _guard(() async {
      final repo = ref.read(repositoryProvider);
      final done = await runTaskAction(context, ref, (point) => repo.fail(task.id, choice.status, notes: choice.notes, point: point));
      if (done != null && done.finalState && mounted) context.go('/home');
    });
  }

  Future<void> _upload(TaskDetail task, String type, Uint8List bytes, String filename) => _guard(() async {
        final t = AppLocalizations.of(context);
        try {
          final updated = await ref.read(repositoryProvider).uploadPod(task.id, type, bytes, filename);
          ref.read(taskProvider(task.id).notifier).replace(updated);
        } on ApiException catch (e) {
          if (mounted) showMessage(context, errorText(t, e), error: true);
        }
      });

  Future<void> _photo(TaskDetail task) async {
    // The picker scales and compresses on the device before anything is uploaded.
    final file = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1600, maxHeight: 1600, imageQuality: 70);
    if (file == null) return;
    await _upload(task, 'photo', await file.readAsBytes(), 'photo.jpg');
  }

  Future<void> _signature(TaskDetail task) async {
    final png = await showModalBottomSheet<Uint8List?>(context: context, isScrollControlled: true, builder: (_) => const SignatureSheet());
    if (png != null) await _upload(task, 'signature', png, 'signature.png');
  }

  Future<void> _verifyCode(TaskDetail task) => _guard(() async {
        final t = AppLocalizations.of(context);
        try {
          final res = await ref.read(repositoryProvider).verifyCode(task.id, _code.text.trim());
          ref.read(taskProvider(task.id).notifier).replace(res.task);
          _code.clear();
          if (mounted) showMessage(context, res.verified ? t.codeOk : (res.message ?? t.errorGeneric), error: !res.verified);
        } on ApiException catch (e) {
          if (mounted) showMessage(context, errorText(t, e), error: true);
        }
      });

  Future<void> _scan(TaskDetail task) async {
    final t = AppLocalizations.of(context);
    final code = await context.push<String>('/scan');
    if (code == null || !mounted) return;
    await _guard(() async {
      try {
        final res = await ref.read(repositoryProvider).scan(task.id, code);
        if (res.task != null) ref.read(taskProvider(task.id).notifier).replace(res.task!);
        if (mounted) showMessage(context, res.matched ? t.scanned : t.notInOrder, error: !res.matched);
      } on ApiException catch (e) {
        if (mounted) showMessage(context, errorText(t, e), error: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final state = ref.watch(taskProvider(widget.taskId));

    // Offer the handover once, as soon as the task is loaded and ready for it.
    final loaded = state.value;
    if (widget.openHandover && !_handoverOffered && loaded != null) {
      _handoverOffered = true;
      if (loaded.next == 'complete' && loaded.canComplete) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _handover(loaded));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: state.value == null
            ? null
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(state.value!.code, style: Typo.code.copyWith(color: Palette.text)),
                Text(state.value!.status, style: const TextStyle(fontSize: 13, color: Palette.text2)),
              ]),
        shape: const Border(bottom: BorderSide(color: Palette.outline, width: 1.5)),
      ),
      body: state.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(taskProvider(widget.taskId))),
        data: (task) => RefreshIndicator(
          color: Palette.action,
          onRefresh: () => ref.read(taskProvider(widget.taskId).notifier).reload(),
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), children: _details(context, t, task)),
        ),
      ),
      bottomNavigationBar: state.value == null || state.value!.finalState ? null : _actions(t, state.value!),
    );
  }

  List<Widget> _details(BuildContext context, AppLocalizations t, TaskDetail task) {
    final place = [task.target.building, task.target.floor, task.target.apartment].whereType<String>().join(' · ');
    return [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(task.minutesLabel, style: Typo.display.copyWith(color: task.finalState ? Palette.text3 : urgencyColor(task.urgency))),
        const SizedBox(width: 8),
        if (!task.finalState) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(minutesKicker(t, task).toUpperCase(), style: Typo.label)),
        const Spacer(),
        Text(task.window, style: const TextStyle(color: Palette.text2)),
      ]),
      const SizedBox(height: 16),
      Text((task.target.address ?? '—').toUpperCase(), style: Typo.display),
      const SizedBox(height: 8),
      Text.rich(TextSpan(children: [
        TextSpan(text: task.target.name ?? '—'),
        if (task.phoneDisplay != null) TextSpan(text: ' · ${task.phoneDisplay}', style: const TextStyle(color: Palette.text2)),
      ])),
      if (place.isNotEmpty) Text(place, style: const TextStyle(color: Palette.text2)),
      if (task.target.description != null)
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Palette.surfaceHover, borderRadius: BorderRadius.circular(8)),
          child: Text(task.target.description!, style: const TextStyle(color: Palette.text2)),
        ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: task.phone == null ? null : () => NavLauncher.call(task.phone!), icon: const Icon(Icons.phone_outlined), label: Text(t.call.toUpperCase()))),
        const SizedBox(width: 12),
        Expanded(child: OutlinedButton.icon(onPressed: task.canNavigate ? () => openDirections(context, ref, task) : null, icon: const Icon(Icons.navigation_outlined), label: Text(t.navigate.toUpperCase()))),
      ]),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        if (task.cash != null) Tag(t.collect('${task.cash!.toStringAsFixed(2)} ${task.currency ?? ''}'), strong: true),
        if (task.requirements.dontRing) Tag(t.dontRing),
        if (task.requirements.contactless) Tag(t.contactless),
      ]),
      if (task.notes != null || task.recipientNotes != null) ...[
        const SizedBox(height: 12),
        for (final note in [task.notes, task.recipientNotes].whereType<String>()) Text(note, style: const TextStyle(color: Palette.text2)),
      ],
      if (task.items.isNotEmpty) ...[
        const SizedBox(height: 24),
        Row(children: [
          Text(t.items.toUpperCase(), style: Typo.label),
          const Spacer(),
          if (task.items.any((i) => i.barcode != null) && !task.finalState)
            TextButton.icon(onPressed: _busy ? null : () => _scan(task), icon: const Icon(Icons.qr_code_scanner), label: Text(t.scan)),
        ]),
        for (final item in task.items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.name),
            subtitle: item.sku == null ? null : Text(item.sku!, style: Typo.code),
            leading: Text('×${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
            trailing: item.scanned ? const Icon(Icons.check_circle, color: Palette.green) : null,
          ),
      ],
      if (!task.finalState && (task.requirements.photo || task.requirements.code || task.next == 'complete')) ...[
        const SizedBox(height: 24),
        Text(t.proof.toUpperCase(), style: Typo.label),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _busy ? null : () => _photo(task),
              icon: Icon(task.pods.any((p) => p.type == 'photo') ? Icons.check : Icons.photo_camera_outlined),
              label: Text('${t.photo}${task.requirements.photoMandatory ? ' *' : ''}'.toUpperCase()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _busy ? null : () => _signature(task),
              icon: Icon(task.pods.any((p) => p.type == 'signature') ? Icons.check : Icons.draw_outlined),
              label: Text(t.signature.toUpperCase()),
            ),
          ),
        ]),
        if (task.requirements.code) ...[
          const SizedBox(height: 12),
          if (task.codeVerified)
            NoticeBanner(t.codeOk, icon: Icons.verified, color: Palette.green)
          else
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                  decoration: InputDecoration(labelText: '${t.enterCode}${task.requirements.codeMandatory ? ' *' : ''}'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(width: 110, child: OutlinedButton(onPressed: _busy ? null : () => _verifyCode(task), child: Text(t.checkCode.toUpperCase()))),
            ]),
        ],
        if (task.pods.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            for (final pod in task.pods)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(pod.url, headers: ref.watch(authHeadersProvider).value, width: 96, height: 80, fit: pod.type == 'signature' ? BoxFit.contain : BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox(width: 96, height: 80)),
              ),
          ]),
        ],
      ],
    ];
  }

  Widget _actions(AppLocalizations t, TaskDetail task) {
    final label = switch (task.next) {
      'claim' => t.nextClaim,
      'pickup' => t.nextPickup,
      'depart' => t.nextDepart,
      'arrive' => t.nextArrive,
      'complete' => t.nextComplete,
      _ => null,
    };
    final blocked = task.next == 'complete' && !task.canComplete;

    return Container(
      decoration: const BoxDecoration(color: Palette.surface, border: Border(top: BorderSide(color: Palette.outline, width: 1.5))),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (label != null)
          FilledButton.icon(
            onPressed: _busy || blocked ? null : () => _primary(task),
            icon: const Icon(Icons.arrow_forward),
            iconAlignment: IconAlignment.end,
            label: Text(label.toUpperCase()),
          ),
        if (blocked) Padding(padding: const EdgeInsets.only(top: 6), child: Text(t.addProofToFinish, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Palette.text2))),
        if (task.canFail) TextButton(onPressed: _busy ? null : () => _fail(task), child: Text(t.couldNotDeliver.toUpperCase())),
      ]),
    );
  }
}
