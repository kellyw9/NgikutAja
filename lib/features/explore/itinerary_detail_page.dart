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
