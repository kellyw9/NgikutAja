import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 7.1 Split Budget: bagi rata atau kustom (porsi per anggota), lalu siapa transfer ke siapa.
class SplitBudgetPage extends StatefulWidget {
  const SplitBudgetPage({super.key, required this.trip});
  final Trip trip;

  @override
  State<SplitBudgetPage> createState() => _SplitBudgetPageState();
}

class _SplitBudgetPageState extends State<SplitBudgetPage> {
  bool custom = false;
  late final Map<String, int> portion = {for (final m in widget.trip.members) m.first: 1};

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = widget.trip;
    final total = t.expenseTotal;
    final members = t.members;
    final parts = custom ? members.fold<int>(0, (a, m) => a + (portion[m.first] ?? 1)) : members.length;
    int shareOf(Member m) => parts == 0 ? 0 : (total * (custom ? (portion[m.first] ?? 1) : 1) / parts).round();
    int paidBy(Member m) => t.expenses.where((e) => e.by == m.first).fold(0, (a, e) => a + e.amount);
    final net = {for (final m in members) m.first: paidBy(m) - shareOf(m)};

    // Penyelesaian: yang kurang bayar transfer ke yang menerima (greedy).
    final debt = [
      for (final e in net.entries)
        if (e.value < 0) [e.key, -e.value],
    ];
    final cred = [
      for (final e in net.entries)
        if (e.value > 0) [e.key, e.value],
    ];
    final settle = <(String, String, int)>[];
    var di = 0, ci = 0;
    while (di < debt.length && ci < cred.length) {
