import 'package:flutter/material.dart';

/// Warna desain NgikutAja, diambil langsung dari piksel gambar desain.
///
/// TODO(KONFIRMASI): ini tema SEMENTARA untuk modul Adopt & Customize.
/// Saat integrasi, pindahkan ke tema aplikasi bersama (MaterialApp di
/// lib/main.dart) supaya semua modul memakai warna yang sama.
/// TODO(KONFIRMASI): font desain belum dipasang (butuh nama font dari
/// Figma + paket google_fonts atau file font di assets).
class NgColors {
  NgColors._();

  /// Hijau tua: judul, tombol utama, tab aktif.
  static const Color teal = Color(0xFF0C4A57);

  /// Hijau lebih terang: garis timeline, garis bawah tab.
  static const Color tealMid = Color(0xFF448587);

  /// Biru-hijau sangat muda: label "Diadopsi", lingkaran nomor.
  static const Color tealSoft = Color(0xFFD6F0F1);

  /// Krem: latar halaman.
  static const Color cream = Color(0xFFF3E3D3);

  /// Krem lebih gelap: garis pemisah, kotak putus-putus, tombol nonaktif.
  static const Color creamDark = Color(0xFFE5D5C5);

  /// Kuning: tombol Create, aksen.
  static const Color yellow = Color(0xFFFFBC16);

  /// Kuning muda: kotak tips / peringatan "jadwal padat".
  static const Color yellowSoft = Color(0xFFFFF1C4);

  /// Merah: bentrok jadwal, Hapus.
  static const Color red = Color(0xFFC5242A);

  /// Merah muda: latar banner bentrok.
  static const Color redSoft = Color(0xFFFFEDE9);

  /// Teks sekunder (lokasi, durasi, tanggal).
  static const Color textMuted = Color(0xFF7A776F);

  /// Garis kotak isian (desain: abu-abu tipis).
  static const Color fieldBorder = Color(0xFF979692);
}

/// Tema modul. Dipakai di MaterialApp (main_dummy.dart sekarang,
/// main.dart saat integrasi): `theme: adoptCustomizeTheme(),`
///
/// Sengaja hanya memakai ColorScheme + tema tombol/input yang stabil di
/// berbagai versi Flutter, supaya tidak error karena beda versi.
ThemeData adoptCustomizeTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: NgColors.teal,
        brightness: Brightness.light,
      ).copyWith(
        primary: NgColors.teal,
        onPrimary: Colors.white,
        primaryContainer: NgColors.tealSoft,
        onPrimaryContainer: NgColors.teal,
        secondary: NgColors.tealMid,
        onSecondary: Colors.white,
        secondaryContainer: NgColors.tealSoft,
        onSecondaryContainer: NgColors.teal,
        tertiary: NgColors.yellow,
        onTertiary: NgColors.teal,
        tertiaryContainer: NgColors.yellowSoft,
        onTertiaryContainer: const Color(0xFF5C4400),
        error: NgColors.red,
        onError: Colors.white,
        errorContainer: NgColors.redSoft,
        onErrorContainer: const Color(0xFFAC333A),
        // Latar halaman, AppBar.
        surface: NgColors.cream,
        onSurface: NgColors.teal,
        onSurfaceVariant: NgColors.textMuted,
        // Kartu, bottom sheet, dialog, kolom isian: putih.
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: Colors.white,
        surfaceContainer: Colors.white,
        surfaceContainerHigh: Colors.white,
        surfaceContainerHighest: NgColors.cream,
        outline: NgColors.tealMid,
        outlineVariant: NgColors.creamDark,
        surfaceTint: Colors.transparent,
      );

  const pill = StadiumBorder();

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: NgColors.cream,
    dividerColor: NgColors.creamDark,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: pill,
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        disabledBackgroundColor: NgColors.creamDark,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: pill,
        minimumSize: const Size(0, 48),
        foregroundColor: NgColors.teal,
        side: const BorderSide(color: NgColors.teal, width: 1.2),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: NgColors.teal,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    // Kolom isian desain: putih, sudut 14, garis abu-abu tipis. Label
    // ditaruh DI ATAS kotak (widget NgField), bukan di dalam garis.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: NgColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NgColors.fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NgColors.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NgColors.teal, width: 1.5),
      ),
    ),
  );
}

/// Pasang di MaterialApp / MaterialApp.router:
///   `builder: adoptCustomizeAppBuilder,`
///
/// Memberi jarak di bawah SEMUA halaman, bottom sheet, dan dialog setinggi
/// tombol navigasi HP (gesture bar / tombol ◁ ○ □), jadi isi aplikasi tidak
/// pernah tertutup. Area di belakang tombol navigasi HP diberi warna putih
/// (sama dengan bottom nav aplikasi).
/// TODO(INTEGRASI): pindahkan ke main.dart bersama tema.
Widget adoptCustomizeAppBuilder(BuildContext context, Widget? child) {
  return ColoredBox(
    color: Colors.white,
    child: SafeArea(
      top: false,
      child: child ?? const SizedBox.shrink(),
    ),
  );
}