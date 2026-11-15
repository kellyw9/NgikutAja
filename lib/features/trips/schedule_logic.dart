import '../../core/format.dart';
import '../../data/models.dart';

/// Pasangan aktivitas yang jamnya tumpang tindih dalam satu hari (indeks).
List<(int, int)> conflictsIn(List<Stop> day) {
  final out = <(int, int)>[];
