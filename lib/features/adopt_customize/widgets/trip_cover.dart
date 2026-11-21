import 'package:flutter/material.dart';

import 'ng_widgets.dart';

/// Sampul trip. Bisa URL internet atau path file lokal (setelah "Ganti foto
/// sampul"). Jika kosong/gagal, tampil placeholder "Tanpa foto" (desain).
class TripCover extends StatelessWidget {
  const TripCover({
    super.key,
    required this.url,
    this.height = 160,
    this.width = double.infinity,
    this.radius = 0,
  });

  final String? url;
  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return NgImage(source: url, width: width, height: height, radius: radius);
  }
}