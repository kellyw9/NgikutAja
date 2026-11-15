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
