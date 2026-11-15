import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import 'checkin_page.dart';
import 'expenses_page.dart';
import 'photo_pages.dart';

/// Jarak dan waktu tempuh dari data contoh (belum ada layanan rute).
const travelInfo = {'Bukit Holbung': ('6,4 km', '18 menit', 'Naik motor')};

/// 6.1 Travel Mode (dan 6.7 saat offline).
class TravelModePage extends StatelessWidget {
  const TravelModePage({super.key, required this.trip});
  final Trip trip;
