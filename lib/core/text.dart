import 'package:flutter/widgets.dart';

import 'colors.dart';

/// Skala tipografi Plus Jakarta Sans. Letter spacing di desain dalam persen,
/// di sini sudah dikonversi ke piksel (persen x ukuran / 100).
class AppText {
  AppText._();

  static const family = 'PlusJakartaSans';

  static TextStyle _s(double size, double lh, FontWeight w, double lsPercent) => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: lh / size,
    fontWeight: w,
    letterSpacing: size * lsPercent / 100,
    color: AppColors.ink,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static final display = _s(30, 36, FontWeight.w700, -2);
  static final h1 = _s(22, 28, FontWeight.w700, -1);
  static final h2 = _s(18, 24, FontWeight.w700, -1);
