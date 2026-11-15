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
