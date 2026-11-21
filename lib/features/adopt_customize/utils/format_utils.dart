import '../models/trip_model.dart';
import 'time_utils.dart';

const List<String> _weekdays = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];
const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _month(DateTime d) => _months[d.month - 1];

/// Contoh (desain): 'Sabtu, 12 Des 2026'. Tanpa hari: '12 Des 2026'.
String formatDateId(DateTime? d, {bool withWeekday = true}) {
  if (d == null) return '-';
  final base = '${d.day} ${_month(d)} ${d.year}';
  return withWeekday ? '${_weekdays[d.weekday - 1]}, $base' : base;
}

/// Contoh: 29000 menjadi 'Rp29.000'.
String formatRupiah(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${amount < 0 ? '-' : ''}Rp$buffer';
}

/// Biaya stop untuk tampilan: 0 menjadi 'Gratis', null menjadi ''.
String formatCost(int? amount) {
  if (amount == null) return '';
  return amount == 0 ? 'Gratis' : formatRupiah(amount);
}

/// '08:00' menjadi '08.00' (gaya penulisan desain).
String formatTimeId(String? hhmm) =>
    hhmm == null ? '' : hhmm.replaceFirst(':', '.');

/// Contoh (desain): '45 menit', '2 jam', '1 jam 30 menit'.
String formatDuration(int? minutes) {
  if (minutes == null) return '';
  if (minutes < 60) return '$minutes menit';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h jam' : '$h jam $m menit';
}

/// Contoh: '08.00 – 09.30 · 1 jam 30 menit'. Jam selesai dihitung otomatis.
/// Kosong jika jam mulai dan durasi sama-sama tidak ada.
String formatSchedule(String? startTime, int? durationMinutes) {
  final end = computeEndTime(startTime, durationMinutes);
  final parts = <String>[];
  if (startTime != null) {
    parts.add(
      end == null
          ? formatTimeId(startTime)
          : '${formatTimeId(startTime)} – ${formatTimeId(end)}',
    );
  }
  final duration = formatDuration(durationMinutes);
  if (duration.isNotEmpty) parts.add(duration);
  return parts.join(' · ');
}

/// Label status tersimpan (internal/debug). Untuk tab dan badge di layar,
/// pakai [tripPhaseLabel].
String tripStatusLabel(TripStatus status) {
  switch (status) {
    case TripStatus.copying:
      return 'Menyalin';
    case TripStatus.planned:
      return 'Direncanakan';
    case TripStatus.ongoing:
      return 'Berjalan';
    case TripStatus.done:
      return 'Selesai';
  }
}

/// Label tab dan badge Trip Saya (desain).
/// TODO(KONFIRMASI): 'Diadopsi' untuk trip yang sudah punya tanggal tapi
/// belum berangkat. Tidak tepat jika nanti ada trip yang bukan hasil Adopt.
String tripPhaseLabel(TripPhase phase) {
  switch (phase) {
    case TripPhase.draft:
      return 'Draft';
    case TripPhase.upcoming:
      return 'Diadopsi';
    case TripPhase.ongoing:
      return 'Berjalan';
    case TripPhase.done:
      return 'Selesai';
  }
}

/// Kategori bawaan. Kunci disimpan di database, label untuk tampilan.
/// Kategori lain (pilihan "Lainnya") disimpan apa adanya.
/// Label mengikuti desain ('Makan', 'Budaya', 'Sosial').
/// TODO(KONFIRMASI): samakan kunci dan label dengan model Anggota 2.
const Map<String, String> kStopCategories = {
  'food': 'Makan',
  'culture': 'Budaya',
  'social': 'Sosial',
  'photo': 'Foto',
  'shopping': 'Belanja',
  'nature': 'Alam',
  'museum': 'Museum',
};

/// Label tampilan kategori. Kosong jika tidak ada kategori.
String categoryLabel(String? category) {
  final value = category?.trim();
  if (value == null || value.isEmpty) return '';
  return kStopCategories[value] ?? value;
}

/// Rentang tanggal ringkas (desain):
/// - bulan sama: '12–14 Des 2026'
/// - beda bulan: '30 Nov – 2 Des 2026'
/// - beda tahun: '30 Des 2026 – 1 Jan 2027'
/// - satu hari:  '12 Des 2026'
/// [withDays] menambahkan ' · 3 hari'. Tanggal kosong: 'Tanggal belum diatur'.
String formatDateRange(
  DateTime? start,
  DateTime? end,
  int days, {
  bool withDays = false,
}) {
  if (start == null || end == null) return 'Tanggal belum diatur';
  final String range;
  if (start.year != end.year) {
    range =
        '${start.day} ${_month(start)} ${start.year} – '
        '${end.day} ${_month(end)} ${end.year}';
  } else if (start.month != end.month) {
    range = '${start.day} ${_month(start)} – ${end.day} ${_month(end)} ${end.year}';
  } else if (start.day == end.day) {
    range = '${start.day} ${_month(start)} ${start.year}';
  } else {
    range = '${start.day}–${end.day} ${_month(end)} ${end.year}';
  }
  return withDays ? '$range · $days hari' : range;
}