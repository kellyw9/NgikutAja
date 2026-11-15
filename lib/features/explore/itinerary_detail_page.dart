import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../purchase/purchase_pages.dart';
import '../trips/adopt_page.dart';
import 'creator_profile_page.dart';
import 'reviews_page.dart';

/// Buka itinerary: berbayar dan belum dibeli -> preview, selain itu detail lengkap.
void openItinerary(BuildContext context, Itinerary it) => pushItinerary(Navigator.of(context), AppScope.read(context), it);

/// Rute itinerary diberi nama 'itinerary' supaya alur pembelian bisa kembali ke sini.
void pushItinerary(NavigatorState nav, AppState app, Itinerary it) => nav.push(
  MaterialPageRoute(
    settings: const RouteSettings(name: 'itinerary'),
    builder: (_) => app.canOpen(it) ? ItineraryDetailPage(it: it) : PaidPreviewPage(it: it),
  ),
);

void shareItinerary(Itinerary it) => shareText(
  '${it.title}\n${it.days} hari di ${it.region}, oleh ${it.creator.handle}. Lihat dan adopt rutenya di aplikasi NgikutAja.',
  subject: it.title,
);

/// Kotak statistik kecil: suka, ulasan, komentar.
class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.text, this.filled = false, required this.onTap, required this.label});
  final String icon;
  final String text;
  final bool filled;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(icon, size: 18, filled: filled),
                const SizedBox(width: 6),
                Text(text, style: AppText.bodyStrong),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// 2.2 Detail Itinerary.
class ItineraryDetailPage extends StatefulWidget {
  const ItineraryDetailPage({super.key, required this.it});
  final Itinerary it;

  @override
  State<ItineraryDetailPage> createState() => _ItineraryDetailPageState();
}

