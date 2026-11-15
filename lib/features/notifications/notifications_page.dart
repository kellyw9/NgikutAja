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
    switch (n.kind) {
      case NotifKind.reminder:
        push(context, NotificationDetailPage(n: n));
      case NotifKind.payment:
        final tx = app.transactions.where((t) => t.item.id == 'bali').firstOrNull;
        if (tx != null) push(context, TransactionDetailPage(tx: tx));
      case NotifKind.departure:
        if (toba != null) push(context, TripDetailPage(trip: toba));
