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
