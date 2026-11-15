import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../explore/itinerary_detail_page.dart';
import '../shell/home_shell.dart';

/// 9.5 Wishlist (+ dihapus dengan Urungkan, + kosong).
class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final list = app.itineraries.where((x) => app.wishlist.contains(x.id)).toList();
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(title: 'Wishlist', sub: list.isEmpty ? null : '${list.length} itinerary tersimpan'),
      body: list.isEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
              child: EmptyState(
                icon: 'bookmark',
                title: 'Wishlist masih kosong',
                text: 'Tekan ikon bookmark pada Card Wisata untuk menyimpan itinerary yang ingin kamu jalani nanti.',
                action: NgButton('Cari itinerary', kind: BtnKind.secondary, size: BtnSize.md, onPressed: () => goTab(context, tabSearch)),
                height: 280,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
              children: [
                for (var i = 0; i < list.length; i++) ...[if (i > 0) const NgDivider(), _Row(list[i])],
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.it);
  final Itinerary it;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Tap(
      onTap: () => openItinerary(context, it),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Photo(it.cover, width: 88, height: 88, radius: AppRadius.inner),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.title, style: AppText.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  MetaRow([('location_on', it.city), ('schedule', '${it.days} hari')]),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: Proof(it, compact: true)),
                      const SizedBox(width: 8),
                      if (it.isPaid) PriceTag(rp(it.price)) else Text('Gratis', style: AppText.smallStrong.c(AppColors.positive)),
                    ],
                  ),
                ],
              ),
