import 'package:flutter/material.dart';

import '../core/text.dart';

/// Placeholder tujuan setelah login/daftar. Ganti dengan halaman Beranda aslimu.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Beranda', style: AppText.h1)),
    );
  }
}