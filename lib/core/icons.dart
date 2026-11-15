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