class _ItineraryDetailPageState extends State<ItineraryDetailPage> {
  int mapDay = 0;
  int day = 0;
  bool more = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final it = widget.it;
    final dayStops = day < it.plan.length ? it.plan[day] : <Stop>[];
    final mapStops = mapDay < it.plan.length ? it.plan[mapDay].length : 0;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeroPhoto(
              it.cover,
              semantic: 'Foto sampul ${it.title}',
              right: [
                IconBtn('share', label: 'Bagikan', bg: AppColors.surface, size: 40, onTap: () => shareItinerary(it)),
                WishButton(it, onGuest: () => requireLogin(context)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kMargin, 16, kMargin, 0),
              child: Gap(
                14,
                children: [
                  if (it.tags.isNotEmpty) Wrap(spacing: 6, runSpacing: 6, children: [for (final t in it.tags) Pill(t, kind: PillKind.teal)]),
                  Text(it.title, style: AppText.h1),
                  MetaRow([('location_on', it.region)]),
                  FactStrip([
                    ('Durasi', '${it.days} hari'),
                    ('Estimasi per orang', it.estimate != null ? rp(it.estimate!) : 'Belum dihitung'),
                    ('Diadopsi', '${thousands(it.adopted)} kali'),
                  ]),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        icon: 'favorite',
                        filled: app.liked.contains(it.id),
                        text: thousands(it.likes),
                        label: app.liked.contains(it.id) ? 'Batal suka, ${it.likes} suka' : 'Suka, ${it.likes} suka',
                        onTap: () => requireLogin(context) ? app.toggleLike(it) : null,
                      ),
                      if (it.rating != null)
                        _StatChip(
                          icon: 'star',
                          filled: true,
                          text: '${decimal(it.rating!)} (${it.reviews ?? 0} ulasan)',
                          label: 'Rating ${decimal(it.rating!)}, buka ulasan',
                          onTap: () => push(context, ReviewsPage(it: it)),
                        ),
                      _StatChip(
                        icon: 'chat_bubble',
                        text: '${app.commentsOf(it).length}',
                        label: '${app.commentsOf(it).length} komentar, buka komentar',
                        onTap: () => push(context, ReviewsPage(it: it, comments: true)),
                      ),
                    ],
                  ),
                  const NgDivider(),
                  CreatorRow(
                    it.creator,
                    onTap: () => push(context, CreatorProfilePage(c: it.creator)),
                    onGuest: () => requireLogin(context),
                  ),
                  const NgDivider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tentang itinerary ini', style: AppText.h2),
                      const SizedBox(height: 6),
                      Text(
                        it.desc.isEmpty ? 'Creator belum menulis deskripsi.' : it.desc,
                        style: it.desc.isEmpty ? AppText.body.muted : AppText.body,
                        maxLines: more ? null : 4,
                        overflow: more ? null : TextOverflow.ellipsis,
                      ),
                      if (it.desc.length > 160) TextLink(more ? 'Tutup' : 'Selengkapnya', onTap: () => setState(() => more = !more)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHead('Peta dan rute', sub: 'Rute Hari ${mapDay + 1}, urut sesuai jadwal'),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: kMargin),
              child: Row(
                children: [
                  for (var d = 0; d < it.days; d++) ...[
                    if (d > 0) const SizedBox(width: 8),
                    NgChip('Hari ${d + 1}', selected: d == mapDay, onTap: () => setState(() => mapDay = d)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kMargin),
              child: MapView(height: 200, pins: spreadPins(mapStops)),
            ),
            const SizedBox(height: 24),
            const SectionHead('Jadwal per hari'),
            const SizedBox(height: 12),
            DayStrip(
              days: [for (var d = 0; d < it.days; d++) DayItem('Hari ${d + 1}', sub: '${d < it.plan.length ? it.plan[d].length : 0} tempat')],
              active: day,
              onTap: (d) => setState(() => day = d),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kMargin, 12, kMargin, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.dayTitle(day), style: AppText.title),
                  const SizedBox(height: 4),
                  MetaRow([('pin_drop', '${dayStops.length} tempat'), ('payments', rp(it.dayCost(day)))]),
                  const SizedBox(height: 18),
                  if (dayStops.isEmpty)
                    Text('Creator belum menulis jadwal untuk hari ini.', style: AppText.body.muted)
                  else
                    for (var i = 0; i < dayStops.length; i++) StopRow(dayStops[i], n: i + 1, last: i == dayStops.length - 1),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it.isPaid ? rp(it.price) : 'Gratis', style: AppText.h2),
                const SizedBox(height: 2),
                Text('${it.places} tempat dalam ${it.days} hari', style: AppText.small.muted),
              ],
            ),
          ),
          NgButton(
            'Adopt itinerary',
            icon: 'luggage',
            onPressed: () {
              if (requireLogin(context)) push(context, AdoptPage(it: it), fullscreen: true);
            },
          ),
        ],
      ),
    );
  }
}

/// 2.5 Preview Itinerary Berbayar: Hari 1 terbuka, hari lain terkunci.
class PaidPreviewPage extends StatelessWidget {
  const PaidPreviewPage({super.key, required this.it});
  final Itinerary it;

  void _locked(BuildContext context, int d) => showNgSnack(context, 'Hari ${d + 1} terbuka setelah itinerary dibeli.');

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    // Sudah dibeli selagi halaman ini terbuka: ganti ke detail lengkap.
    if (app.canOpen(it)) return ItineraryDetailPage(it: it);
    final day1 = it.plan.isNotEmpty ? it.plan[0] : <Stop>[];
    final day2 = it.plan.length > 1 ? it.plan[1] : <Stop>[];
    final lockedCount = it.places - day1.length;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeroPhoto(
              it.cover,
              height: 240,
              semantic: 'Foto sampul ${it.title}',
              right: [WishButton(it, onGuest: () => requireLogin(context))],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kMargin, 16, kMargin, 0),
              child: Gap(
                14,
                children: [
                  Align(alignment: Alignment.centerLeft, child: PriceTag(rp(it.price))),
                  Text(it.title, style: AppText.h1),
                  MetaRow([('location_on', it.region)]),
                  FactStrip([
                    ('Durasi', '${it.days} hari'),
