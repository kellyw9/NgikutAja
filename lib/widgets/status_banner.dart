import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/icons.dart';
import '../core/text.dart';

/// Banner status: merah untuk error, hijau untuk sukses.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.title,
    required this.message,
    this.isError = true,
  });

  final String title;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final accent = isError ? AppColors.negative : AppColors.positive;
    final ink = isError ? AppColors.negativeInk : AppColors.positiveInk;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isError ? AppColors.negativePale : AppColors.positivePale,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcon(isError ? 'error' : 'check_circle', size: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.smallStrong.c(ink)),
                  const SizedBox(height: 2),
                  Text(message, style: AppText.small.c(ink)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}