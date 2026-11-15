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
        TabHeader(
          'Profil',
          actions: [IconBtn('settings', label: 'Pengaturan', onTap: () => push(context, const SettingsPage()))],
        ),
        ProfileHead(
          p: app.me,
          itins: mine.length,
          onFollowers: () => push(context, const PeoplePage(followers: true)),
          onFollowing: () => push(context, const PeoplePage(followers: false)),
          action: NgButton(
            'Edit profil',
            kind: BtnKind.secondary,
            size: BtnSize.md,
            icon: 'edit',
            expand: true,
            onPressed: () => push(context, const EditProfilePage(), fullscreen: true),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(kMargin, 16, kMargin, 0),
          child: BoxList(
            children: [
              ListRow(
                icon: 'bookmark',
                title: 'Wishlist',
                sub: '${app.wishlist.length} itinerary tersimpan',
                onTap: () => push(context, const WishlistPage()),
              ),
              ListRow(
                icon: 'bar_chart',
                title: 'Creator dashboard',
                sub: 'Pendapatan ${rp(app.revenue)} (simulasi)',
                onTap: () => push(context, const DashboardPage()),
              ),
              ListRow(
                icon: 'receipt_long',
