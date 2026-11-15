import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/icons.dart';
import '../core/text.dart';
import '../data/services.dart';

// ---------------------------------------------------------------- tombol

enum BtnKind { primary, secondary, accent, danger, dangerText, text, ghost }

enum BtnSize { lg, md }

/// Tombol NgikutAja: radius 8, tinggi 48 (lg) atau 40 (md).
class NgButton extends StatelessWidget {
  const NgButton(
    this.label, {
    super.key,
    this.onPressed,
    this.kind = BtnKind.primary,
    this.size = BtnSize.lg,
    this.icon,
    this.trailingIcon,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final BtnKind kind;
  final BtnSize size;
  final String? icon;
  final String? trailingIcon;
  final bool expand;
  final bool loading;

  static (Color?, Color, Color?) _colors(BtnKind k) => switch (k) {
    BtnKind.primary => (AppColors.ink, AppColors.white, null),
    BtnKind.secondary => (AppColors.surface, AppColors.ink, AppColors.ink),
    BtnKind.accent => (AppColors.yellow, AppColors.ink, null),
    BtnKind.danger => (AppColors.negative, AppColors.white, null),
    BtnKind.dangerText => (null, AppColors.negative, null),
    BtnKind.text => (null, AppColors.primaryStrong, null),
    BtnKind.ghost => (AppColors.sunk, AppColors.ink, null),
  };

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final (bg, fg, stroke) = _colors(kind);
    final textual = kind == BtnKind.text || kind == BtnKind.dangerText;
    final lg = size == BtnSize.lg;
    final color = disabled ? AppColors.muted : fg;
    final style = (lg ? AppText.button : AppText.bodyStrong).c(color);

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SpinIcon(size: 20, color: color),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          AppIcon(icon!, size: 20, color: color),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        if (trailingIcon != null) ...[const SizedBox(width: 8), AppIcon(trailingIcon!, size: 20, color: color)],
      ],
    );

    return SizedBox(
      height: lg ? 48 : 40,
      width: expand ? double.infinity : null,
      child: TextButton(
        onPressed: disabled ? null : onPressed,
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: textual ? 8 : (lg ? 20 : 16))),
          minimumSize: const WidgetStatePropertyAll(Size(44, 40)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: WidgetStatePropertyAll(disabled && !textual ? AppColors.sunk : bg),
          foregroundColor: WidgetStatePropertyAll(color),
          overlayColor: WidgetStateProperty.resolveWith((s) {
            final base = (bg == AppColors.ink || bg == AppColors.negative) ? AppColors.white : AppColors.ink;
            if (s.contains(WidgetState.pressed)) return base.withValues(alpha: .16);
            if (s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)) return base.withValues(alpha: .08);
            return null;
          }),
          side: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.focused)) return const BorderSide(color: AppColors.teal, width: 2);
            if (stroke != null && !disabled) return BorderSide(color: stroke);
            return BorderSide.none;
          }),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.control)))),
          mouseCursor: WidgetStatePropertyAll(disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click),
        ),
        child: child,
      ),
    );
  }
}

/// Tombol ikon: area sentuh 44 persegi. Dengan [bg]: kotak radius 8 (dipakai di atas foto).
class IconBtn extends StatelessWidget {
  const IconBtn(
    this.icon, {
    super.key,
    required this.label,
    this.onTap,
    this.bg,
    this.color = AppColors.ink,
    this.size = 44,
    this.iconSize = 24,
    this.filled = false,
    this.stroke,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;
  final Color? bg;
  final Color color;
  final double size;
  final double iconSize;
  final bool filled;
  final Color? stroke;

  @override
  Widget build(BuildContext context) {
    final boxed = bg != null || stroke != null;
    final radius = BorderRadius.circular(boxed ? AppRadius.control : size / 2);
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: Material(
          color: bg ?? Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: stroke != null ? BorderSide(color: stroke!) : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(borderRadius: radius),
            focusColor: AppColors.teal.withValues(alpha: .24),
            child: SizedBox.square(
              dimension: size,
              child: Center(
                child: AppIcon(icon, size: iconSize, color: onTap == null ? AppColors.control : color, filled: filled),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Link teks (primaryStrong). Tinggi sentuh 44.
class TextLink extends StatelessWidget {
  const TextLink(this.label, {super.key, this.onTap, this.icon, this.style, this.color = AppColors.primaryStrong});
  final String label;
  final VoidCallback? onTap;
  final String? icon;
  final TextStyle? style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        focusColor: AppColors.teal.withValues(alpha: .2),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: (style ?? AppText.bodyStrong).c(color)),
              if (icon != null) ...[const SizedBox(width: 4), AppIcon(icon!, size: 18, color: color)],
            ],
          ),
        ),
      ),
    );
  }
}

/// Area ketuk generik dengan efek tekan, fokus, dan kursor tangan.
class Tap extends StatelessWidget {
  const Tap({super.key, required this.child, this.onTap, this.radius = 0, this.label});
  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          focusColor: AppColors.teal.withValues(alpha: .18),
          highlightColor: AppColors.ink.withValues(alpha: .06),
          splashColor: AppColors.ink.withValues(alpha: .08),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- foto

/// Foto bawaan (nama aset di assets/photos) atau foto pengguna (`mem:<id>`).
/// Tanpa sumber: kotak sunk dengan ikon.
class Photo extends StatelessWidget {
  const Photo(this.src, {super.key, this.width, this.height, this.radius = 0, this.placeholderIcon = 'add_a_photo', this.semantic});
  final String? src;
  final double? width;
  final double? height;
  final double radius;
  final String placeholderIcon;
  final String? semantic;

  @override
  Widget build(BuildContext context) {
    Widget img;
    final s = src;
    if (s == null) {
      img = Container(
        color: AppColors.sunk,
        alignment: Alignment.center,
        child: AppIcon(placeholderIcon, color: AppColors.muted),
      );
    } else if (s.startsWith('mem:')) {
      final bytes = PhotoStore.get(s);
      img = bytes == null
          ? Container(color: AppColors.sunk)
          : Image.memory(bytes, fit: BoxFit.cover, width: width, height: height, gaplessPlayback: true);
    } else {
      img = Image.asset(
        'assets/photos/$s.jpg',
