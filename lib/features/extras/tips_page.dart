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
