/// Format angka gaya Indonesia: Rp25.000, 1.240, 4,8.
String thousands(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return (n < 0 ? '-' : '') + buf.toString();
}

String rp(int n) => n < 0 ? '−Rp${thousands(-n)}' : 'Rp${thousands(n)}';

String decimal(double v, [int digits = 1]) => v.toStringAsFixed(digits).replaceAll('.', ',');

/// Ambil angka dari teks rupiah yang diketik ("Rp25.000" -> 25000).
int parseRupiah(String text) => int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

const monthsShort = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
const monthsLong = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
const weekdaysLong = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const weekdaysShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

/// "Sabtu, 12 Des 2026"
String dateLong(DateTime d) => '${weekdaysLong[d.weekday - 1]}, ${d.day} ${monthsShort[d.month - 1]} ${d.year}';

/// "Sab, 12 Des"
String dateShort(DateTime d) => '${weekdaysShort[d.weekday - 1]}, ${d.day} ${monthsShort[d.month - 1]}';

/// "12–14 Des 2026" atau "30 Nov–2 Des 2026"
String dateRange(DateTime a, DateTime b) {
  if (a.month == b.month && a.year == b.year) {
    return a.day == b.day ? '${a.day} ${monthsShort[a.month - 1]} ${a.year}' : '${a.day}–${b.day} ${monthsShort[a.month - 1]} ${a.year}';
  }
  return '${a.day} ${monthsShort[a.month - 1]}–${b.day} ${monthsShort[b.month - 1]} ${b.year}';
}

/// Jam "08.30" <-> menit sejak 00.00.
int toMinutes(String hhmm) {
  final p = hhmm.split('.');
  return (int.tryParse(p[0]) ?? 0) * 60 + (p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0);
