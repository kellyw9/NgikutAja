import 'package:flutter/material.dart';

import '../../data/seed.dart';
import '../../widgets/ui.dart';
import '../explore/itinerary_detail_page.dart';

/// 9.6 Creator Dashboard. Semua angka pendapatan berasal dari pembayaran simulasi.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final mine = app.mine;
    final top = mine.where((x) => x.isPaid).toList()..sort((a, b) => app.salesOf(b).compareTo(app.salesOf(a)));
    final chartItem = top.firstOrNull;
