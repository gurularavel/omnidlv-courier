import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' show LocationPermission;
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/api/api_exception.dart';
import '../../core/config.dart';
import '../../data/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/location_tracker.dart';
import '../../services/nav_launcher.dart';
import '../../state/providers.dart';
import '../actions.dart';
import '../sheets.dart';
import '../theme.dart';
import '../widgets.dart';

/// Home: the next stop owns the screen; the rest of the day lives in "My day".
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from Waze or a phone call: show what changed meanwhile.
    if (state == AppLifecycleState.resumed) ref.read(boardProvider.notifier).refresh();
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

  Future<void> _startShift() => _guard(() async {
        final t = AppLocalizations.of(context);
        final permission = await LocationTracker.permission();
        if (permission != LocationPermission.always && mounted) {
          final ok = await context.push<bool>('/permissions');
          if (ok != true) return;
        }
        try {
          final pos = await LocationTracker.currentPosition();
          final board = await ref.read(repositoryProvider).startShift(lat: pos?.latitude, lng: pos?.longitude);
          ref.read(boardProvider.notifier).replace(board);
        } on ApiException catch (e) {
          if (mounted) showMessage(context, errorText(t, e), error: true);
        }
      });

  Future<void> _endShift() => _guard(() async {
        final t = AppLocalizations.of(context);
        Navigator.of(context).pop(); // menu
        try {
          ref.read(boardProvider.notifier).replace(await ref.read(repositoryProvider).endShift());
        } on ApiException catch (e) {
          if (mounted) showMessage(context, errorText(t, e), error: true);
        }
      });

  Future<void> _primary(TaskDetail n) => _guard(() async {
        // Handing over needs proof and a confirmation: that lives on the task screen.
        if (n.next == 'complete') {
          await context.push('/task/${n.id}?handover=1');
          return;
        }
        final repo = ref.read(repositoryProvider);
        await runTaskAction(context, ref, (point) => n.next == 'claim' ? repo.claim(n.id) : repo.step(n.id, n.next!, point: point));
      });

  Future<void> _take(TaskSummary s) async {
    final repo = ref.read(repositoryProvider);
    await runTaskAction(context, ref, (_) => repo.claim(s.id));
  }

  Future<void> _deleteAccount() async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(t.deleteAccount),
        content: Text(t.deleteAccountBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancel)),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(t.send, style: const TextStyle(color: Palette.danger))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(repositoryProvider).requestDeletion(null);
      if (mounted) showMessage(context, t.deleteAccountBody);
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorText(t, e), error: true);
    }
  }

  void _openMenu() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => MenuSheet(onEndShift: _endShift, onDeleteAccount: _deleteAccount),
      );

  void _openMyDay() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheet) => MyDaySheet(
          onOpen: (s) {
            Navigator.of(sheet).pop();
            context.push('/task/${s.id}');
          },
          onTake: _take,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final boardState = ref.watch(boardProvider);
    final queued = ref.watch(actionQueueProvider).pending;

    return Scaffold(
      body: SafeArea(
        child: boardState.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(boardProvider)),
          data: (board) => RefreshIndicator(
            color: Palette.action,
            onRefresh: () => ref.read(boardProvider.notifier).refresh(),
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(child: _Header(board: board, onMenu: _openMenu)),
              if (queued > 0) SliverToBoxAdapter(child: NoticeBanner(t.queuedBanner(queued))),
              if (!board.shiftActive)
                SliverFillRemaining(hasScrollBody: false, child: _OffShift(onStart: _busy ? null : _startShift))
              else if (board.next == null)
                SliverFillRemaining(hasScrollBody: false, child: _NoOrders(pool: board.pool.length, onPool: _openMyDay))
              else
                SliverToBoxAdapter(child: _NextStop(task: board.next!)),
            ]),
          ),
        ),
      ),
      bottomNavigationBar: boardState.value?.shiftActive == true && boardState.value?.next != null
          ? _BottomBar(task: boardState.value!.next!, board: boardState.value!, busy: _busy, onPrimary: _primary, onMyDay: _openMyDay)
          : null,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.board, required this.onMenu});
  final Board board;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final on = board.shiftActive;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Palette.outline, width: 1.5))),
      child: Row(children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: on ? Palette.parse(board.courier.ink) : Palette.text3, width: 4)),
        ),
        const SizedBox(width: 10),
        Text((on ? t.onShift : t.offShiftTitle).toUpperCase(), style: Typo.label.copyWith(color: Palette.text)),
        const Spacer(),
        if (on) Text('${board.delivered}/${board.delivered + board.active.length}', style: const TextStyle(color: Palette.text2)),
        IconButton(onPressed: onMenu, icon: const Icon(Icons.menu), tooltip: t.menu),
      ]),
    );
  }
}

class _OffShift extends StatelessWidget {
  const _OffShift({required this.onStart});
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 24),
        Text(t.offShiftTitle.toUpperCase(), style: Typo.display),
        const SizedBox(height: 12),
        Text(t.offShiftBody, style: const TextStyle(color: Palette.text2)),
        const Spacer(),
        FilledButton.icon(onPressed: onStart, icon: const Icon(Icons.arrow_forward), iconAlignment: IconAlignment.end, label: Text(t.startShift.toUpperCase())),
      ]),
    );
  }
}

class _NoOrders extends StatelessWidget {
  const _NoOrders({required this.pool, required this.onPool});
  final int pool;
  final VoidCallback onPool;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 24),
        Text(t.noOrdersTitle.toUpperCase(), style: Typo.display),
        const SizedBox(height: 12),
        Text(t.noOrdersBody, style: const TextStyle(color: Palette.text2)),
        const Spacer(),
        OutlinedButton(onPressed: onPool, child: Text('${t.tabPool.toUpperCase()} · $pool')),
      ]),
    );
  }
}

