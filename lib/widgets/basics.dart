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
        fit: BoxFit.cover,
        width: width,
        height: height,
        cacheWidth: width != null && width!.isFinite ? (width! * 2.5).round() : null,
        errorBuilder: (_, _, _) => Container(color: AppColors.sunk),
      );
    }
    final box = SizedBox(width: width, height: height, child: img);
    final wrapped = semantic == null ? ExcludeSemantics(child: box) : Semantics(image: true, label: semantic, child: box);
    return radius > 0 ? ClipRRect(borderRadius: BorderRadius.circular(radius), child: wrapped) : wrapped;
  }
}

// ---------------------------------------------------------------- garis putus-putus

class DashedBox extends StatelessWidget {
  const DashedBox({super.key, required this.child, this.color = AppColors.control, this.radius = AppRadius.control, this.width = 1, this.fill});
  final Widget child;
  final Color color;
  final double radius;
  final double width;
  final Color? fill;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _DashPainter(color, radius, width, fill), child: child);
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color, this.radius, this.width, this.fill);
  final Color color;
  final double radius;
  final double width;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset(width / 2, width / 2) & Size(size.width - width, size.height - width);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    if (fill != null) canvas.drawRRect(rr, Paint()..color = fill!);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final path = Path()..addRRect(rr);
    for (final ui.PathMetric m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter o) => o.color != color || o.fill != fill;
}

/// Tombol garis putus-putus selebar layar: "Tambah hari", "Tambah aktivitas".
class DashedAction extends StatelessWidget {
  const DashedAction(this.label, {super.key, required this.onTap, this.icon = 'add', this.height = 48, this.color = AppColors.control, this.fill});
  final String label;
  final VoidCallback onTap;
  final String icon;
  final double height;
  final Color color;
  final Color? fill;

  @override
  Widget build(BuildContext context) => Tap(
    onTap: onTap,
    radius: AppRadius.control,
    child: DashedBox(
      color: color,
      fill: fill,
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label, style: AppText.bodyStrong),
          ],
        ),
      ),
    ),
  );
}

/// Kotak tambah foto 80x80 bergaris putus-putus.
class AddPhotoTile extends StatelessWidget {
  const AddPhotoTile({super.key, required this.onTap, this.size = 80, this.label = 'Tambah', this.icon = 'add_a_photo'});
  final VoidCallback onTap;
  final double size;
  final String label;
  final String icon;

  @override
  Widget build(BuildContext context) => Tap(
    onTap: onTap,
    radius: AppRadius.inner,
    label: label,
    child: DashedBox(
      radius: AppRadius.inner,
      child: SizedBox.square(
        dimension: size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 20, color: AppColors.muted),
            const SizedBox(height: 4),
            Text(label, style: AppText.small.muted),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------- label

enum PillKind { neutral, teal, positive, negative, warning, solid }

/// Status: tag persegi radius 4, pasangan warna pucat + teks gelap.
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.kind = PillKind.neutral, this.icon});
  final String text;
  final PillKind kind;
  final String? icon;

  static (Color, Color) colors(PillKind k) => switch (k) {
    PillKind.neutral => (AppColors.sunk, AppColors.ink),
    PillKind.teal => (AppColors.tealPale, AppColors.ink),
    PillKind.positive => (AppColors.positivePale, AppColors.positiveInk),
    PillKind.negative => (AppColors.negativePale, AppColors.negativeInk),
    PillKind.warning => (AppColors.yellowPale, AppColors.ink),
    PillKind.solid => (AppColors.ink, AppColors.white),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = colors(kind);
    return Container(
      height: 22,
      padding: EdgeInsets.only(left: icon != null ? 5 : 8, right: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.tag)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[AppIcon(icon!, size: 14, color: fg), const SizedBox(width: 4)],
          Text(text, style: AppText.smallStrong.c(fg)),
        ],
      ),
    );
  }
}

/// Harga berbayar: label putih dengan ikon label harga.
class PriceTag extends StatelessWidget {
  const PriceTag(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    height: 28,
    padding: const EdgeInsets.only(left: 6, right: 10),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.tag)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppIcon('sell', size: 16),
        const SizedBox(width: 4),
        Text(text, style: AppText.smallStrong),
      ],
    ),
  );
}

/// Item metadata: ikon 16 + teks kecil.
class Meta extends StatelessWidget {
  const Meta(this.icon, this.text, {super.key, this.color = AppColors.muted});
  final String icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppIcon(icon, size: 16, color: color),
      const SizedBox(width: 4),
      Flexible(child: Text(text, style: AppText.small.c(color))),
    ],
  );
}

/// Baris metadata dipisah jarak 12 (tanpa titik tengah).
class MetaRow extends StatelessWidget {
  const MetaRow(this.items, {super.key, this.color = AppColors.muted, this.gap = 12});
  final List<(String, String)?> items;
  final Color color;
  final double gap;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: gap,
    runSpacing: 4,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [for (final i in items.whereType<(String, String)>()) Meta(i.$1, i.$2, color: color)],
  );
}

/// Avatar inisial (belum ada foto profil asli).
class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = 32, this.tint = 0, this.photo});
  final String name;
  final double size;
  final int tint;
  final String? photo;

  static String initials(String name) =>
      name.replaceAll('@', '').split(RegExp(r'[\s.]')).where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();

  @override
  Widget build(BuildContext context) {
    if (photo != null) {
      return ClipOval(
        child: Photo(photo, width: size, height: size, semantic: 'Foto profil $name'),
      );
    }
    final style = size >= 56 ? AppText.h2 : (size >= 32 ? AppText.bodyStrong : AppText.smallStrong);
    return Semantics(
      label: name,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.tints[tint % AppColors.tints.length], shape: BoxShape.circle),
        child: ExcludeSemantics(
          child: Text(initials(name), style: style.copyWith(fontSize: size < 24 ? 9 : null)),
        ),
      ),
    );
  }
}

/// Logo sementara: nama produk sebagai teks, diawali penanda rute persegi teal.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.large = true, this.onDark = false});
  final bool large;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final mark = large ? 14.0 : 10.0;
    return Semantics(
      label: 'NgikutAja',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: mark,
              height: mark,
              decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(3)),
            ),
            SizedBox(width: large ? 10 : 6),
