import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import 'itinerary_detail_page.dart';

/// 2.4 Profil Creator.
class CreatorProfilePage extends StatefulWidget {
  const CreatorProfilePage({super.key, required this.c});
  final Creator c;

  @override
  State<CreatorProfilePage> createState() => _CreatorProfilePageState();
}

class _CreatorProfilePageState extends State<CreatorProfilePage> {
  bool paidOnly = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = widget.c;
    final all = app.byCreator(c).where((x) => !x.isDraft).toList();
    final list = paidOnly ? all.where((x) => x.isPaid).toList() : all;
    final following = app.isFollowing(c);
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(
        actions: [
          IconBtn('share', label: 'Bagikan profil', onTap: () => shareText('${c.name} (${c.handle}) menulis ${all.length} itinerary di NgikutAja.')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ProfileHead(
            p: c,
            itins: all.length,
            action: c == app.me
                ? const SizedBox()
                : NgButton(
                    following ? 'Mengikuti' : 'Ikuti',
                    kind: following ? BtnKind.ghost : BtnKind.primary,
                    size: BtnSize.md,
                    expand: true,
                    icon: following ? 'check' : null,
                    onPressed: () => requireLogin(context) ? app.toggleFollow(c) : null,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(kMargin, 20, kMargin, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Itinerary', style: AppText.h2)),
                    NgChip('Semua', selected: !paidOnly, onTap: () => setState(() => paidOnly = false)),
                    const SizedBox(width: 8),
                    NgChip('Berbayar', selected: paidOnly, onTap: () => setState(() => paidOnly = true)),
                  ],
                ),
                const SizedBox(height: 14),
                if (list.isEmpty)
                  const EmptyState(
                    icon: 'map',
