import 'package:flutter/material.dart';

class TravelColors {
  static const background = Color(0xFFF6E7D6);
  static const primary = Color(0xFF0F4C5C);
  static const muted = Color(0xFF6B6B6B);
  static const done = Color(0xFF2E9E6B);

  static Color categoryColor(String? category) {
    switch (category) {
      case 'Makan':
        return const Color(0xFFF9D9A6);
      case 'Budaya':
        return const Color(0xFFF3C9C0);
      case 'Alam':
        return const Color(0xFFCDE8CF);
      case 'Sosial':
        return const Color(0xFFD5DDF5);
      default:
        return const Color(0xFFE6E0D8);
    }
  }
}

String formatRupiah(double? value) {
  if (value == null || value == 0) return 'Gratis';
  final s = value.toInt().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp$buf';
}