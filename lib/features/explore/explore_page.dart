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
