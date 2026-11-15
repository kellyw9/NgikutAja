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
      case NotifKind.like:
        openItinerary(context, app.itinerary('samosirmotor'));
      case NotifKind.comment:
        push(context, ReviewsPage(it: app.itinerary('samosirmotor'), comments: true));
      case NotifKind.invite:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final today = app.notifications.where((n) => n.today).toList();
    final older = app.notifications.where((n) => !n.today).toList();
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(
        title: 'Notifikasi',
        actions: [NgButton('Tandai dibaca', kind: BtnKind.text, size: BtnSize.md, onPressed: app.hasUnread ? app.markAllRead : null)],
      ),
      body: app.notifications.isEmpty
          ? const EmptyState(
              icon: 'notifications',
              title: 'Belum ada notifikasi',
              text: 'Pengingat trip, undangan, dan status pembayaran muncul di sini.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (today.isNotEmpty) ...[_group('Hari ini'), for (final n in today) _row(context, app, n)],
                if (older.isNotEmpty) ...[_group('Kemarin'), for (final n in older) _row(context, app, n)],
              ],
            ),
    );
  }

  Widget _group(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(kMargin, 14, kMargin, 6),
    child: Text(t, style: AppText.smallStrong.muted),
  );

  Widget _row(BuildContext context, AppState app, AppNotification n) {
    final invite = n.kind == NotifKind.invite;
    return Material(
      color: n.unread ? AppColors.surface : Colors.transparent,
      child: InkWell(
        onTap: invite ? (n.unread ? () => app.markRead(n) : null) : () => _open(context, app, n),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kMargin, 12, kMargin, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(n.icon, size: 36, iconSize: 20, fill: n.unread ? AppColors.sunk : AppColors.surface, border: AppColors.line),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: AppText.body,
                        children: [
                          TextSpan(text: n.lead, style: AppText.bodyStrong),
                          TextSpan(text: n.text),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(n.time, style: AppText.small.muted),
                    if (invite) ...[
                      const SizedBox(height: 8),
                      if (n.inviteState == null)
                        Row(
                          children: [
                            NgButton(
                              'Terima',
                              size: BtnSize.md,
                              onPressed: () {
                                app.answerInvite(n, true);
                                showNgSnack(context, 'Undangan diterima. Trip muncul setelah pemilik menyimpan anggotanya.', kind: SnackKind.success);
                              },
                            ),
                            const SizedBox(width: 8),
                            NgButton('Tolak', kind: BtnKind.secondary, size: BtnSize.md, onPressed: () => app.answerInvite(n, false)),
                          ],
                        )
                      else
                        Pill(n.inviteState!, kind: n.inviteState == 'Diterima' ? PillKind.positive : PillKind.neutral),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: n.unread
                    ? Semantics(
                        label: 'Belum dibaca',
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.negative, shape: BoxShape.circle),
                        ),
                      )
                    : const SizedBox(width: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 10.2 Detail Notifikasi (pengingat aktivitas).
class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({super.key, required this.n});
  final AppNotification n;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final trip = app.runningTrip;
    final day = trip == null ? 0 : app.currentDay(trip);
    final idx = trip == null ? null : app.nextIndex(trip, day);
    final st = trip != null && idx != null ? trip.plan[day][idx] : null;
    final info = st == null ? null : travelInfo[st.name];
    final date = app.today;
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const NgAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 16),
        children: [
          Gap(
            14,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: IconTile('alarm', size: 44, fill: AppColors.surface, iconSize: 24, border: AppColors.line),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(st == null ? 'Pengingat aktivitas' : '30 menit lagi: ${st.name}', style: AppText.h1),
                  const SizedBox(height: 4),
                  Text(
