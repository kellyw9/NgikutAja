import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

String photoDayLabel(Trip t, int d) {
  final date = t.dayDate(d);
  return date == null ? 'Hari ${d + 1}' : 'Hari ${d + 1}, ${weekdaysLong[date.weekday - 1]} ${date.day} ${monthsShort[date.month - 1]}';
}

/// 7.5 Photo Memory.
class PhotoMemoryPage extends StatelessWidget {
  const PhotoMemoryPage({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    AppScope.of(context);
    final t = trip;
    final days = {for (final p in t.photos) p.day}.toList()..sort();
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(title: 'Photo memory', sub: t.title),
      body: t.photos.isEmpty
          ? const EmptyState(
              icon: 'photo_library',
              title: 'Belum ada foto',
              text: 'Foto yang kamu tambahkan dari Travel Mode atau Trip journal tersimpan di sini.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
              children: [
                Text('${t.photos.length} foto tersimpan dari ${days.length} hari perjalanan', style: AppText.small.muted),
                for (final d in days) ...[
                  const SizedBox(height: 16),
                  Text(photoDayLabel(t, d), style: AppText.title),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, c) {
                      final size = (c.maxWidth - 12) / 3;
                      final list = t.photos.where((p) => p.day == d).toList();
                      return Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final p in list)
                            Tap(
                              onTap: () => push(context, PhotoViewerPage(trip: t, index: t.photos.indexOf(p)), fullscreen: true),
                              radius: AppRadius.inner,
                              label: 'Buka foto ${p.caption}',
                              child: Photo(p.src, width: size, height: size, radius: AppRadius.inner),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
    );
  }
}

/// 7.5 Photo Memory (layar penuh).
class PhotoViewerPage extends StatefulWidget {
  const PhotoViewerPage({super.key, required this.trip, required this.index});
  final Trip trip;
  final int index;

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late int i = widget.index;
  late final pc = PageController(initialPage: widget.index);

  @override
  void dispose() {
    pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final p = t.photos[i];
    final date = t.dayDate(p.day);
    return AnnotatedRegion(
      value: kLightIcons,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
