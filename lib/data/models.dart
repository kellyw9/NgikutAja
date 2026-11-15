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
