// DATA CONTOH (bukan data nyata), diambil dari desain final NgikutAja.
// Tanggal trip dan transaksi dihitung relatif terhadap hari ini supaya status
// (Diadopsi, Berjalan, Selesai) dan hitung mundur tetap masuk akal kapan pun aplikasi dibuka.
import '../core/format.dart';
import 'models.dart';

Stop _s(String start, String end, String name, Category cat, int cost, [String? photo, String? note, String? desc]) =>
    Stop(start: start, end: end, name: name, cat: cat, cost: cost, photo: photo, note: note, desc: desc);

const _m = Category.makan, _b = Category.budaya, _a = Category.alam, _so = Category.sosial, _l = Category.lainnya;

class Seed {
  Seed(this.now) : today = DateTime(now.year, now.month, now.day) {
    _build();
