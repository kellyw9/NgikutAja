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
