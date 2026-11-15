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
