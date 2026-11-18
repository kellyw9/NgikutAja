import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/icons.dart';

/// Gambar dari asset. Kalau file asset belum ada, tampil gradient + ikon pengganti.
class AssetImageBox extends StatelessWidget {
  const AssetImageBox({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.radius = const BorderRadius.all(Radius.circular(AppRadius.dialog)),
    this.fallbackIcon = 'landscape',
  });

  final String asset;
  final double? width;
  final double? height;
  final BorderRadius radius;
  final String fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.mapWater, AppColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppIcon(fallbackIcon, size: 32, color: AppColors.white),
        ),
      ),
    );
  }
}