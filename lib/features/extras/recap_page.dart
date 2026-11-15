import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import 'memory_pages.dart';

/// 7.6 Trip Recap.
class RecapPage extends StatelessWidget {
  const RecapPage({super.key, required this.trip});
  final Trip trip;

  String _summary(Trip t) =>
      'Recap trip "${t.title}" (${t.dates ?? ''}): ${t.visited()} dari ${t.places()} tempat dikunjungi, '
