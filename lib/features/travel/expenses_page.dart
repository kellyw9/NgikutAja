import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../extras/split_budget_page.dart';

String expenseTime(Trip t, Expense e) {
  final d = t.dayDate(e.day);
  return d == null
      ? 'Hari ${e.day + 1} pukul ${e.time}'
