import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../extras/split_budget_page.dart';

String expenseTime(Trip t, Expense e) {
  final d = t.dayDate(e.day);
  return d == null
      ? 'Hari ${e.day + 1} pukul ${e.time}'
      : 'Hari ${e.day + 1}, ${weekdaysLong[d.weekday - 1]} ${d.day} ${monthsShort[d.month - 1]} pukul ${e.time}';
}

/// 6.5 Pengeluaran: daftar + detail.
class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key, required this.trip});
  final Trip trip;

  void _detail(BuildContext context, Expense e) {
    final app = AppScope.read(context);
    final n = trip.members.length;
    showNgSheet<void>(
      context,
      title: e.name,
      builder: (ctx) => Gap(
        16,
