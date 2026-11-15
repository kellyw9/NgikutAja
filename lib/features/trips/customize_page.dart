import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import 'schedule_logic.dart';
import 'trip_forms.dart';

export 'trip_forms.dart';

/// 5.4 Customize Trip, termasuk 5.6 pindahkan, 5.7 tambah hari, 5.9 catatan jadwal, 5.10 status simpan.
class CustomizePage extends StatefulWidget {
  const CustomizePage({super.key, required this.trip, this.initialDay = 0});
  final Trip trip;
  final int initialDay;
