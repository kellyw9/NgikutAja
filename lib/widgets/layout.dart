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
                height: 56,
                child: Padding(
                  padding: EdgeInsets.only(left: back != null ? 4 : kMargin, right: 4),
                  child: Row(
                    children: [
                      if (back != null)
                        IconBtn(back!, label: back == 'close' ? 'Tutup' : 'Kembali', onTap: onBack ?? () => Navigator.maybePop(context)),
                      const SizedBox(width: 4),
                      Expanded(child: titleCol),
                      if (trailingTitle != null) ...[const SizedBox(width: 8), trailingTitle!, const SizedBox(width: 8)],
                      ...actions,
                      if (center && actions.isEmpty && trailingTitle == null) const SizedBox(width: 44),
                    ],
                  ),
                ),
              ),
              if (rule) Container(height: 1, color: AppColors.rule),
            ],
          ),
        ),
      ),
    );
  }
}

/// Judul halaman akar tab: h1 rata kiri.
class TabHeader extends StatelessWidget {
  const TabHeader(this.title, {super.key, this.actions = const [], this.sub});
  final String title;
  final List<Widget> actions;
  final String? sub;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(kMargin, 12, 4, 8),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(header: true, child: Text(title, style: AppText.h1)),
              if (sub != null) ...[const SizedBox(height: 2), Text(sub!, style: AppText.small.muted)],
            ],
          ),
        ),
        ...actions,
      ],
    ),
  );
}

class SectionHead extends StatelessWidget {
  const SectionHead(this.title, {super.key, this.action, this.onAction, this.sub, this.padded = true});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final String? sub;
  final bool padded;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: padded ? kMargin : 0, right: padded ? 4 : 0),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(header: true, child: Text(title, style: AppText.h2)),
              if (sub != null) ...[const SizedBox(height: 2), Text(sub!, style: AppText.small.muted)],
            ],
          ),
        ),
        if (action != null)
          Padding(
            padding: EdgeInsets.only(right: padded ? 12 : 0),
            child: TextLink(action!, onTap: onAction),
          ),
      ],
    ),
  );
}

/// Bar aksi bawah yang menempel: garis atas, isi.
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.children});
  final List<Widget> children;

  @override
