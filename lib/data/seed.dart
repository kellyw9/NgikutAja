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
  }

  final DateTime now;
  final DateTime today;

  /// Transaksi transfer bank contoh dibuat 1 menit sebelum aplikasi dibuka,
  /// supaya batas bayar 15 menitnya masih berjalan.
  DateTime get _pendingAt => now.subtract(const Duration(minutes: 1));

  late final Creator me;
  late final Map<String, Creator> creators;
  late final List<Itinerary> itineraries;
  late final List<Itinerary> drafts;
  late final List<Trip> trips;
  late final List<Review> reviews;
  late final Map<String, List<Comment>> comments;
  late final List<Transaction> transactions;
  late final List<AppNotification> notifications;
  late final Map<String, List<LocalTip>> tips;
  late final List<Person> followers;
  late final List<Person> followingPeople;

  static const ratingDist = {5: 27, 4: 7, 3: 2, 2: 0, 1: 0};

  /// Penjualan bulanan "Samosir Naik Motor 2 Hari" (Jul sampai Nov).
  static const monthly = [('Jul', 2), ('Agu', 4), ('Sep', 5), ('Okt', 6), ('Nov', 1)];

  static const recentSearches = ['Danau Toba', 'Medan', 'Bukittinggi'];

  DateTime _d(int offset) => today.add(Duration(days: offset));

  void _build() {
    me = Creator(
      id: 'dinda',
      name: 'Dinda Saragi',
      handle: '@dindasaragi',
      tint: 0,
      bio: 'Anak Medan. Suka sarapan di pasar dan duduk lama di pinggir danau.',
      followers: 86,
      following: 112,
    );

    creators = {
      'rahmat': Creator(
        id: 'rahmat',
        name: 'Rahmat Siregar',
        handle: '@jalanjalanmedan',
        tint: 1,
        bio: 'Pemandu lokal Medan. Rute pagi sampai malam tanpa buang waktu di jalan.',
        followers: 1240,
        following: 75,
      ),
      'lestari': Creator(
        id: 'lestari',
        name: 'Lestari Manurung',
        handle: '@tobaslowtravel',
        tint: 3,
        bio: 'Tinggal di Samosir. Menulis rute pelan untuk yang mau menginap.',
        followers: 860,
        following: 140,
      ),
      'bayu': Creator(
        id: 'bayu',
        name: 'Bayu Prasetyo',
        handle: '@jogjahemat',
        tint: 4,
        bio: 'Keliling Jogja naik Trans Jogja dan jalan kaki.',
        followers: 2310,
        following: 98,
      ),
      'komang': Creator(
        id: 'komang',
        name: 'Komang Ayu',
        handle: '@rutebaliutara',
        tint: 2,
        bio: 'Bali bagian utara: danau, air terjun, pantai pasir hitam.',
        followers: 540,
        following: 61,
      ),
      'yosef': Creator(
        id: 'yosef',
        name: 'Yosef Ndun',
        handle: '@bajoharian',
        tint: 5,
        bio: 'Kapten kapal wisata di Labuan Bajo.',
        followers: 410,
        following: 33,
      ),
      'nadia': Creator(
        id: 'nadia',
        name: 'Nadia Kusuma',
        handle: '@bandungjadul',
        tint: 1,
        bio: 'Gedung tua, kopi, dan jalan kaki di Bandung.',
        followers: 690,
        following: 210,
      ),
    };
    final c = creators;

    final medan = Itinerary(
      id: 'medan',
      title: '3 Hari Kuliner dan Sejarah di Medan',
      city: 'Medan',
      region: 'Medan, Sumatera Utara',
      days: 3,
      cover: 'maimun',
      creator: c['rahmat']!,
      price: 0,
      adopted: 212,
      likes: 486,
      rating: 4.8,
      reviews: 36,
      tags: ['Kuliner', 'Budaya'],
      publishedAt: _d(-20),
      desc:
          'Tiga hari keliling Medan dengan urutan yang hemat jalan: pagi di istana dan masjid tua, siang di rumah saudagar, '
          'sore jalan kaki di Kesawan. Hari kedua dan ketiga fokus kuliner malam dan oleh-oleh.',
      dayTitles: ['Istana dan kota tua', 'Pasar dan kuliner malam', 'Oleh-oleh sebelum pulang'],
      plan: [
        [
