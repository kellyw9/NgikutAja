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
