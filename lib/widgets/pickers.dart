import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/format.dart';
import '../core/icons.dart';
import '../core/nav.dart';
import '../core/text.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../data/services.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import 'basics.dart';
import 'feedback.dart';
import 'inputs.dart';
import 'layout.dart';

/// Pilih tanggal keberangkatan. Rentang [days] hari ikut ditandai.
Future<DateTime?> pickDate(BuildContext context, {required DateTime initial, int days = 1, String title = 'Tanggal keberangkatan', DateTime? first}) {
  return showNgSheet<DateTime>(
    context,
    title: title,
    scroll: true,
    builder: (_) => _Calendar(initial: initial, days: days, first: first ?? AppScope.read(context).today),
  );
}

class _Calendar extends StatefulWidget {
  const _Calendar({required this.initial, required this.days, required this.first});
  final DateTime initial;
  final int days;
  final DateTime first;

  @override
  State<_Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<_Calendar> {
  late DateTime sel = widget.initial;
  late DateTime month = DateTime(widget.initial.year, widget.initial.month);

  @override
  Widget build(BuildContext context) {
    final lead = DateTime(month.year, month.month, 1).weekday - 1; // Senin = 0
    final count = DateUtils.getDaysInMonth(month.year, month.month);
