import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 7.3 Local Tips.
class TipsPage extends StatelessWidget {
  const TipsPage({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final tips = app.seed.tips[trip.city] ?? const <LocalTip>[];
    return Scaffold(
