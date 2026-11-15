import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 7.3 Local Tips.
class TipsPage extends StatelessWidget {
  const TipsPage({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final tips = app.seed.tips[trip.city] ?? const <LocalTip>[];
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(title: 'Local tips', sub: trip.city == 'Samosir' ? 'Samosir dan Danau Toba' : trip.city),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
        children: [
          if (tips.isEmpty)
            EmptyState(icon: 'lightbulb', title: 'Belum ada tips untuk ${trip.city}', text: 'Tips dari creator dan komunitas akan muncul di sini.')
          else ...[
            for (final tip in tips) ...[
              NgCard(
                padding: const EdgeInsets.all(12),
                onTap: () => push(context, TipDetailPage(tip: tip)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppIcon(tip.icon, size: 22, color: AppColors.muted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tip.title, style: AppText.title),
                          const SizedBox(height: 2),
                          Text(tip.text, style: AppText.body.muted, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const AppIcon('chevron_right', size: 20, color: AppColors.muted),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            Text('Tips ditulis oleh creator itinerary dan anggota komunitas yang pernah berkunjung.', style: AppText.small.muted),
          ],
        ],
      ),
    );
  }
}

class TipDetailPage extends StatelessWidget {
  const TipDetailPage({super.key, required this.tip});
  final LocalTip tip;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.ground,
    appBar: const NgAppBar(),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 16),
      children: [
        Gap(
          14,
          children: [
            Text(tip.title, style: AppText.h1),
            if (tip.author != null)
              Row(
