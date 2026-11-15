import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/format.dart';
import '../core/icons.dart';
import '../core/text.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import 'basics.dart';

enum CardVariant { feed, row, grid }

/// Rating + jumlah adopsi. Rating hanya tampil kalau datanya ada.
class Proof extends StatelessWidget {
  const Proof(this.it, {super.key, this.compact = false});
  final Itinerary it;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (it.rating != null) ...[
        const AppIcon('star', size: 16, filled: true),
        const SizedBox(width: 3),
        Text(decimal(it.rating!), style: AppText.smallStrong),
        if (!compact && it.reviews != null) ...[const SizedBox(width: 3), Text('(${it.reviews})', style: AppText.small.muted)],
        const SizedBox(width: 10),
      ],
      Flexible(
        child: Text('${thousands(it.adopted)} adopsi', style: AppText.small.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    ],
  );
}

/// Tombol wishlist. Tamu diarahkan ke sheet login lewat [onGuest].
class WishButton extends StatelessWidget {
  const WishButton(this.it, {super.key, this.boxed = true, this.onGuest});
  final Itinerary it;
  final bool boxed;
  final VoidCallback? onGuest;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final on = app.loggedIn && app.wishlist.contains(it.id);
    return IconBtn(
      'bookmark',
      label: on ? 'Hapus dari Wishlist' : 'Simpan ke Wishlist',
      filled: on,
      bg: boxed ? AppColors.surface : null,
      size: boxed ? 40 : 44,
      iconSize: 22,
      onTap: () {
        if (!app.loggedIn) {
          onGuest?.call();
          return;
        }
        app.toggleWish(it.id);
      },
    );
  }
}

/// Card Wisata, tiga varian berisi data yang sama.
class WisataCard extends StatelessWidget {
  const WisataCard(this.it, {super.key, this.variant = CardVariant.feed, required this.onTap, this.onGuest, this.showWish = true});
  final Itinerary it;
  final CardVariant variant;
  final VoidCallback onTap;
  final VoidCallback? onGuest;
  final bool showWish;

  @override
  Widget build(BuildContext context) {
    final label = '${it.title}, ${it.city}, ${it.days} hari${it.isPaid ? ', ${rp(it.price)}' : ', gratis'}';
    switch (variant) {
      case CardVariant.row:
        return Tap(
          onTap: onTap,
          label: label,
          radius: AppRadius.inner,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Photo(it.cover, width: 88, height: 88, radius: AppRadius.inner),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.title, style: AppText.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      MetaRow([('location_on', it.city), ('schedule', '${it.days} hari')]),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(child: Proof(it, compact: true)),
                          const SizedBox(width: 8),
                          if (it.isPaid) PriceTag(rp(it.price)) else Text('Gratis', style: AppText.smallStrong.c(AppColors.positive)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showWish) WishButton(it, boxed: false, onGuest: onGuest),
              ],
            ),
          ),
        );
      case CardVariant.grid:
        return Tap(
          onTap: onTap,
          label: label,
          radius: AppRadius.inner,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 124,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Photo(it.cover, radius: AppRadius.inner),
                    if (showWish) Positioned(right: 6, top: 6, child: WishButton(it, onGuest: onGuest)),
                    if (it.isPaid) Positioned(left: 6, bottom: 6, child: PriceTag(rp(it.price))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(it.title, style: AppText.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              MetaRow([('location_on', it.city), ('schedule', '${it.days} hari')], gap: 8),
              const SizedBox(height: 8),
              Proof(it, compact: true),
            ],
          ),
        );
      case CardVariant.feed:
        return Tap(
          onTap: onTap,
          label: label,
          radius: AppRadius.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 210,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Photo(it.cover, radius: AppRadius.card),
                    if (it.isPaid) Positioned(left: 10, top: 10, child: PriceTag(rp(it.price))),
                    if (showWish) Positioned(right: 10, top: 10, child: WishButton(it, onGuest: onGuest)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(it.title, style: AppText.h2, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              MetaRow([
                ('location_on', it.city),
                ('schedule', '${it.days} hari'),
                if (it.estimate != null) ('payments', 'Estimasi ${rp(it.estimate!)}'),
              ]),
              const SizedBox(height: 10),
              Row(
                children: [
                  Avatar(it.creator.name, size: 24, tint: it.creator.tint, photo: it.creator.photo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(it.creator.handle, style: AppText.smallStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Proof(it),
                ],
              ),
            ],
          ),
        );
    }
  }
}

/// Dua kolom Card Wisata grid.
class Grid2 extends StatelessWidget {
  const Grid2(this.items, {super.key, required this.onTap, this.onGuest, this.showWish = true});
  final List<Itinerary> items;
  final void Function(Itinerary) onTap;
  final VoidCallback? onGuest;
  final bool showWish;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var r = 0; r < (items.length + 1) ~/ 2; r++) ...[
        if (r > 0) const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: WisataCard(items[r * 2], variant: CardVariant.grid, onTap: () => onTap(items[r * 2]), onGuest: onGuest, showWish: showWish),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: r * 2 + 1 < items.length
                  ? WisataCard(
                      items[r * 2 + 1],
                      variant: CardVariant.grid,
                      onTap: () => onTap(items[r * 2 + 1]),
                      onGuest: onGuest,
                      showWish: showWish,
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ],
    ],
  );
}

PillKind tripPill(TripStatus s) => switch (s) {
  TripStatus.draft => PillKind.warning,
  TripStatus.diadopsi => PillKind.teal,
  TripStatus.berjalan => PillKind.solid,
  TripStatus.selesai => PillKind.positive,
};

/// Card Trip: blok putih bergaris tipis seperti tiket.
class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.status,
    required this.title,
    required this.city,
    required this.days,
    this.dates,
    this.cover,
    this.extra,
    this.onTap,
  });
  final TripStatus status;
  final String title;
  final String city;
  final int days;
  final String? dates;
  final String? cover;
  final Widget? extra;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: AppColors.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Tap(
          onTap: onTap,
          label: '$title, ${status.label}',
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
