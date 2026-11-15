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
                child: NgButton(
                  'Navigasi',
                  icon: 'directions',
                  expand: true,
                  onPressed: () => push(context, NavigationPage(trip: trip, day: day, i: i)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NgButton(
                  'Check-in',
                  kind: BtnKind.secondary,
                  icon: 'pin_drop',
                  expand: true,
                  onPressed: () => push(context, CheckinPage(trip: trip, day: day, i: i)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 6.2 Detail Stop Saat Perjalanan.
class TravelStopPage extends StatelessWidget {
  const TravelStopPage({super.key, required this.trip, required this.day, required this.i});
  final Trip trip;
  final int day;
  final int i;

  @override
  Widget build(BuildContext context) {
    AppScope.of(context);
    final st = trip.plan[day][i];
    final checked = trip.isChecked(day, i);
    final photos = [?st.photo, if (trip.cover != null && trip.cover != st.photo) trip.cover!];
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          HeroPhoto(st.photo ?? trip.cover, height: 220, semantic: st.name),
          Padding(
            padding: const EdgeInsets.fromLTRB(kMargin, 16, kMargin, 24),
            child: Gap(
              14,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    checked
                        ? Pill('Check-in ${trip.checkins['$day-$i']}', kind: PillKind.positive, icon: 'check')
                        : const Pill('Belum dikunjungi', kind: PillKind.warning),
                    Pill('Aktivitas ${i + 1} dari ${trip.plan[day].length}'),
                  ],
                ),
                Text(st.name, style: AppText.h1),
                MetaRow([('schedule', '${st.start}–${st.end}'), (st.cat.icon, st.cat.label), ('payments', st.cost > 0 ? rp(st.cost) : 'Gratis')]),
                if (st.desc != null) Text(st.desc!, style: AppText.body),
                if (st.note != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.yellowPale, borderRadius: BorderRadius.circular(AppRadius.card)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppIcon('lightbulb', size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Catatan creator', style: AppText.bodyStrong),
                              const SizedBox(height: 2),
                              Text(st.note!, style: AppText.body),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (photos.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Foto tempat', style: AppText.h2),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (var k = 0; k < photos.length; k++) ...[
                            if (k > 0) const SizedBox(width: 10),
                            Expanded(child: Photo(photos[k], height: 110, radius: AppRadius.inner)),
                          ],
                          if (photos.length == 1) ...[const SizedBox(width: 10), const Expanded(child: SizedBox())],
                        ],
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: NgButton(
                        'Navigasi',
                        icon: 'directions',
                        expand: true,
                        onPressed: () => push(context, NavigationPage(trip: trip, day: day, i: i)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NgButton(
                        checked ? 'Sudah check-in' : 'Check-in',
                        kind: BtnKind.secondary,
                        icon: 'pin_drop',
                        expand: true,
                        onPressed: checked ? null : () => push(context, CheckinPage(trip: trip, day: day, i: i)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 6.3 Navigasi.
class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key, required this.trip, required this.day, required this.i});
  final Trip trip;
  final int day;
  final int i;

  @override
  Widget build(BuildContext context) {
    final st = trip.plan[day][i];
    final info = travelInfo[st.name];
    final prev = i > 0 ? i - 1 : null;
    return Scaffold(
      backgroundColor: AppColors.mapLand,
      body: Stack(
        children: [
          Positioned.fill(
            child: MapView(
              height: null,
              kind: MapKind.lake,
              radius: 0,
              pins: [
                if (prev != null) MapPin(.8, .33, n: prev + 1, state: trip.isChecked(day, prev) ? MarkerState.done : MarkerState.todo),
                MapPin(.55, .5, n: i + 1, state: MarkerState.next),
              ],
              me: const Offset(.72, .38),
              label: false,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconBtn('arrow_back', label: 'Kembali', bg: AppColors.surface, size: 40, onTap: () => Navigator.pop(context)),
              ),
            ),
