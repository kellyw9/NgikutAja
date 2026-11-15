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
