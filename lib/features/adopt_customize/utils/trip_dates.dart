/// TODO(KONFIRMASI): batas maksimal hari per trip adalah asumsi pengaman,
/// belum disepakati tim.
const int kMaxTripDays = 30;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Tanggal hari ke-[index] (mulai dari 0) dihitung dari [start].
DateTime dayDate(DateTime start, int index) {
  return DateTime(start.year, start.month, start.day + index);
}

/// Jumlah hari dari [start] sampai [end], keduanya dihitung (inklusif).
/// Hasil kurang dari 1 berarti [end] sebelum [start].
int tripDayCount(DateTime start, DateTime end) {
  final s = DateTime.utc(start.year, start.month, start.day);
  final e = DateTime.utc(end.year, end.month, end.day);
  return e.difference(s).inDays + 1;
}
