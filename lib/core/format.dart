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
