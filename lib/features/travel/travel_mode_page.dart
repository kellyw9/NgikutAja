import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import 'checkin_page.dart';
import 'expenses_page.dart';
import 'photo_pages.dart';

/// Jarak dan waktu tempuh dari data contoh (belum ada layanan rute).
const travelInfo = {'Bukit Holbung': ('6,4 km', '18 menit', 'Naik motor')};

/// 6.1 Travel Mode (dan 6.7 saat offline).
class TravelModePage extends StatelessWidget {
  const TravelModePage({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = trip;
    final day = app.currentDay(t);
    final stops = t.plan[day];
    final next = app.nextIndex(t, day);
    final date = t.dayDate(day);
    final done = t.visited();
    final total = t.places();

    return AnnotatedRegion(
      value: kLightIcons.copyWith(systemNavigationBarColor: AppColors.surface, systemNavigationBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: AppColors.ground,
        body: Column(
          children: [
            Container(
              color: AppColors.ink,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    if (!app.online)
                      const NgBanner(
                        kind: BannerKind.offline,
                        text: 'Kamu sedang offline. Jadwal dan catatan tetap bisa dibuka, check-in disimpan dulu di HP.',
                      ),
                    SizedBox(
                      height: 56,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, right: 12),
                        child: Row(
                          children: [
                            IconBtn('close', label: 'Tutup Travel Mode', color: AppColors.white, onTap: () => Navigator.pop(context)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Semantics(header: true, child: Text('Travel Mode', style: AppText.h2.white)),
                            ),
                            Container(
                              height: 28,
                              padding: const EdgeInsets.only(left: 6, right: 10),
                              decoration: BoxDecoration(color: AppColors.inkRaised, borderRadius: BorderRadius.circular(AppRadius.tag)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppIcon(!app.online ? 'cloud_off' : (t.offline ? 'cloud_done' : 'cloud_off'), size: 16, color: AppColors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    !app.online ? 'Offline' : (t.offline ? 'Tersimpan offline' : 'Belum tersimpan offline'),
                                    style: AppText.smallStrong.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(kMargin, 4, kMargin, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hari ${day + 1}${date != null ? ', ${weekdaysLong[date.weekday - 1]} ${date.day} ${monthsShort[date.month - 1]}' : ''}',
                            style: AppText.bodyStrong.c(AppColors.yellow),
                          ),
                          const SizedBox(height: 6),
                          Text(t.title, style: AppText.h1.white),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text('$done dari $total tempat selesai', style: AppText.small.white),
                              const Spacer(),
                              Text('${total == 0 ? 0 : (done / total * 100).round()}%', style: AppText.smallStrong.white),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Progress(total == 0 ? 0 : done / total, track: AppColors.inkRaised),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(kMargin, 14, kMargin, 16),
                children: [
                  if (next != null)
                    _NextCard(trip: t, day: day, i: next)
                  else
                    NgCard(
                      child: Row(
                        children: [
                          const AppIcon('task_alt', color: AppColors.positive),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              stops.isEmpty ? 'Tidak ada aktivitas hari ini.' : 'Semua aktivitas hari ini sudah selesai.',
                              style: AppText.bodyStrong,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Text('Jadwal hari ini', style: AppText.h2)),
                      Text('${stops.length} aktivitas', style: AppText.small.muted),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < stops.length; i++)
                    StopRow(
                      stops[i],
                      n: i + 1,
                      last: i == stops.length - 1,
                      note: false,
                      thumb: false,
                      state: t.isChecked(day, i) ? MarkerState.done : (i == next ? MarkerState.next : MarkerState.todo),
                      line: t.isChecked(day, i) ? AppColors.teal : AppColors.rule,
                      onTap: () => push(context, TravelStopPage(trip: t, day: day, i: i)),
                      extra: t.isChecked(day, i) ? Text('Check-in ${t.checkins['$day-$i']}', style: AppText.smallStrong.c(AppColors.positive)) : null,
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomBar(
          children: [
            Expanded(
              child: NgButton(
                'Pengeluaran',
                kind: BtnKind.secondary,
                size: BtnSize.md,
                icon: 'payments',
                expand: true,
                onPressed: () => push(context, ExpensesPage(trip: t)),
              ),
            ),
            Expanded(
              child: NgButton(
                'Tambah foto',
                kind: BtnKind.secondary,
                size: BtnSize.md,
                icon: 'add_a_photo',
                expand: true,
                onPressed: () => addTripPhoto(context, t, day),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.trip, required this.day, required this.i});
  final Trip trip;
  final int day;
  final int i;

  @override
  Widget build(BuildContext context) {
    final st = trip.plan[day][i];
    final info = travelInfo[st.name];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.yellow, width: 2),
      ),
      child: Column(
        children: [
          Tap(
            onTap: () => push(context, TravelStopPage(trip: trip, day: day, i: i)),
            radius: 6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Marker(i + 1, state: MarkerState.next, size: 22),
                          const SizedBox(width: 6),
                          Text('Berikutnya pukul ${st.start}', style: AppText.smallStrong.muted),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(st.name, style: AppText.h2),
                      const SizedBox(height: 6),
                      MetaRow([(st.cat.icon, st.cat.label), if (info != null) ('near_me', info.$1), if (info != null) ('timer', info.$2)]),
                    ],
                  ),
                ),
                if (st.photo != null) ...[const SizedBox(width: 12), Photo(st.photo, width: 68, height: 68, radius: AppRadius.inner)],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
