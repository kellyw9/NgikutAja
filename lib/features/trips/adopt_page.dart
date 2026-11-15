import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../shell/home_shell.dart';
import 'customize_page.dart';
import 'trip_detail_page.dart';

/// 5.2 Adopt Itinerary: tanggal, pengingat, simpan offline.
class AdoptPage extends StatefulWidget {
  const AdoptPage({super.key, required this.it});
  final Itinerary it;

  @override
  State<AdoptPage> createState() => _AdoptPageState();
}

class _AdoptPageState extends State<AdoptPage> {
  late DateTime start = AppScope.read(context).today.add(const Duration(days: 7));
  bool dayBefore = true;
  bool each = true;
  int offset = 30;
  bool offline = true;

  Future<void> _adopt() async {
    final it = widget.it;
    final end = start.add(Duration(days: it.days - 1));
    final r = await showNgDialog(
      context,
      icon: 'luggage',
      title: 'Adopt itinerary ini?',
      body: '${it.places} tempat akan disalin ke Trip Saya untuk ${dateRange(start, end)}. Kamu bisa mengubahnya kapan saja.',
      actions: const [
        DialogAction('Adopt sekarang', kind: BtnKind.primary, value: true),
        DialogAction('Batal'),
      ],
    );
    if (r != true || !mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdoptProgressPage(it: it, start: start, dayBefore: dayBefore, each: each, offset: offset, offline: offline),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final it = widget.it;
    final end = start.add(Duration(days: it.days - 1));
    final before = start.subtract(const Duration(days: 1));
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const NgAppBar(title: 'Adopt ke Trip Saya', back: 'close'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
        children: [
          Gap(
            16,
            children: [
              NgCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Photo(it.cover, width: 72, height: 72, radius: AppRadius.inner),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it.title, style: AppText.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          MetaRow([('location_on', it.city), ('schedule', '${it.days} hari'), ('pin_drop', '${it.places} tempat')]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Creator asli', style: AppText.bodyStrong),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Avatar(it.creator.name, size: 36, tint: it.creator.tint),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              children: [
                                Text(it.creator.name, style: AppText.bodyStrong),
                                Text(it.creator.handle, style: AppText.body.muted),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('Kredit tetap tercatat di tripmu walau jadwalnya kamu ubah.', style: AppText.small.muted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              NgField(
                label: 'Tanggal keberangkatan',
                icon: 'calendar_month',
                value: dateLong(start),
                trailing: 'expand_more',
                helper: 'Trip selesai ${dateLong(end)} (${it.days} hari).',
                onTap: () async {
                  final d = await pickDate(context, initial: start, days: it.days);
                  if (d != null) setState(() => start = d);
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pengingat', style: AppText.bodyStrong),
                  const SizedBox(height: 6),
                  _switchRow(
                    'Sehari sebelum berangkat',
                    '${weekdaysLong[before.weekday - 1]}, ${before.day} ${monthsShort[before.month - 1]} pukul 19.00',
                    dayBefore,
                    (v) => setState(() => dayBefore = v),
                  ),
                  _switchRow('Sebelum tiap aktivitas', 'Notifikasi lokal di HP', each, (v) => setState(() => each = v)),
                  if (each)
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final m in const [15, 30, 60]) NgChip('$m menit', selected: offset == m, onTap: () => setState(() => offset = m)),
                      ],
                    ),
                ],
              ),
              NgCard(
                child: Row(
                  children: [
                    const AppIcon('download_for_offline', size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Simpan untuk offline', style: AppText.bodyStrong),
                          const SizedBox(height: 2),
                          Text('Jadwal, catatan, dan foto tempat bisa dibuka tanpa sinyal.', style: AppText.small.muted),
                        ],
                      ),
                    ),
                    NgToggle(offline, label: 'Simpan untuk offline', onChanged: (v) => setState(() => offline = v)),
                  ],
                ),
              ),
              NgButton('Adopt ke Trip Saya', icon: 'luggage', expand: true, onPressed: _adopt),
            ],
          ),
        ],
      ),
    );
  }

  Widget _switchRow(String title, String sub, bool v, ValueChanged<bool> on) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 48),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.body),
              const SizedBox(height: 2),
              Text(sub, style: AppText.small.muted),
            ],
          ),
        ),
        const SizedBox(width: 12),
