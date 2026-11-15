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
