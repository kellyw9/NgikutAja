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
