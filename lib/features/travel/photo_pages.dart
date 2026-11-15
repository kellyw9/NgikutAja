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
