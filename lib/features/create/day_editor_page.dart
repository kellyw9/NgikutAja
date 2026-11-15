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
                      children: [
                        NgChip('Hari ${k + 1}', selected: k == day, onTap: () => _selectDay(k)),
                        if (_dayHasError(k))
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Semantics(
                              label: 'Hari ${k + 1} perlu diperbaiki',
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.negative,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.ground, width: 2),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(width: 8),
                  if (d.plan.length < 7)
                    IconBtn(
                      'add',
                      label: 'Tambah hari',
                      size: 36,
                      iconSize: 20,
                      stroke: AppColors.control,
                      bg: AppColors.surface,
                      onTap: () {
                        _saveTitle();
                        setState(() {
                          d.plan.add([]);
                          d.dayTitles.add('');
                          d.days = d.plan.length;
                          day = d.plan.length - 1;
                          dayTitle.text = '';
                        });
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kMargin, 16, kMargin, 0),
              child: Gap(
                12,
                children: [
                  NgField(
                    label: 'Judul hari',
                    icon: 'event_note',
                    controller: dayTitle,
                    hint: 'Misal: Istana dan kota tua',
                    onChanged: (_) => _saveTitle(),
                  ),
                  if (stops.isEmpty) ...[
                    Text('Hari ${day + 1} belum punya stop.', style: AppText.body.muted),
                    NgCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: AppColors.yellowPale, borderRadius: BorderRadius.circular(AppRadius.card)),
                            child: const AppIcon('location_on', size: 30),
                          ),
                          const SizedBox(height: 12),
                          Text('Belum ada stop', style: AppText.h2),
                          const SizedBox(height: 6),
                          Text('Hari ini belum punya stop. Tambahkan minimal 1 stop.', style: AppText.body.muted, textAlign: TextAlign.center),
                          const SizedBox(height: 14),
                          DashedAction('Tambah stop dari peta', icon: 'add_location_alt', color: AppColors.teal, onTap: () => _editStop()),
                        ],
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        const AppIcon('drag_indicator', size: 16, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Expanded(child: Text('Geser untuk mengurutkan', style: AppText.small.muted)),
                        MetaRow([('pin_drop', '${stops.length} tempat'), ('payments', rp(cost))], color: AppColors.ink),
                      ],
                    ),
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      padding: EdgeInsets.zero,
                      proxyDecorator: (child, _, _) => Material(
                        color: Colors.transparent,
                        child: DecoratedBox(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: kFloatShadow),
                          child: child,
                        ),
                      ),
                      onReorderItem: (a, b) => setState(() {
                        final s = stops.removeAt(a);
                        stops.insert(b, s);
                      }),
                      children: [
                        for (var i = 0; i < stops.length; i++)
                          Padding(
                            key: ObjectKey(stops[i]),
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _StopCard(stop: stops[i], index: i, conflict: conflictIndexes(stops).contains(i), onEdit: () => _editStop(i)),
                          ),
                      ],
                    ),
                    if (conflicts.isNotEmpty)
                      Text('Stop bertanda merah jamnya tumpang tindih. Ubah jam lewat ikon pensil.', style: AppText.small.c(AppColors.negative)),
                    DashedAction('Tambah stop dari peta', icon: 'add_location_alt', color: AppColors.teal, onTap: () => _editStop()),
                  ],
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (anyError) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppIcon('warning', size: 16, color: AppColors.negative),
                      const SizedBox(width: 6),
                      Text('Selesaikan error sebelum lanjut', style: AppText.small.c(AppColors.negative)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                NgButton(
                  'Lanjut ke publish',
                  trailingIcon: 'arrow_forward',
                  expand: true,
                  onPressed: anyError
                      ? null
                      : () {
                          _saveTitle();
                          push(context, PublishPage(d: d));
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  const _StopCard({required this.stop, required this.index, required this.conflict, required this.onEdit});
  final Stop stop;
  final int index;
  final bool conflict;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: conflict ? AppColors.negative : AppColors.line, width: conflict ? 2 : 1),
    ),
    child: Row(
      children: [
        ReorderableDragStartListener(
          index: index,
          child: Semantics(
            label: 'Geser untuk mengurutkan ${stop.name}',
            child: const MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: SizedBox(
                width: 36,
                height: 52,
                child: Center(child: AppIcon('drag_indicator', size: 20, color: AppColors.muted)),
              ),
            ),
          ),
        ),
        stop.photo != null ? Photo(stop.photo, width: 52, height: 52, radius: AppRadius.inner) : IconTile(stop.cat.icon, size: 52, iconSize: 24),
        const SizedBox(width: 12),
        Expanded(
