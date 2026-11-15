import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../trips/schedule_logic.dart';
import 'add_stop_page.dart';
import 'create_itinerary_page.dart';
import 'publish_page.dart';

/// Langkah 2: Editor Hari & Stop (+ state error: jam bentrok, hari tanpa stop).
class DayEditorPage extends StatefulWidget {
  const DayEditorPage({super.key, required this.d});
  final Itinerary d;

  @override
  State<DayEditorPage> createState() => _DayEditorPageState();
}

class _DayEditorPageState extends State<DayEditorPage> {
  late final d = widget.d;
  int day = 0;
  late final dayTitle = TextEditingController(text: _title(0));

  String _title(int k) => k < d.dayTitles.length ? d.dayTitles[k] : '';

  void _selectDay(int k) {
    _saveTitle();
    setState(() {
      day = k;
      dayTitle.text = _title(k);
    });
  }

  void _saveTitle() {
    while (d.dayTitles.length < d.plan.length) {
      d.dayTitles.add('');
    }
    d.dayTitles[day] = dayTitle.text.trim();
  }

  bool _dayHasError(int k) => d.plan[k].isEmpty || conflictsIn(d.plan[k]).isNotEmpty;

  Future<void> _editStop([int? i]) async {
    final r = await push<StopEditResult>(
      context,
      AddStopPage(
        stop: i == null ? null : d.plan[day][i].copy(),
        city: d.city,
        defaultStart: d.plan[day].isEmpty ? '08.00' : fromMinutes(d.plan[day].map((s) => s.endMin).reduce((a, b) => a > b ? a : b) + 15),
      ),
      fullscreen: true,
    );
    if (r == null) return;
    setState(() {
      if (i == null) {
        if (r.stop != null) d.plan[day].add(r.stop!);
      } else if (r.deleted) {
        d.plan[day].removeAt(i);
      } else {
        d.plan[day][i] = r.stop!;
      }
    });
  }

  @override
  void dispose() {
    dayTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stops = d.plan[day];
    final conflicts = conflictsIn(stops);
    final anyError = [for (var k = 0; k < d.plan.length; k++) _dayHasError(k)].any((x) => x);
    final cost = stops.fold<int>(0, (a, s) => a + s.cost);

    // Pesan error pertama di seluruh hari, supaya pengguna tahu harus ke hari mana.
    String? conflictMsg;
    for (var k = 0; k < d.plan.length && conflictMsg == null; k++) {
      final c = conflictsIn(d.plan[k]);
      if (c.isNotEmpty) {
        final a = d.plan[k][c.first.$1];
        conflictMsg = 'Jam ${a.name} di Hari ${k + 1} bentrok dengan stop berikutnya.';
      }
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, _) => _saveTitle(),
      child: Scaffold(
        backgroundColor: AppColors.ground,
        appBar: NgAppBar(title: d.title, sub: 'Editor hari & stop', trailingTitle: draftPill),
        body: ListView(
          padding: const EdgeInsets.only(top: 4, bottom: 24),
          children: [
            if (conflictMsg != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 12),
                child: NgBanner(kind: BannerKind.error, title: conflictMsg, text: 'Periksa kembali jadwal waktu kunjungan atau atur ulang durasi.'),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: kMargin),
              child: Row(
                children: [
                  for (var k = 0; k < d.plan.length; k++) ...[
                    if (k > 0) const SizedBox(width: 8),
                    Stack(
                      clipBehavior: Clip.none,
