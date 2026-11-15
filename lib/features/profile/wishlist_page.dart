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
