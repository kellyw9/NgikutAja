// Helper konversi data untuk semua model modul Adopt & Customize.
// TODO(KONFIRMASI): format penyimpanan tanggal belum disepakati tim.

/// Mengubah nilai dari penyimpanan menjadi DateTime.
DateTime? parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  // TODO(FIRESTORE): aktifkan setelah cloud_firestore terpasang
  // (tambahkan: import 'package:cloud_firestore/cloud_firestore.dart';)
  // if (value is Timestamp) return value.toDate();
  return null;
}

/// Mengubah DateTime menjadi nilai untuk disimpan.
Object? dateToStorage(DateTime? value) {
  if (value == null) return null;
  // TODO(FIRESTORE): ganti menjadi Timestamp.fromDate(value)
  return value.toIso8601String();
}
