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
