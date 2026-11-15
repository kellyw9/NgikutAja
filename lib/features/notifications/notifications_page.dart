import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../explore/itinerary_detail_page.dart';
import '../explore/reviews_page.dart';
import '../purchase/purchase_pages.dart';
import '../trips/trip_detail_page.dart';
import '../travel/travel_mode_page.dart';

/// 10.1 Daftar Notifikasi.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  void _open(BuildContext context, AppState app, AppNotification n) {
    app.markRead(n);
    final toba = app.trips.where((t) => t.id == 'toba-kampus').firstOrNull;
