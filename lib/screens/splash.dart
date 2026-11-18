import 'dart:async';

import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/icons.dart';
import '../core/nav.dart';
import '../core/text.dart';
import '../widgets/wordmark.dart';
import 'onboarding1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) replace(context, const Onboarding1Screen());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 5),
            const SizedBox(
              width: 120,
              height: 50,
              child: CustomPaint(painter: _RoutePainter()),
            ),
            const SizedBox(height: 12),
            const Wordmark(size: 34, mainColor: AppColors.white),
            const SizedBox(height: 4),
            Text('Liburan tinggal ngikut', style: AppText.body.c(AppColors.tealPale)),
            const Spacer(flex: 4),
            const SpinIcon(size: 24, color: AppColors.tealPale),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final start = Offset(8, size.height * 0.55);
    final mid = Offset(size.width * 0.45, size.height * 0.45);
    final end = Offset(size.width - 12, size.height * 0.3);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(size.width * 0.3, size.height * 0.95, size.width * 0.5, size.height * 0.1, end.dx, end.dy);
    canvas.drawPath(path, line);

    void dot(Offset o, Color c) {
      canvas.drawCircle(o, 8, Paint()..color = c);
      final check = Paint()
        ..color = c == AppColors.yellow ? AppColors.ink : AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(
        Path()
          ..moveTo(o.dx - 3, o.dy)
          ..lineTo(o.dx - 0.5, o.dy + 2.5)
          ..lineTo(o.dx + 3.5, o.dy - 2.5),
        check,
      );
    }

    dot(start, AppColors.teal);
    dot(mid, AppColors.teal);
    dot(end, AppColors.yellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}