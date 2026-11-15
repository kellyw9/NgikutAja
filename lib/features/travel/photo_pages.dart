import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 6.6 Tambah foto perjalanan: sheet kamera/galeri, lalu pratinjau.
Future<void> addTripPhoto(BuildContext context, Trip trip, int day) async {
  final p = await pickPhotoSheet(context, title: 'Tambah foto perjalanan');
