import '../core/format.dart';

enum Category {
  makan('Makan', 'restaurant'),
  budaya('Budaya', 'museum'),
  alam('Alam', 'landscape'),
  sosial('Sosial', 'groups'),
  lainnya('Lainnya', 'category');

  const Category(this.label, this.icon);
  final String label;
  final String icon;
}

class Creator {
  Creator({
    required this.id,
    required this.name,
    required this.handle,
    required this.tint,
    required this.bio,
    required this.followers,
    required this.following,
    this.photo,
  });

  final String id;
  String name;
  String handle;
  final int tint;
  String bio;
  int followers;
  int following;

  /// Foto profil (kunci foto). Null = avatar inisial.
  String? photo;
}

class Stop {
  Stop({
    required this.start,
    required this.end,
    required this.name,
    required this.cat,
    this.cost = 0,
    this.photo,
    this.note,
    this.desc,
    this.address,
  });

  String start;
  String end;
  String name;
  Category cat;
  int cost;
  String? photo;
  String? note;
  String? desc;
  String? address;

  int get startMin => toMinutes(start);
  int get endMin => toMinutes(end);
  int get duration => (endMin - startMin).clamp(0, 24 * 60);

  Stop copy() => Stop(start: start, end: end, name: name, cat: cat, cost: cost, photo: photo, note: note, desc: desc, address: address);
}

List<List<Stop>> copyPlan(List<List<Stop>> plan) => [
  for (final d in plan) [for (final s in d) s.copy()],
];

class Itinerary {
  Itinerary({
    required this.id,
    required this.title,
    required this.city,
    required this.region,
    required this.days,
    required this.cover,
    required this.creator,
    this.price = 0,
    this.adopted = 0,
    this.likes = 0,
    this.rating,
    this.reviews,
    this.tags = const [],
    this.desc = '',
    List<String>? dayTitles,
    List<List<Stop>>? plan,
    this.lodging = 0,
    this.estimateSeed,
    this.placesSeed,
    DateTime? publishedAt,
    this.isDraft = false,
  }) : dayTitles = dayTitles ?? [],
       plan = plan ?? [],
       publishedAt = publishedAt ?? DateTime(2026, 1, 1);

  final String id;
  String title;
  String city;
  String region;
  int days;
  String? cover;
  Creator creator;
  int price;
  int adopted;
  int likes;
  double? rating;
  int? reviews;
  List<String> tags;
  String desc;
  List<String> dayTitles;
  List<List<Stop>> plan;

  /// Biaya penginapan yang ikut dihitung ke estimasi.
  int lodging;

  /// Estimasi dan jumlah tempat dari data contoh untuk itinerary yang jadwalnya tidak lengkap.
  int? estimateSeed;
  int? placesSeed;
  DateTime publishedAt;
  bool isDraft;

  bool get isPaid => price > 0;
  bool get hasFullPlan => plan.length == days && plan.every((d) => d.isNotEmpty);

  int dayCost(int d) => d < plan.length ? plan[d].fold(0, (a, s) => a + s.cost) : 0;
  int get stopCount => plan.fold(0, (a, d) => a + d.length);

  /// Estimasi per orang = jumlah biaya semua aktivitas (+ penginapan).
  int? get estimate {
    if (hasFullPlan) return plan.fold<int>(0, (a, d) => a + d.fold(0, (b, s) => b + s.cost)) + lodging;
    return estimateSeed;
  }

  int get places => hasFullPlan ? stopCount : (placesSeed ?? stopCount);

  String dayTitle(int d) => d < dayTitles.length && dayTitles[d].isNotEmpty ? dayTitles[d] : 'Hari ${d + 1}';
}

enum TripStatus {
  draft('Draft'),
  diadopsi('Diadopsi'),
  berjalan('Berjalan'),
  selesai('Selesai');

  const TripStatus(this.label);
  final String label;
}

enum MemberRole {
  owner('Pemilik'),
  editor('Bisa edit'),
  viewer('Hanya lihat');

  const MemberRole(this.label);
  final String label;
}

class Member {
  Member({required this.name, required this.handle, required this.role, required this.tint, this.joined});
  final String name;
  final String handle;
  MemberRole role;
  final int tint;
  final String? joined;

  String get first => name.split(' ').first;
}

enum ExpenseCat {
  makan('Makan', 'restaurant'),
  transportasi('Transportasi', 'directions_car'),
  tiket('Tiket', 'local_activity'),
  lainnya('Lainnya', 'category');

  const ExpenseCat(this.label, this.icon);
  final String label;
  final String icon;
}

class Expense {
  Expense({
    required this.id,
    required this.name,
    required this.cat,
    required this.amount,
    required this.by,
    required this.day,
    required this.time,
    this.receipt,
  });
