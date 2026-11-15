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
                  ],
                ),
              ),
              Text('Tipe publikasi', style: AppText.h2),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    typeCard(false, 'Gratis', 'Bebas diadopsi siapa saja secara cuma-cuma.'),
                    const SizedBox(width: 12),
                    typeCard(true, 'Berbayar', 'Hari 1 terlihat gratis. Hari lain terbuka setelah dibeli.'),
                  ],
                ),
              ),
              if (paid)
                NgCard(
                  child: NgField(
                    label: 'Harga adopsi',
                    controller: price,
                    prefixText: 'Rp',
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsFormatter()],
                    onChanged: (_) => setState(() {}),
                    helper: 'Pembayaran masih simulasi, belum ada dana riil.',
                    error: parseRupiah(price.text) < 5000 ? 'Harga minimal Rp5.000' : null,
                  ),
                ),
              Text('Kesiapan itinerary', style: AppText.h2),
              BoxList(
                inset: 14,
                children: [
                  for (final (label, ok) in checks)
                    SizedBox(
                      height: 52,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            IconTile(
                              ok ? 'check' : 'close',
                              size: 28,
                              iconSize: 18,
                              fill: ok ? AppColors.positivePale : AppColors.negativePale,
                              color: ok ? AppColors.positiveInk : AppColors.negativeInk,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(label, style: AppText.body)),
                            Text(ok ? 'Selesai' : 'Belum', style: AppText.smallStrong.c(ok ? AppColors.positive : AppColors.negative)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
          child: Gap(
            12,
            children: [
              NgButton(
                'Publish sekarang',
                trailingIcon: 'arrow_forward',
                expand: true,
                onPressed: ready
                    ? () {
                        _apply();
                        app.publish(d);
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => PublishedPage(d: d)), (r) => r.isFirst);
                      }
                    : null,
              ),
              NgButton(
                'Simpan sebagai draft',
                kind: BtnKind.secondary,
                expand: true,
                onPressed: () {
                  _apply();
                  saveDraftAndClose(context, d);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Langkah 6: Berhasil Publish.
class PublishedPage extends StatelessWidget {
  const PublishedPage({super.key, required this.d});
  final Itinerary d;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const NgAppBar(back: null, actions: [_CloseBtn()]),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 24),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    const Center(
                      child: IconTile('check', size: 72, iconSize: 36, fill: AppColors.positivePale, color: AppColors.positiveInk),
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      liveRegion: true,
                      child: Text('Itinerary berhasil dipublish!', style: AppText.h1, textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 8),