class _NextStop extends ConsumerWidget {
  const _NextStop({required this.task});
  final TaskDetail task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final n = task;
    final place = [
      if (n.target.building != null) n.target.building,
      if (n.target.floor != null) n.target.floor,
      if (n.target.apartment != null) n.target.apartment,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(crossAxisAlignment: WrapCrossAlignment.end, spacing: 8, runSpacing: 6, children: [
          Text(n.minutesLabel, style: Typo.hero.copyWith(color: urgencyColor(n.urgency))),
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(minutesKicker(t, n).toUpperCase(), style: Typo.label)),
          if (n.category == 'assigned' && n.type == 'drop_off') Tag(t.pickUpFirst, strong: true),
        ]),
        const SizedBox(height: 16),
        Text((n.target.address ?? '—').toUpperCase(), style: Typo.display),
        if (place.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(place, style: const TextStyle(color: Palette.text2))),
        const SizedBox(height: 8),
        Text.rich(TextSpan(children: [
          TextSpan(text: n.target.name ?? ''),
          if (n.phoneDisplay != null) TextSpan(text: ' · ${n.phoneDisplay}', style: const TextStyle(color: Palette.text2)),
        ])),
        const SizedBox(height: 4),
        Text(n.code, style: Typo.code),
        if (n.target.lat != null) ...[
          const SizedBox(height: 16),
          _MapStrip(task: n),
        ],
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (n.cash != null) Tag(t.collect('${n.cash!.toStringAsFixed(2)} ${n.currency ?? ''}'), strong: true),
          if (n.requirements.code) Tag('${t.deliveryCode}${n.requirements.codeMandatory ? ' · ${t.mandatory}' : ''}'),
          if (n.requirements.photo) Tag('${t.photo}${n.requirements.photoMandatory ? ' · ${t.mandatory}' : ''}'),
          if (n.requirements.dontRing) Tag(t.dontRing),
          if (n.requirements.contactless) Tag(t.contactless),
          ActionChip(label: Text(t.details), onPressed: () => context.push('/task/${n.id}'), avatar: const Icon(Icons.chevron_right, size: 18)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: n.phone == null ? null : () => NavLauncher.call(n.phone!),
              icon: const Icon(Icons.phone_outlined),
              label: Text(t.call.toUpperCase()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: n.canNavigate ? () => openDirections(context, ref, n) : null,
              icon: const Icon(Icons.navigation_outlined),
              label: Text(t.navigate.toUpperCase()),
            ),
          ),
        ]),
      ]),
    );
  }
}

/// A look-only map: where the stop is. No gestures, so scrolling the page never pans it.
class _MapStrip extends StatelessWidget {
  const _MapStrip({required this.task});
  final TaskDetail task;

  @override
  Widget build(BuildContext context) {
    final target = LatLng(task.target.lat!, task.target.lng!);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radiusPlate),
      child: Container(
        height: 170,
        decoration: BoxDecoration(border: Border.all(color: Palette.outline, width: 1.5), borderRadius: BorderRadius.circular(radiusPlate)),
        child: FlutterMap(
          options: MapOptions(initialCenter: target, initialZoom: 15, interactionOptions: const InteractionOptions(flags: InteractiveFlag.none)),
          children: [
            TileLayer(urlTemplate: AppConfig.tileUrl, userAgentPackageName: 'az.omnidlv.courier'),
            MarkerLayer(markers: [
              Marker(
                point: target,
                width: 22,
                height: 22,
                child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Palette.teal, width: 5))),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.task, required this.board, required this.busy, required this.onPrimary, required this.onMyDay});
  final TaskDetail task;
  final Board board;
  final bool busy;
  final Future<void> Function(TaskDetail) onPrimary;
  final VoidCallback onMyDay;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final label = switch (task.next) {
      'claim' => t.nextClaim,
      'pickup' => t.nextPickup,
      'depart' => t.nextDepart,
      'arrive' => t.nextArrive,
      'complete' => t.nextComplete,
      _ => null,
    };

    return Container(
      decoration: const BoxDecoration(color: Palette.surface, border: Border(top: BorderSide(color: Palette.outline, width: 1.5))),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (label != null)
          FilledButton.icon(
            onPressed: busy ? null : () => onPrimary(task),
            icon: const Icon(Icons.arrow_forward),
            iconAlignment: IconAlignment.end,
            label: Text(label.toUpperCase()),
          ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onMyDay,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Text(t.myDay.toUpperCase(), style: Typo.label.copyWith(color: Palette.text)),
              const SizedBox(width: 12),
              Expanded(child: _StopsLine(board: board)),
              const Icon(Icons.expand_less),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// The rest of the day as a transit line: one station per stop, late ones ringed.
class _StopsLine extends StatelessWidget {
  const _StopsLine({required this.board});
  final Board board;

  @override
  Widget build(BuildContext context) {
    final stops = board.active.skip(1).take(8).toList();
    final ink = Palette.parse(board.courier.ink);
    if (stops.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 22,
      child: Stack(alignment: Alignment.center, children: [
        Container(height: 5, decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(3))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          for (final s in stops)
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: ink, width: 3),
                boxShadow: s.urgency == Urgency.late ? const [BoxShadow(color: Palette.action, spreadRadius: 2.5)] : null,
              ),
            ),
        ]),
      ]),
    );
  }
}
