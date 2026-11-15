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
