import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/text.dart';
import 'basics.dart';

enum MapKind { city, lake }

class MapPin {
  const MapPin(this.x, this.y, {this.n = 1, this.state = MarkerState.todo});
  final double x;
  final double y;
  final int n;
  final MarkerState state;
}

/// Peta sementara (gambar, bukan peta asli). Diberi label "Peta sementara" supaya tidak
/// disangka peta sungguhan. Ganti dengan widget peta asli saat integrasi peta dikerjakan.
class MapView extends StatelessWidget {
  const MapView({
    super.key,
    this.height = 200,
    this.kind = MapKind.city,
    this.pins = const [],
    this.me,
    this.radius = AppRadius.card,
    this.route = true,
    this.ring,
    this.onTapPoint,
    this.label = true,
    this.overlay = const [],
  });

  final double? height;
  final MapKind kind;
  final List<MapPin> pins;
  final Offset? me;
  final double radius;
  final bool route;

  /// Lingkaran radius check-in: (pusat relatif, radius piksel).
  final (Offset, double)? ring;
  final ValueChanged<Offset>? onTapPoint;
  final bool label;
  final List<Widget> overlay;

  @override
  Widget build(BuildContext context) {
    final map = LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = height ?? c.maxHeight;
        return SizedBox(
          width: w,
          height: h,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: onTapPoint == null ? null : (d) => onTapPoint!(Offset(d.localPosition.dx / w, d.localPosition.dy / h)),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(child: CustomPaint(painter: _MapPainter(kind, route ? pins : const [], ring))),
                for (final p in pins)
                  Positioned(
                    left: p.x * w - 12,
                    top: p.y * h - 12,
                    child: Marker(p.n, state: p.state),
                  ),
                if (me != null)
                  Positioned(
                    left: me!.dx * w - 11,
                    top: me!.dy * h - 11,
                    child: Semantics(
                      label: 'Posisi saya',
                      child: Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(color: AppColors.myLocation, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  ),
                ...overlay,
                if (label)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      height: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.tag)),
                      child: Text('Peta sementara', style: AppText.small.muted),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
    return Semantics(
      label: 'Peta sementara dengan ${pins.length} penanda',
      child: radius > 0 ? ClipRRect(borderRadius: BorderRadius.circular(radius), child: map) : map,
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.kind, this.pins, this.ring);
  final MapKind kind;
  final List<MapPin> pins;
  final (Offset, double)? ring;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    Offset p(double x, double y) => Offset(x * w, y * h);
    canvas.drawRect(Offset.zero & s, Paint()..color = AppColors.mapLand);
    final road = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    if (kind == MapKind.lake) {
      final lake = Path()
        ..moveTo(.16 * w, -.05 * h)
        ..cubicTo(.1 * w, .3 * h, .2 * w, .7 * h, .12 * w, 1.05 * h)
        ..lineTo(1.05 * w, 1.05 * h)
        ..lineTo(1.05 * w, -.05 * h)
        ..close();
      canvas.drawPath(lake, Paint()..color = AppColors.mapWater);
      final island = Path()
        ..moveTo(.45 * w, .12 * h)
        ..cubicTo(.75 * w, .08 * h, .95 * w, .3 * h, .9 * w, .55 * h)
        ..cubicTo(.86 * w, .8 * h, .65 * w, .95 * h, .45 * w, .9 * h)
        ..cubicTo(.28 * w, .85 * h, .3 * w, .6 * h, .34 * w, .4 * h)
        ..cubicTo(.36 * w, .25 * h, .38 * w, .14 * h, .45 * w, .12 * h)
        ..close();
      canvas.drawPath(island, Paint()..color = AppColors.mapLand);
