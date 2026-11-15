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
