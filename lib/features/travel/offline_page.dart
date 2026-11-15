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
