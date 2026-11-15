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

class _AdoptPageState extends State<AdoptPage> {
  late DateTime start = AppScope.read(context).today.add(const Duration(days: 7));
  bool dayBefore = true;
  bool each = true;
  int offset = 30;
  bool offline = true;

  Future<void> _adopt() async {
    final it = widget.it;
    final end = start.add(Duration(days: it.days - 1));
    final r = await showNgDialog(
      context,
      icon: 'luggage',
      title: 'Adopt itinerary ini?',
