import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import 'memory_pages.dart';

/// 7.6 Trip Recap.
class RecapPage extends StatelessWidget {
  const RecapPage({super.key, required this.trip});
  final Trip trip;

  String _summary(Trip t) =>
      'Recap trip "${t.title}" (${t.dates ?? ''}): ${t.visited()} dari ${t.places()} tempat dikunjungi, '
      'total pengeluaran ${rp(t.spending())}, ${t.photos.length} foto memori. Dicatat dengan NgikutAja.';

  @override
  Widget build(BuildContext context) {
    final t = trip;
    final names = [
      for (final d in t.plan)
        for (final s in d) s.name,
    ];
    final others = t.places() - names.length;
    final pins = spreadPins((t.visited()).clamp(0, 4), states: List.filled(4, MarkerState.done));
    final photos = t.photos;
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(
        title: 'Trip recap',
