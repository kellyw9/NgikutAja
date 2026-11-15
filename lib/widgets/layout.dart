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
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: AppColors.line),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kMargin, vertical: 12),
            child: Row(
              children: [
                for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: 12), children[i]],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Ringkasan angka tanpa kotak: label kecil di atas nilai, dipisah garis vertikal.
class FactStrip extends StatelessWidget {
  const FactStrip(this.cells, {super.key});
  final List<(String, String)> cells;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(height: 1, color: AppColors.rule),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cells.length; i++) ...[
                if (i > 0) Container(width: 1, color: AppColors.rule),
                // Lebar sel mengikuti panjang isi supaya label dan nilai panjang tetap satu baris.
                Expanded(
                  flex: 12 + (cells[i].$1.length > cells[i].$2.length ? cells[i].$1.length : cells[i].$2.length),
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 12, right: i == cells.length - 1 ? 0 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cells[i].$1, style: AppText.small.muted),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(cells[i].$2, style: AppText.title, maxLines: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      Container(height: 1, color: AppColors.rule),
    ],
  );
}

/// Daftar label-nilai (struk, rincian biaya). Nilai rata kanan.
class KeyValueBox extends StatelessWidget {
  const KeyValueBox(this.rows, {super.key, this.total, this.fill = AppColors.surfaceSoft});
  final List<(String, String)> rows;
  final (String, String)? total;
  final Color fill;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      children: [
        for (final r in rows)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Row(
              children: [
                Text(r.$1, style: AppText.body.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(r.$2, style: AppText.body, textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
        if (total != null) ...[
          Container(height: 1, color: AppColors.line),
          SizedBox(
            height: 44,
            child: Row(
              children: [
                Expanded(child: Text(total!.$1, style: AppText.bodyStrong)),
                Text(total!.$2, style: AppText.h2),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

/// Baris daftar: ikon, judul, subjudul, chevron.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    this.icon,
    required this.title,
    this.sub,
    this.trailing = const AppIcon('chevron_right', size: 20, color: AppColors.muted),
    this.danger = false,
    this.lead,
    this.onTap,
    this.padH = kMargin,
  });
  final String? icon;
  final String title;
  final String? sub;
  final Widget? trailing;
  final bool danger;
  final Widget? lead;
  final VoidCallback? onTap;
  final double padH;

  @override
  Widget build(BuildContext context) => Tap(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: sub != null ? 64 : 52),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: 8),
        child: Row(
          children: [
            if (lead != null) ...[
              lead!,
              const SizedBox(width: 14),
            ] else if (icon != null) ...[
              AppIcon(icon!, size: 22, color: danger ? AppColors.negative : AppColors.ink),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.body.c(danger ? AppColors.negative : AppColors.ink)),
                  if (sub != null) ...[const SizedBox(height: 2), Text(sub!, style: AppText.small.muted)],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 14), trailing!],
          ],
        ),
      ),
    ),
  );
}

/// Blok putih bergaris tipis berisi baris yang dipisah garis (inset dari kiri).
class BoxList extends StatelessWidget {
  const BoxList({super.key, required this.children, this.inset = 48, this.padV = 2});
  final List<Widget> children;
  final double inset;
  final double padV;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    padding: EdgeInsets.symmetric(vertical: padV),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) NgDivider(inset: inset, color: AppColors.line), children[i]],
      ],
    ),
  );
}

/// Kartu putih bergaris tipis.
class NgCard extends StatelessWidget {
  const NgCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.border = AppColors.line,
    this.borderWidth = 1,
    this.onTap,
    this.fill = AppColors.surface,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color border;
  final double borderWidth;
  final VoidCallback? onTap;
  final Color fill;

  @override
  Widget build(BuildContext context) => Material(
    color: fill,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      side: BorderSide(color: border, width: borderWidth),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      focusColor: AppColors.teal.withValues(alpha: .15),
      child: Padding(padding: padding, child: child),
    ),
  );
}

/// Foto sampul selebar layar dengan tombol kotak putih di atasnya.
class HeroPhoto extends StatelessWidget {
  const HeroPhoto(this.photo, {super.key, this.height = 260, this.left = 'arrow_back', this.onLeft, this.right = const [], this.semantic});
  final String? photo;
  final double height;
  final String? left;
  final VoidCallback? onLeft;
  final List<Widget> right;
  final String? semantic;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kLightIcons.copyWith(systemNavigationBarColor: AppColors.surface, systemNavigationBarIconBrightness: Brightness.dark),
      child: SizedBox(
        height: height + top,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Photo(photo, semantic: semantic),
            // gradasi tipis di atas agar ikon status bar tetap terbaca di atas foto terang
            if (top > 0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: top + 24,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x660C4A57), Color(0x000C4A57)]),
                  ),
                ),
              ),
            if (left != null)
              Positioned(
                left: 12,
                top: top + 12,
                child: IconBtn(left!, label: 'Kembali', bg: AppColors.surface, size: 40, onTap: onLeft ?? () => Navigator.maybePop(context)),
              ),
            if (right.isNotEmpty)
              Positioned(
