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
