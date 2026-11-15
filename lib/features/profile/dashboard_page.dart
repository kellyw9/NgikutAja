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
    final monthly = Seed.monthly;
    final maxN = monthly.fold<int>(1, (a, m) => m.$2 > a ? m.$2 : a);

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const NgAppBar(title: 'Creator dashboard', sub: 'Juli sampai November 2026'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
        children: [
          Gap(
            16,
            children: [
              FactStrip([
                ('Itinerary terbit', '${mine.length}'),
                ('Total adopsi', thousands(app.totalAdopt)),
                ('Pendapatan simulasi', rp(app.revenue)),
              ]),
              if (chartItem != null)
                NgCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Penjualan bulanan', style: AppText.title),
                      const SizedBox(height: 2),
                      Text('${chartItem.title}, ${rp(chartItem.price)} per transaksi', style: AppText.small.muted),
