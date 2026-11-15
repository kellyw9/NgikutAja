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
