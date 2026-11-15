import '../../core/format.dart';
import '../../data/models.dart';

/// Pasangan aktivitas yang jamnya tumpang tindih dalam satu hari (indeks).
List<(int, int)> conflictsIn(List<Stop> day) {
  final out = <(int, int)>[];
  for (var i = 0; i < day.length; i++) {
    for (var j = i + 1; j < day.length; j++) {
      if (day[i].startMin < day[j].endMin && day[j].startMin < day[i].endMin) out.add((i, j));
    }
  }
  return out;
}

Set<int> conflictIndexes(List<Stop> day) => {
