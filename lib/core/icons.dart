import 'package:flutter/widgets.dart';
import 'package:path_parsing/path_parsing.dart';

import 'colors.dart';
import 'icon_paths.dart';

/// Ikon Material Symbols Outlined (sama dengan desain), digambar dari path SVG.
/// [filled] memakai varian `__fill` bila tersedia.
class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {super.key, this.size = 24, this.color = AppColors.ink, this.filled = false});

  final String name;
  final double size;
  final Color color;
  final bool filled;

  static final Map<String, Path> _cache = {};

  static Path _path(String name, bool filled) {
    final key = filled && kIconPaths.containsKey('${name}__fill') ? '${name}__fill' : name;
    return _cache.putIfAbsent(key, () {
      final data = kIconPaths[key];
      assert(data != null, 'Ikon tidak ada: $name');
      final b = _PathBuilder();
      writeSvgPathDataToPath(data ?? '', b);
      return b.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _IconPainter(_path(name, filled), color)),
      ),
    );
  }
}

class _PathBuilder extends PathProxy {
  final Path path = Path();
  @override
  void close() => path.close();
  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) => path.cubicTo(x1, y1, x2, y2, x3, y3);
  @override
  void lineTo(double x, double y) => path.lineTo(x, y);
  @override
  void moveTo(double x, double y) => path.moveTo(x, y);
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.path, this.color);
  final Path path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 960;
    canvas.save();
    canvas.scale(s, s);
    canvas.translate(0, 960);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.path != path || old.color != color;
}

/// Ikon berputar untuk status memuat (progress_activity).
class SpinIcon extends StatefulWidget {
  const SpinIcon({super.key, this.size = 24, this.color = AppColors.ink});
  final double size;
  final Color color;

  @override
  State<SpinIcon> createState() => _SpinIconState();
}

class _SpinIconState extends State<SpinIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
