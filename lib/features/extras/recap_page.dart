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
        actions: [IconBtn('share', label: 'Bagikan recap', onTap: () => shareText(_summary(t)))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
        children: [
          Gap(
            16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title, style: AppText.h1),
                  const SizedBox(height: 4),
                  MetaRow([('calendar_month', t.dates ?? 'Tanggal belum diatur'), ('schedule', '${t.days} hari')]),
                ],
              ),
              FactStrip([
                ('Tempat dikunjungi', '${t.visited()} dari ${t.places()}'),
                ('Total pengeluaran', rp(t.spending())),
                ('Foto memori', '${photos.length} foto'),
              ]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Destinasi yang dikunjungi', style: AppText.h2),
                  const SizedBox(height: 8),
                  MapView(height: 170, pins: pins),
                  const SizedBox(height: 8),
                  if (names.isNotEmpty)
                    Text(others > 0 ? '${names.take(4).join(', ')}, dan $others tempat lainnya.' : '${names.join(', ')}.', style: AppText.body.muted),
                ],
              ),
              if (photos.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Foto dan kenangan', style: AppText.h2),
                    const SizedBox(height: 8),
                    Tap(
                      onTap: () => push(context, PhotoMemoryPage(trip: t)),
                      radius: AppRadius.inner,
                      label: 'Buka Photo memory',
                      child: SizedBox(
                        height: 216,
                        child: Row(
                          children: [
                            Expanded(flex: 5, child: Photo(photos.last.src, height: 216, radius: AppRadius.inner)),
                            if (photos.length > 1) ...[
                              const SizedBox(width: 6),
                              Expanded(
