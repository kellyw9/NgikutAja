import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/text.dart';

/// Logo teks "NgikutAja": "Ngikut" mengikuti [mainColor], "Aja" selalu kuning.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 28, this.mainColor = AppColors.ink});

  final double size;
  final Color mainColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'NgikutAja',
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            style: AppText.wordmark.copyWith(
              fontSize: size,
              height: 1.2,
              letterSpacing: size * -0.02,
              color: mainColor,
            ),
            children: const [
              TextSpan(text: 'Ngikut'),
              TextSpan(text: 'Aja', style: TextStyle(color: AppColors.yellow)),
            ],
          ),
        ),
      ),
    );
  }
}