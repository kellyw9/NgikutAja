import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../shell/home_shell.dart';
import 'onboarding_page.dart';

/// 1.1 Splash: garis rute pembuka (motif yang sama dengan timeline dan Travel Mode).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
