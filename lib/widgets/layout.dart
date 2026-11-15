import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import '../core/icons.dart';
import '../core/text.dart';
import 'basics.dart';

const kDarkIcons = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: AppColors.surface,
  systemNavigationBarIconBrightness: Brightness.dark,
);

const kLightIcons = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: AppColors.ink,
  systemNavigationBarIconBrightness: Brightness.light,
);

/// App bar: tombol kembali, judul rata kiri (h2), subjudul kecil, aksi di kanan.
class NgAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NgAppBar({
    super.key,
    this.title,
    this.sub,
    this.back = 'arrow_back',
    this.onBack,
    this.actions = const [],
    this.rule = false,
    this.center = false,
    this.trailingTitle,
  });

  final String? title;
  final String? sub;

  /// Ikon tombol kiri ('arrow_back' atau 'close'); null = tanpa tombol.
  final String? back;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool rule;
  final bool center;
  final Widget? trailingTitle;

  @override
  Size get preferredSize => Size.fromHeight(rule ? 57 : 56);

  @override
  Widget build(BuildContext context) {
    final titleCol = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty)
          Semantics(
            header: true,
            child: Text(title!, style: AppText.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        if (sub != null) Text(sub!, style: AppText.small.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kDarkIcons,
      child: Material(
        color: AppColors.ground,
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
