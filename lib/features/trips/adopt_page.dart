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
      body: '${it.places} tempat akan disalin ke Trip Saya untuk ${dateRange(start, end)}. Kamu bisa mengubahnya kapan saja.',
      actions: const [
        DialogAction('Adopt sekarang', kind: BtnKind.primary, value: true),
        DialogAction('Batal'),
      ],
    );
    if (r != true || !mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdoptProgressPage(it: it, start: start, dayBefore: dayBefore, each: each, offset: offset, offline: offline),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final it = widget.it;
    final end = start.add(Duration(days: it.days - 1));
    final before = start.subtract(const Duration(days: 1));
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const NgAppBar(title: 'Adopt ke Trip Saya', back: 'close'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
        children: [
          Gap(
            16,
            children: [
