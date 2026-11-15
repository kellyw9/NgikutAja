import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 9.3 Daftar Follower dan 9.4 Daftar Following.
class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key, required this.followers});
  final bool followers;

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  // Yang saling mengikuti (dari data contoh) dan perubahan selama sesi ini.
  final Set<String> following = {'@kevintbn', '@sarilubis', '@yohanapdd'};

  @override
  void initState() {
    super.initState();
    if (!widget.followers) {
      following.addAll(AppScope.read(context).seed.followingPeople.map((p) => p.handle));
    }
  }

  @override
  Widget build(BuildContext context) {
