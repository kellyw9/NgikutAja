/// Menit terakhir dalam sehari (23:59).
/// TODO(KONFIRMASI): jadwal yang melewati tengah malam belum didukung.
const int kLastMinuteOfDay = 23 * 60 + 59;

/// Mengubah teks 'HH:mm' menjadi menit sejak 00:00.
/// Mengembalikan null jika format tidak valid (contoh: '9:00' atau '25:00').
int? parseHHmm(String? value) {
  if (value == null) return null;
  final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(value);
  if (match == null) return null;
  // Tanda `!` aman: pola regex di atas selalu mengisi grup 1 dan 2.
  return int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
}

/// Menit sejak 00:00 menjadi 'HH:mm'. Hanya untuk nilai 0..1439.
String formatHHmm(int minutes) {
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

/// Jam selesai ('HH:mm') dari jam mulai + durasi.
/// Null jika salah satu kosong/tidak valid atau hasilnya melewati 23:59.
String? computeEndTime(String? startTime, int? durationMinutes) {
  final start = parseHHmm(startTime);
  if (start == null || durationMinutes == null || durationMinutes <= 0) {
    return null;
  }
  final end = start + durationMinutes;
  if (end > kLastMinuteOfDay) return null;
  return formatHHmm(end);
}

/// Durasi (menit) dari jam mulai dan jam selesai.
/// Null jika tidak valid atau jam selesai tidak setelah jam mulai.
int? computeDuration(String? startTime, String? endTime) {
  final start = parseHHmm(startTime);
  final end = parseHHmm(endTime);
  if (start == null || end == null || end <= start) return null;
  return end - start;
}
