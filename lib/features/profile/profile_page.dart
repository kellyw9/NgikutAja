import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../explore/creator_profile_page.dart';
import '../explore/itinerary_detail_page.dart';
import '../purchase/purchase_pages.dart';
import 'dashboard_page.dart';
import 'edit_profile_page.dart';
import 'people_page.dart';
import 'settings_page.dart';
import 'wishlist_page.dart';

/// 9.1 Profil Saya (tab).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final mine = app.mine;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
