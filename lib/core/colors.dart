import 'package:flutter/widgets.dart';

/// Token warna NgikutAja ("Papan Jadwal"), sama persis dengan halaman Design System.
class AppColors {
  AppColors._();

  // Palet merek inti
  static const ground = Color(0xFFFAF3EA); // latar semua layar
  static const teal = Color(0xFF258C9B); // rute, indikator aktif, progres (bukan untuk teks)
  static const yellow = Color(0xFFFEBF12); // satu arti: sekarang / berikutnya
  static const ink = Color(0xFF0C4A57); // teks utama dan tombol utama

  // Turunan
  static const primaryStrong = Color(0xFF176975); // link dan aksi teks
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFFFFBF6);
  static const sunk = Color(0xFFF0E5D8);
  static const muted = Color(0xFF4A6569);
  static const rule = Color(0xFFE3D3C1); // garis di atas krem
  static const line = Color(0xFFE8DCCD); // garis dan tepi kartu di atas putih
  static const control = Color(0xFF7F9194); // tepi input dan kontrol
  static const tealPale = Color(0xFFD3ECEF);
  static const yellowPale = Color(0xFFFFF1C4);
  static const positive = Color(0xFF1E6B44);
  static const positivePale = Color(0xFFDCFAE5);
  static const positiveInk = Color(0xFF04250E);
  static const negative = Color(0xFFC4242A);
  static const negativePale = Color(0xFFFFEDEA);
  static const negativeInk = Color(0xFF831C1E);
  static const white = Color(0xFFFFFFFF);
  static const scrim = Color(0x730C4A57); // ink, opacity 0.45

  // Header Travel Mode (tinta satu tingkat lebih terang)
  static const inkRaised = Color(0xFF17505C);

  // Peta sementara
  static const mapLand = Color(0xFFEDE4D7);
  static const mapWater = Color(0xFFBCDCE1);
  static const mapPark = Color(0xFFDCE8D3);
  static const myLocation = Color(0xFF1A73E8);

  /// Warna latar avatar inisial.
