import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../shell/home_shell.dart';
import 'customize_page.dart';
import 'trip_detail_page.dart';

/// 5.2 Adopt Itinerary: tanggal, pengingat, simpan offline.
class AdoptPage extends StatefulWidget {
  const AdoptPage({super.key, required this.it});
  final Itinerary it;

  @override
  State<AdoptPage> createState() => _AdoptPageState();
}
