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
