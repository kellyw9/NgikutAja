import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../adopt_customize_theme.dart';
import '../models/trip_photo_model.dart';

// ============================================================== GAMBAR

/// Menampilkan gambar dari URL (http/https) atau path file lokal (hasil
/// galeri). Jika kosong atau gagal dimuat, tampil placeholder "Tanpa foto".
/// Catatan: path lokal hanya bisa dibuka di Android/iOS (bukan web).
class NgImage extends StatelessWidget {
  const NgImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.radius = 0,
    this.showPlaceholderText = true,
  });

  final String? source;
  final double? width;
  final double? height;
  final double radius;
  final bool showPlaceholderText;

  @override
  Widget build(BuildContext context) {
    final src = source?.trim() ?? '';
    Widget placeholder(BuildContext context) => _Placeholder(
      width: width,
      height: height,
      showText: showPlaceholderText,
    );

    Widget image;
    if (src.isEmpty) {
      image = placeholder(context);
    } else if (src.startsWith('http://') || src.startsWith('https://')) {
      image = Image.network(
        src,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => placeholder(context),
      );
    } else {
      image = Image.file(
        File(src),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => placeholder(context),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: width, height: height, child: image),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.width, this.height, required this.showText});

  final double? width;
  final double? height;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: NgColors.creamDark,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_outlined, color: NgColors.textMuted),
          if (showText && (height == null || height! >= 72))
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Tanpa foto',
                style: TextStyle(fontSize: 11, color: NgColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

// ========================================================= GARIS PUTUS

/// Kotak bergaris putus-putus (desain: "Tambah aktivitas", "Tambah" foto).
class DashedBox extends StatelessWidget {
  const DashedBox({
    super.key,
    required this.child,
    this.radius = 14,
    this.color = NgColors.textMuted,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final double radius;
  final Color color;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        painter: _DashedPainter(color: color, radius: radius),
        child: SizedBox(
          width: width,
          height: height,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color || old.radius != radius;
}

// ============================================================== FORM

/// Label di ATAS kolom isian (desain), bukan di dalam garis kotak.
class NgField extends StatelessWidget {
  const NgField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: NgColors.teal,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Kotak isian yang dibuka dengan ketukan (jam, durasi, tanggal, kategori).
class NgTapField extends StatelessWidget {
  const NgTapField({
    super.key,
    required this.text,
    this.icon,
    this.trailing,
    this.onTap,
    this.muted = false,
  });

  final String text;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// True untuk kolom otomatis/nonaktif (latar krem, bukan putih).
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: muted ? Colors.transparent : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: NgColors.fieldBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: NgColors.teal),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 15, color: NgColors.teal),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Format ribuan untuk kolom biaya: 35000 tampil "35.000".
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// "35.000" menjadi 35000. Kosong menjadi null.
  static int? parse(String text) =>
      int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));

  static String format(int? value) {
    if (value == null) return '';
    return ThousandsFormatter()
        .formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: value.toString()),
        )
        .text;
  }
}

// ============================================================== KATEGORI

/// Ikon kategori (desain: garpu-sendok untuk Makan, gedung untuk Budaya,
/// orang untuk Sosial).
IconData categoryIcon(String? category) {
  switch (category) {
    case 'food':
      return Icons.restaurant;
    case 'culture':
      return Icons.account_balance_outlined;
    case 'social':
      return Icons.groups_outlined;
    case 'photo':
      return Icons.photo_camera_outlined;
    case 'shopping':
      return Icons.shopping_bag_outlined;
    case 'nature':
      return Icons.park_outlined;
    case 'museum':
      return Icons.museum_outlined;
    default:
      return Icons.label_outline;
  }
}

// ================================================================ FOTO

/// Membuka galeri HP dan mengembalikan path foto yang dipilih (null jika batal).
///
/// Izin: Android memakai pemilih foto sistem (tidak perlu izin penyimpanan).
/// iOS butuh teks izin di ios/Runner/Info.plist (NSPhotoLibraryUsageDescription).
/// Jika izin ditolak, pengguna diberi tahu lewat snackbar.
Future<String?> pickPhotoFromGallery(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    return file?.path;
  } on PlatformException catch (e) {
    final denied = e.code.contains('denied') || e.code.contains('access');
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          denied
              ? 'Akses galeri ditolak. Izinkan akses foto di Pengaturan HP, '
                    'lalu coba lagi.'
              : 'Galeri tidak bisa dibuka. Coba lagi.',
        ),
      ),
    );
    return null;
  }
}

/// Deretan foto + kotak "Tambah" (desain: bagian "Foto" dan "Foto trip").
/// Ketuk foto untuk menghapusnya.
class PhotoStrip extends StatelessWidget {
  const PhotoStrip({
    super.key,
    required this.sources,
    required this.onAdd,
    required this.onRemove,
    this.size = 96,
    this.emptyText,
  });

  /// Pasangan (id, sumber gambar).
  final List<(String, String)> sources;
  final VoidCallback? onAdd;
  final void Function(String id)? onRemove;
  final double size;

  /// Teks di samping kotak "Tambah" jika belum ada foto.
  final String? emptyText;

  /// Helper untuk daftar [TripPhotoModel].
  static List<(String, String)> fromPhotos(List<TripPhotoModel> photos) => [
    for (final p in photos) (p.id, '${p.photoUrl}'),
  ];

  Future<void> _confirmRemove(BuildContext context, String id) async {
    final remove = onRemove;
    if (remove == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus foto?'),
        content: const Text('Foto dihapus setelah kamu menyimpan perubahan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: NgColors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) remove(id);
  }

  @override
  Widget build(BuildContext context) {
    final addTile = DashedBox(
      width: size,
      height: size,
      onTap: onAdd,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_a_photo_outlined, color: NgColors.teal),
          SizedBox(height: 6),
          Text('Tambah', style: TextStyle(fontSize: 13, color: NgColors.teal)),
        ],
      ),
    );

    if (sources.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          addTile,
          if (emptyText != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                emptyText!,
                style: const TextStyle(color: NgColors.textMuted),
              ),
            ),
          ],
        ],
      );
    }

    return SizedBox(
      height: size,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final (id, src) in sources) ...[
            GestureDetector(
              onTap: () => _confirmRemove(context, id),
              child: NgImage(
                source: src,
                width: size,
                height: size,
                radius: 14,
                showPlaceholderText: false,
              ),
            ),
            const SizedBox(width: 12),
          ],
          addTile,
        ],
      ),
    );
  }
}

// ============================================================ IKON + TEKS

/// Ikon kecil + teks abu-abu (desain: "📍 Medan", "🗓 12–14 Des 2026").
class IconLabel extends StatelessWidget {
  const IconLabel({
    super.key,
    required this.icon,
    required this.text,
    this.size = 14,
  });

  final IconData icon;
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size + 2, color: NgColors.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: size, color: NgColors.textMuted),
          ),
        ),
      ],
    );
  }
}

/// Snackbar untuk tombol fitur modul lain yang belum tersambung.
void showNotConnected(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text('$feature belum tersambung (modul lain).')),
    );
}