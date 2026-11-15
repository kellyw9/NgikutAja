import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../create/create_itinerary_page.dart';
import '../extras/memory_pages.dart';
import '../extras/recap_page.dart';
import '../shell/home_shell.dart';
import '../travel/travel_mode_page.dart';
import 'trip_detail_page.dart';

/// 5.1 Daftar Trip: Draft, Diadopsi, Berjalan, Selesai.
class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ValueListenableBuilder<TripStatus>(
      valueListenable: tripsTab,
      builder: (context, tab, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
