import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/text.dart';

class SegmentProgress extends StatelessWidget {
  const SegmentProgress({super.key, required this.current, required this.total});

  final int current; // 0-based
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Container(
          width: 22,
          height: 4,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: i <= current ? AppColors.teal : AppColors.rule,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

/// Baris atas onboarding: progress di kiri, "Lewati" di kanan.
class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({super.key, required this.current, required this.onSkip});

  final int current;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SegmentProgress(current: current, total: 3),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSkip,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text('Lewati', style: AppText.small.muted),
          ),
        ),
      ],
    );
  }
}