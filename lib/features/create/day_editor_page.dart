import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../trips/schedule_logic.dart';
import 'add_stop_page.dart';
import 'create_itinerary_page.dart';
import 'publish_page.dart';

/// Langkah 2: Editor Hari & Stop (+ state error: jam bentrok, hari tanpa stop).
class DayEditorPage extends StatefulWidget {
  const DayEditorPage({super.key, required this.d});
  final Itinerary d;

  @override
  State<DayEditorPage> createState() => _DayEditorPageState();
}

class _DayEditorPageState extends State<DayEditorPage> {
  late final d = widget.d;
  int day = 0;
  late final dayTitle = TextEditingController(text: _title(0));

  String _title(int k) => k < d.dayTitles.length ? d.dayTitles[k] : '';

  void _selectDay(int k) {
    _saveTitle();
    setState(() {
      day = k;
