import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../explore/itinerary_detail_page.dart';
import '../trips/schedule_logic.dart';
import 'create_itinerary_page.dart';

/// Langkah 5: Publish Itinerary.
class PublishPage extends StatefulWidget {
  const PublishPage({super.key, required this.d});
  final Itinerary d;

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  late final d = widget.d;
  late bool paid = d.price > 0;
  late final price = TextEditingController(text: thousands(d.price > 0 ? d.price : 25000));

  @override
  void dispose() {
    price.dispose();
    super.dispose();
  }

  void _apply() => d.price = paid ? parseRupiah(price.text) : 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final checks = [
      ('Judul terisi', d.title.trim().isNotEmpty),
      ('Semua hari memiliki stop', d.plan.every((x) => x.isNotEmpty)),
      ('Jam tidak bentrok', d.plan.every((x) => conflictsIn(x).isEmpty)),
      if (paid) ('Harga minimal Rp5.000', parseRupiah(price.text) >= 5000),
    ];
    final ready = checks.every((c) => c.$2);
    final total = d.plan.fold<int>(0, (a, x) => a + x.fold(0, (b, s) => b + s.cost));

    Widget typeCard(bool isPaid, String title, String text) {
      final on = paid == isPaid;
      return Expanded(
        child: Semantics(
          inMutuallyExclusiveGroup: true,
          checked: on,
          child: NgCard(
            padding: const EdgeInsets.all(14),
            border: on ? AppColors.teal : AppColors.line,
            borderWidth: on ? 2 : 1,
            onTap: () => setState(() => paid = isPaid),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: AppText.bodyStrong)),
                    AppIcon(on ? 'check_circle' : 'radio_button_unchecked', size: 22, filled: on, color: on ? AppColors.teal : AppColors.muted),
                  ],
                ),
                const SizedBox(height: 6),
                Text(text, style: AppText.small.muted),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const NgAppBar(title: 'Publish itinerary'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
        children: [
          Gap(
            16,
            children: [
              NgCard(
                child: Row(
                  children: [
                    Photo(d.cover, width: 80, height: 80, radius: AppRadius.card),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.title, style: AppText.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Meta('person', '${app.me.name} (${app.me.handle})'),
                          const SizedBox(height: 6),
                          MetaRow([('schedule', '${d.plan.length} hari'), ('pin_drop', '${d.stopCount} stop'), ('payments', rp(total))]),
                        ],
                      ),
                    ),
