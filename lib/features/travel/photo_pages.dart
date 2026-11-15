import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 6.6 Tambah foto perjalanan: sheet kamera/galeri, lalu pratinjau.
Future<void> addTripPhoto(BuildContext context, Trip trip, int day) async {
  final p = await pickPhotoSheet(context, title: 'Tambah foto perjalanan');
  if (p == null || p.isEmpty || !context.mounted) return;
  push(context, PhotoPreviewPage(trip: trip, day: day, src: p), fullscreen: true);
}

class PhotoPreviewPage extends StatefulWidget {
  const PhotoPreviewPage({super.key, required this.trip, required this.day, required this.src});
  final Trip trip;
  final int day;
  final String src;

  @override
  State<PhotoPreviewPage> createState() => _PhotoPreviewPageState();
}

class _PhotoPreviewPageState extends State<PhotoPreviewPage> {
  late int? stop = AppScope.read(context).nextIndex(widget.trip, widget.day);
  String vis = 'Trip-only';

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final stops = t.plan[widget.day];
    final st = stop != null && stop! < stops.length ? stops[stop!] : null;
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const NgAppBar(title: 'Foto baru', back: 'close'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
        children: [
          Gap(
            16,
            children: [
              Photo(widget.src, height: 250, radius: AppRadius.card, semantic: 'Foto baru'),
              NgField(
                label: 'Aktivitas terkait',
                icon: st?.cat.icon ?? 'pin_drop',
                value: st == null ? 'Tanpa aktivitas' : '${st.name} (Hari ${widget.day + 1})',
                trailing: 'expand_more',
                onTap: () async {
                  final r = await showNgSheet<int>(
                    context,
                    title: 'Aktivitas terkait',
                    scroll: true,
                    builder: (ctx) => Column(
                      children: [
                        RadioRow(title: 'Tanpa aktivitas', selected: stop == null, onTap: () => Navigator.pop(ctx, -1)),
                        for (var k = 0; k < stops.length; k++)
                          RadioRow(
                            title: stops[k].name,
                            sub: '${stops[k].start}–${stops[k].end}',
                            selected: stop == k,
                            onTap: () => Navigator.pop(ctx, k),
                          ),
                      ],
                    ),
                  );
                  if (r != null) setState(() => stop = r < 0 ? null : r);
                },
              ),
