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
    final app = AppScope.of(context);
    final list = widget.followers ? app.seed.followers : app.seed.followingPeople;
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(
        title: widget.followers ? 'Pengikut' : 'Mengikuti',
        sub: widget.followers ? '${app.me.followers} pengikut' : '${app.me.following} mengikuti',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (var i = 0; i < list.length; i++) ...[
            if (i > 0) const NgDivider(inset: kMargin + 52),
            SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kMargin),
                child: Row(
                  children: [
                    Avatar(list[i].name, size: 40, tint: list[i].tint),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(list[i].name, style: AppText.bodyStrong),
                          const SizedBox(height: 2),
