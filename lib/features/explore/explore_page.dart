import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../notifications/notifications_page.dart';
import '../search/search_page.dart';
import '../shell/home_shell.dart';
import 'itinerary_detail_page.dart';

/// 2.1 Explore / Feed.
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String tab = 'Trending';
  bool loading = true;
  Object? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await AppScope.read(context).loadFeed();
    } catch (e) {
      error = e;
    }
    if (mounted) setState(() => loading = false);
  }

  void _switch(String t) {
    if (t == tab) return;
    setState(() => tab = t);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = switch (tab) {
      'Terbaru' => app.latest().where((x) => x.creator != app.me).toList(),
      'Following' => app.fromFollowing(),
      _ => app.trending(),
    };

    Widget feed() {
      if (loading) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: kMargin),
          child: Column(children: [SkeletonCard(), SizedBox(height: 20), NgDivider(), SizedBox(height: 20), SkeletonCard()]),
        );
      }
      if (error != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: kMargin),
          child: ErrorBlock('Feed Explore tidak bisa dimuat. Tarik ke bawah atau coba lagi.', onRetry: _load),
        );
      }
      if (items.isEmpty && tab == 'Following') {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: kMargin),
          child: EmptyState(
            icon: 'person_add',
            title: 'Belum mengikuti creator',
            text: 'Ikuti creator dari halaman itinerary. Itinerary terbaru mereka akan muncul di sini.',
            action: NgButton('Lihat yang trending', kind: BtnKind.secondary, size: BtnSize.md, onPressed: () => _switch('Trending')),
            height: 300,
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: kMargin),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: NgDivider()),
              WisataCard(items[i], onTap: () => openItinerary(context, items[i]), onGuest: () => requireLogin(context)),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        TabHeader('Explore', actions: [Bell(onTap: () => push(context, const NotificationsPage()))]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kMargin),
          child: Segmented(items: const ['Trending', 'Terbaru', 'Following'], active: tab, onChanged: _switch),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.ink,
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              children: [
                if (tab == 'Trending' && !loading) ...[
                  SectionHead('Kota populer', action: 'Lihat semua', onAction: () => goSearch(context, '')),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: kMargin),
                      itemCount: AppState.cities.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => CityCard(AppState.cities[i]),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                feed(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CityCard extends StatelessWidget {
  const CityCard(this.c, {super.key});
  final CityInfo c;

  @override
  Widget build(BuildContext context) {
    final n = AppScope.of(context).cityCount(c);
    return SizedBox(
      width: 124,
      child: Tap(
        onTap: () => goSearch(context, c.name),
        radius: AppRadius.card,
        label: '${c.name}, $n itinerary',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Photo(c.photo, width: 124, height: 140, radius: AppRadius.card),
            const SizedBox(height: 6),
            Text(c.name, style: AppText.bodyStrong),
