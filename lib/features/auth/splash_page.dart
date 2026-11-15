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
      final app = AppScope.read(context);
      replace(context, app.onboarded ? const HomeShell() : const OnboardingPage());
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: kLightIcons,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 64,
                        child: Stack(
                          children: [
                            const Positioned.fill(child: CustomPaint(painter: _RoutePainter())),
                            const Positioned(left: 1, top: 37, child: Marker(1, state: MarkerState.done, size: 26)),
                            const Positioned(left: 107, top: 1, child: Marker(2, state: MarkerState.done, size: 26)),
                            const Positioned(left: 213, top: 17, child: Marker(3, state: MarkerState.next, size: 26)),
                          ],
