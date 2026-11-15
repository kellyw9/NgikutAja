import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 7.1 Split Budget: bagi rata atau kustom (porsi per anggota), lalu siapa transfer ke siapa.
class SplitBudgetPage extends StatefulWidget {
  const SplitBudgetPage({super.key, required this.trip});
  final Trip trip;

  @override
