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
