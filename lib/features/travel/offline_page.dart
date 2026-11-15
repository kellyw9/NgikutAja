import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 6.7 Pengelolaan Offline.
class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  String _now() {
    final n = DateTime.now();
    return fromMinutes(n.hour * 60 + n.minute);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
