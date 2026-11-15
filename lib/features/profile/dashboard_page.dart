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
                      const SizedBox(height: 10),
                      Semantics(
                        label: 'Grafik penjualan: ${monthly.map((m) => '${m.$1} ${m.$2}').join(', ')}',
                        child: ExcludeSemantics(
                          child: SizedBox(
                            height: 170,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (var i = 0; i < monthly.length; i++) ...[
                                  if (i > 0) const Spacer(),
                                  SizedBox(
                                    width: 36,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('${monthly[i].$2}', style: AppText.smallStrong),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 106 * monthly[i].$2 / maxN,
                                          decoration: BoxDecoration(
                                            // Bulan berjalan memakai warna sunk: datanya belum lengkap.
                                            color: i == monthly.length - 1 ? AppColors.sunk : AppColors.teal,
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                          ),
                                        ),
                                        Container(height: 1, color: AppColors.line),
                                        const SizedBox(height: 4),
                                        Text(monthly[i].$1, style: AppText.small.muted),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Bulan November baru berjalan, datanya belum lengkap.', style: AppText.small.muted),
                    ],
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Itinerary yang kamu kelola', style: AppText.h2),
                  const SizedBox(height: 8),
                  if (mine.isEmpty)
                    Text('Belum ada itinerary yang terbit.', style: AppText.body.muted)
                  else
                    BoxList(
                      inset: 78,
                      children: [
                        for (final x in mine)
                          Tap(
                            onTap: () => openItinerary(context, x),
                            child: SizedBox(
                              height: 76,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  children: [
                                    Photo(x.cover, width: 52, height: 52, radius: AppRadius.inner),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(x.title, style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 2),
                                          Text('${x.adopted} adopsi, ${x.isPaid ? rp(x.price) : 'Gratis'}', style: AppText.small.muted),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(rp(x.price * app.salesOf(x)), style: AppText.bodyStrong),
                                  ],
                                ),
