import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 6.7 Pengelolaan Offline.
class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  String _now() {
    final n = DateTime.now();
    return fromMinutes(n.hour * 60 + n.minute);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final trips = app.trips.where((t) => app.statusOf(t) != TripStatus.selesai).toList();

    Widget avail(bool ok, String text) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          AppIcon(ok ? 'check_circle' : 'cloud_off', size: 18, color: ok ? AppColors.positive : AppColors.muted, filled: ok),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppText.body)),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const NgAppBar(title: 'Data offline'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
        children: [
          Gap(
            16,
            children: [
              for (final t in trips)
                NgCard(
                  child: Row(
                    children: [
                      AppIcon(t.offline ? 'cloud_done' : 'download_for_offline', size: 22, color: t.offline ? AppColors.positive : AppColors.muted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.title, style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(
                              t.offline ? 'Tersimpan offline (${t.offlineSize} MB), sinkronisasi pukul ${t.syncedAt}' : 'Belum diunduh',
                              style: AppText.small.muted,
                            ),
                          ],
                        ),
                      ),
                      NgToggle(
                        t.offline,
                        label: 'Simpan ${t.title} untuk offline',
                        onChanged: (v) {
                          if (v && !app.online) {
                            showNgSnack(context, 'Butuh internet untuk mengunduh data trip.', kind: SnackKind.error);
                            return;
                          }
                          t
                            ..offline = v
                            ..offlineSize = v ? 6 + t.places() : 0
                            ..syncedAt = v ? _now() : null;
                          app.touch();
                        },
                      ),
                    ],
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bisa dibuka tanpa sinyal', style: AppText.h2),
                  avail(true, 'Jadwal, jam, dan urutan tempat'),
                  avail(true, 'Catatan creator dan foto tempat'),
                  avail(true, 'Pengeluaran dan packing list'),
                  avail(true, 'Check-in (disimpan dulu di HP)'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Membutuhkan internet', style: AppText.h2),
                  avail(false, 'Peta langsung dan navigasi Google Maps'),
                  avail(false, 'Komentar dan undangan anggota baru'),
                ],
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 16),
          child: NgButton(
            'Perbarui data offline',
            kind: BtnKind.secondary,
            icon: 'sync',
            expand: true,
            onPressed: () {
              if (!app.online) {
                showNgSnack(context, 'Kamu sedang offline. Coba lagi saat ada sinyal.', kind: SnackKind.error);
                return;
              }
              final saved = trips.where((t) => t.offline).toList();
              for (final t in saved) {
                t.syncedAt = _now();
              }
              app.touch();
              showNgSnack(
                context,
                saved.isEmpty ? 'Belum ada trip yang disimpan offline.' : 'Data offline diperbarui.',
                kind: saved.isEmpty ? SnackKind.neutral : SnackKind.success,
              );
