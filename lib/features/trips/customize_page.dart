import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import 'schedule_logic.dart';
import 'trip_forms.dart';

export 'trip_forms.dart';

/// 5.4 Customize Trip, termasuk 5.6 pindahkan, 5.7 tambah hari, 5.9 catatan jadwal, 5.10 status simpan.
class CustomizePage extends StatefulWidget {
  const CustomizePage({super.key, required this.trip, this.initialDay = 0});
  final Trip trip;
  final int initialDay;

  @override
  State<CustomizePage> createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
  late Trip t = widget.trip;
  late List<List<Stop>> plan = copyPlan(t.plan);
  late List<String> titles = [for (var d = 0; d < t.days; d++) t.dayTitle(d)];
  late int day = widget.initialDay.clamp(0, t.days - 1);
  int changes = 0;
  bool saving = false;

  void _changed(VoidCallback f) => setState(() {
    f();
    changes++;
  });

  String _dayLabel(int d) {
    final date = t.dayDate(d);
    return date == null ? 'Hari ${d + 1}' : 'Hari ${d + 1}, ${weekdaysLong[date.weekday - 1]} ${date.day} ${monthsShort[date.month - 1]}';
  }

  Future<void> _save() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      await AppScope.read(context).saveTripPlan(t, copyPlan(plan), [...titles]);
      if (!mounted) return;
      setState(() {
        saving = false;
        changes = 0;
      });
      showNgSnack(context, 'Perubahan tersimpan. Pengingat ikut diperbarui.', kind: SnackKind.success);
    } catch (_) {
      if (!mounted) return;
      setState(() => saving = false);
      showNgSnack(context, 'Gagal menyimpan. Perubahanmu masih ada di layar.', kind: SnackKind.error, action: 'Coba lagi', onAction: _save);
    }
  }

  Future<bool> _confirmLeave() async {
    if (changes == 0) return true;
    final r = await showNgDialog(
      context,
      title: 'Buang perubahan?',
      body: 'Ada $changes perubahan yang belum disimpan.',
      actions: const [
        DialogAction('Lanjut mengedit', kind: BtnKind.primary, value: false),
        DialogAction('Buang perubahan', kind: BtnKind.dangerText, value: true),
      ],
    );
    return r == true;
  }

  Future<void> _edit(int i) async {
    final r = await push<StopEditResult>(context, EditStopPage(stop: plan[day][i].copy(), dayLabel: _dayLabel(day)), fullscreen: true);
    if (r == null) return;
    _changed(() => r.deleted ? plan[day].removeAt(i) : plan[day][i] = r.stop!);
  }

  Future<void> _add() async {
    final last = plan[day].isEmpty ? null : plan[day].map((s) => s.endMin).reduce((a, b) => a > b ? a : b);
    final r = await push<StopEditResult>(
      context,
      EditStopPage(dayLabel: _dayLabel(day), defaultStart: last == null ? '09.00' : fromMinutes(last + 15)),
      fullscreen: true,
    );
    if (r?.stop != null) _changed(() => plan[day].add(r!.stop!));
  }

  Future<void> _delete(int i) async {
    final st = plan[day][i];
    final r = await showNgDialog(
      context,
      icon: 'delete',
      title: 'Hapus ${st.name}?',
      body: 'Aktivitas ini dihapus dari Hari ${day + 1}. Jam aktivitas setelahnya tidak ikut bergeser.',
      actions: const [
        DialogAction('Hapus aktivitas', kind: BtnKind.danger, value: true),
        DialogAction('Batal'),
      ],
    );
    if (r == true) _changed(() => plan[day].removeAt(i));
  }

  Future<void> _move(int i) async {
    final st = plan[day][i];
    final target = await showNgSheet<int>(
      context,
      title: 'Pindahkan aktivitas',
      scroll: true,
      builder: (ctx) {
        int? pick = plan.length > 1 ? (day == plan.length - 1 ? day - 1 : day + 1) : null;
        return StatefulBuilder(
          builder: (ctx, set) {
            final dest = pick;
            final lastEnd = dest == null || plan[dest].isEmpty ? null : plan[dest].map((s) => s.endMin).reduce((a, b) => a > b ? a : b);
            return Gap(
              16,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.ground, borderRadius: BorderRadius.circular(AppRadius.card)),
                  child: Row(
                    children: [
                      Marker(i + 1),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(st.name, style: AppText.bodyStrong),
                            const SizedBox(height: 2),
                            Text('${st.cat.label}, Hari ${day + 1} pukul ${st.start}–${st.end}', style: AppText.small.muted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    for (var d = 0; d < plan.length; d++) ...[
                      if (d > 0) const NgDivider(color: AppColors.line),
                      RadioRow(
                        title: _dayLabel(d),
                        sub: d == day
                            ? 'Posisi sekarang'
                            : plan[d].isEmpty
                            ? 'Belum ada aktivitas'
                            : '${plan[d].length} aktivitas, selesai ${fromMinutes(plan[d].map((s) => s.endMin).reduce((a, b) => a > b ? a : b))}',
                        selected: d == pick,
                        enabled: d != day,
                        height: 56,
                        onTap: () => set(() => pick = d),
                      ),
                    ],
                  ],
                ),
                if (dest != null)
                  Text(
                    'Masuk di urutan terakhir Hari ${dest + 1}, mulai ${lastEnd == null ? st.start : fromMinutes(lastEnd + 15)}. Jam bisa disesuaikan kembali.',
                    style: AppText.small.muted,
                  ),
                NgButton(
                  dest == null ? 'Tambah hari dulu' : 'Pindahkan ke Hari ${dest + 1}',
                  expand: true,
                  onPressed: dest == null ? null : () => Navigator.pop(ctx, dest),
                ),
              ],
            );
          },
        );
      },
    );
    if (target == null || !mounted) return;
    final lastEnd = plan[target].isEmpty ? null : plan[target].map((s) => s.endMin).reduce((a, b) => a > b ? a : b);
    final ns = lastEnd == null ? st.start : fromMinutes(lastEnd + 15);
    final from = t.dayDate(day), to = t.dayDate(target);
    final ok = await showNgDialog(
      context,
      icon: 'drive_file_move',
      title: 'Pindahkan ke Hari ${target + 1}?',
      body: from != null && to != null
          ? '${st.name} pindah dari ${weekdaysLong[from.weekday - 1]}, ${from.day} ${monthsShort[from.month - 1]} ke ${weekdaysLong[to.weekday - 1]}, ${to.day} ${monthsShort[to.month - 1]} pukul $ns.'
          : '${st.name} pindah dari Hari ${day + 1} ke Hari ${target + 1} pukul $ns.',
      actions: const [
        DialogAction('Pindahkan sekarang', kind: BtnKind.primary, value: true),
        DialogAction('Batal'),
      ],
    );
    if (ok != true) return;
    _changed(() {
      final s = plan[day].removeAt(i);
      appendToDay(plan[target], s);
    });
    if (mounted) showNgSnack(context, '${st.name} dipindah ke Hari ${target + 1}.');
  }

  Future<void> _addDay() async {
    final n = plan.length + 1;
    final newDate = t.start?.add(Duration(days: n - 1));
    final ok = await showNgSheet<bool>(
      context,
      title: 'Tambah hari',
      sub: 'Hari baru ditaruh setelah Hari ${plan.length}.',
      builder: (ctx) => Gap(
        16,
        children: [
          NgField(label: 'Nomor hari', value: 'Hari $n', readOnly: true, fill: AppColors.surfaceSoft),
          if (newDate != null)
            NgField(
              label: 'Tanggal perjalanan',
              icon: 'calendar_month',
              value: dateLong(newDate),
              readOnly: true,
              fill: AppColors.surfaceSoft,
              helper: 'Tanggal selesai trip otomatis berubah menjadi ${newDate.day} ${monthsShort[newDate.month - 1]} ${newDate.year}.',
            ),
          NgButton('Tambah hari', expand: true, onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (ok == true) {
      _changed(() {
        plan.add([]);
        titles.add('Hari $n');
        day = plan.length - 1;
      });
    }
  }

  void _notes() {
    showNgSheet<void>(
      context,
      title: 'Catatan jadwal',
      sub: 'Hanya peringatan. Perubahan tetap bisa disimpan.',
      scroll: true,
      builder: (ctx) {
        final (issues, tips) = analyze(plan);
        if (issues.isEmpty) {
          return const EmptyState(icon: 'task_alt', title: 'Jadwal aman', text: 'Tidak ada jadwal yang bertabrakan atau terlalu padat.', height: 200);
        }
        return Gap(
          16,
          children: [
            for (final iss in issues)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iss.conflict ? AppColors.negativePale : AppColors.yellowPale,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppIcon(iss.conflict ? 'error' : 'warning', size: 20, color: iss.conflict ? AppColors.negativeInk : AppColors.ink),
                        const SizedBox(width: 8),
                        Expanded(child: Text(iss.title, style: AppText.bodyStrong.c(iss.conflict ? AppColors.negativeInk : AppColors.ink))),
                      ],
                    ),
                    for (final l in iss.lines) ...[
                      const SizedBox(height: 6),
                      Text(l, style: AppText.body.c(iss.conflict ? AppColors.negativeInk : AppColors.ink)),
                    ],
                  ],
                ),
              ),
            if (tips.isNotEmpty) Text('Saran penyesuaian', style: AppText.h2),
            for (final s in tips)
              Row(
                children: [
                  AppIcon(s.icon, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title, style: AppText.bodyStrong),
                        const SizedBox(height: 2),
                        Text(s.sub, style: AppText.small.muted),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  NgButton(
                    'Terapkan',
                    kind: BtnKind.secondary,
                    size: BtnSize.md,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _changed(() => s.apply(plan));
                      showNgSnack(context, 'Saran diterapkan. Jangan lupa simpan.');
                    },
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stops = plan[day];
    final conflicts = conflictsIn(stops);
    final bad = conflictIndexes(stops);
    return PopScope(
      canPop: changes == 0,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.ground,
        appBar: NgAppBar(
          title: 'Customize trip',
          back: 'close',
          onBack: () => Navigator.maybePop(context),
          actions: [NgButton('Simpan', kind: BtnKind.text, size: BtnSize.md, onPressed: saving ? null : _save)],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kMargin),
              child: NgCard(
                padding: const EdgeInsets.all(10),
                onTap: () => push(context, EditTripInfoPage(trip: t), fullscreen: true).then((_) => setState(() {})),
                child: Row(
                  children: [
                    Photo(t.cover, width: 56, height: 56, radius: AppRadius.inner),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title, style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            t.start == null ? 'Tanggal belum diatur' : dateRange(t.start!, t.start!.add(Duration(days: plan.length - 1))),
                            style: AppText.small.muted,
                          ),
                        ],
                      ),
                    ),
                    IconBtn(
                      'edit',
                      label: 'Edit informasi trip',
                      size: 40,
                      iconSize: 18,
                      onTap: () => push(context, EditTripInfoPage(trip: t), fullscreen: true).then((_) => setState(() {})),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            DayStrip(
              days: [
                for (var d = 0; d < plan.length; d++)
                  DayItem(
                    'Hari ${d + 1}',
                    date: t.dayDate(d) == null ? null : dateShort(t.dayDate(d)!),
                    sub: '${plan[d].length} tempat',
                    alert: conflictsIn(plan[d]).isNotEmpty,
                  ),
              ],
              active: day,
              onTap: (d) => setState(() => day = d),
              onAdd: _addDay,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kMargin, 12, kMargin, 0),
              child: Gap(
                14,
                children: [
                  if (conflicts.isNotEmpty)
                    NgBanner(
                      kind: BannerKind.error,
                      title: 'Jadwal bertabrakan di Hari ${day + 1}',
                      text:
                          '${stops[conflicts.first.$1].name} (${stops[conflicts.first.$1].start}–${stops[conflicts.first.$1].end}) dan '
                          '${stops[conflicts.first.$2].name} (${stops[conflicts.first.$2].start}–${stops[conflicts.first.$2].end}). Tetap bisa disimpan.',
                      action: 'Lihat saran',
                      onAction: _notes,
                    )
                  else if (isPacked(stops))
                    NgBanner(
                      kind: BannerKind.warning,
                      title: 'Hari ${day + 1} terlalu padat',
                      text: '${durationText(activeMinutes(stops))} aktivitas.',
                      action: 'Lihat saran',
                      onAction: _notes,
                    ),
                  if (stops.isEmpty)
                    Text('Belum ada aktivitas di Hari ${day + 1}.', style: AppText.body.muted)
                  else
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      padding: EdgeInsets.zero,
                      proxyDecorator: (child, _, _) => Material(
                        color: AppColors.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          side: const BorderSide(color: AppColors.ink),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: kFloatShadow),
                          child: Padding(padding: const EdgeInsets.fromLTRB(10, 10, 8, 0), child: child),
                        ),
                      ),
                      onReorderItem: (a, b) => _changed(() {
                        final s = stops.removeAt(a);
                        stops.insert(b, s);
                      }),
                      children: [
                        for (var i = 0; i < stops.length; i++)
                          KeyedSubtree(
                            key: ObjectKey(stops[i]),
                            child: StopRow(
                              stops[i],
                              n: i + 1,
                              last: i == stops.length - 1,
                              note: false,
                              conflict: bad.contains(i),
                              trailing: ReorderableDragStartListener(
                                index: i,
                                child: Semantics(
                                  label: 'Geser untuk mengurutkan ${stops[i].name}',
                                  child: const MouseRegion(
                                    cursor: SystemMouseCursors.grab,
                                    child: SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: Center(child: AppIcon('drag_indicator', color: AppColors.muted)),
                                    ),
                                  ),
                                ),
                              ),
                              extra: Wrap(
                                spacing: 16,
                                children: [
                                  TextLink('Edit', style: AppText.smallStrong, onTap: () => _edit(i)),
                                  TextLink('Pindahkan', style: AppText.smallStrong, onTap: () => _move(i)),
                                  TextLink('Hapus', style: AppText.smallStrong, color: AppColors.negative, onTap: () => _delete(i)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  DashedAction('Tambah aktivitas', onTap: _add),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Foto perjalanan', style: AppText.h2),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            AddPhotoTile(
                              size: 72,
                              onTap: () async {
                                final p = await pickPhotoSheet(context, title: 'Tambah foto perjalanan');
                                if (p == null || p.isEmpty || !context.mounted) return;
                                final now = DateTime.now();
                                AppScope.read(
                                  context,
                                ).addPhoto(t, TripPhoto(src: p, day: day, caption: t.title, time: fromMinutes(now.hour * 60 + now.minute)));
                                setState(() {});
                              },
                            ),
                            const SizedBox(width: 10),
                            if (t.photos.isEmpty)
                              Text('Belum ada foto untuk trip ini.', style: AppText.body.muted)
