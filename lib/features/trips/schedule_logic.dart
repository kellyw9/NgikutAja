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
  for (final (a, b) in conflictsIn(day)) ...[a, b],
};

int activeMinutes(List<Stop> day) => day.fold(0, (a, s) => a + s.duration);

/// Jeda paling pendek antar aktivitas berurutan (menurut jam), dalam menit.
int? shortestGap(List<Stop> day) {
  final s = [...day]..sort((a, b) => a.startMin.compareTo(b.startMin));
  int? best;
  for (var i = 1; i < s.length; i++) {
    final g = s[i].startMin - s[i - 1].endMin;
    if (g >= 0 && (best == null || g < best)) best = g;
  }
  return best;
}

bool isPacked(List<Stop> day) => activeMinutes(day) >= 8 * 60;

class Suggestion {
  Suggestion({required this.icon, required this.title, required this.sub, required this.apply});
  final String icon;
  final String title;
  final String sub;
  final void Function(List<List<Stop>> plan) apply;
}

class DayIssue {
  DayIssue({required this.day, required this.conflict, required this.title, required this.lines});
  final int day;
  final bool conflict;
  final String title;
  final List<String> lines;
}

/// Geser [target] ke [newStart] dan mundurkan aktivitas setelahnya yang jadi bertabrakan.
/// Mengembalikan nama + jam baru aktivitas lain yang ikut bergeser.
List<String> shiftCascade(List<Stop> day, Stop target, int newStart) {
  final moved = <String>[];
  final dur = target.duration;
  target
    ..start = fromMinutes(newStart)
    ..end = fromMinutes(newStart + dur);
  final later = day.where((s) => !identical(s, target) && s.startMin >= newStart).toList()..sort((a, b) => a.startMin.compareTo(b.startMin));
  var cursor = target.endMin;
  for (final s in later) {
    if (s.startMin < cursor) {
      final d = s.duration;
      final ns = cursor + 15;
      s
        ..start = fromMinutes(ns)
        ..end = fromMinutes(ns + d);
      moved.add('${s.name} ikut mundur ke ${s.start}–${s.end}');
    }
    cursor = s.endMin;
  }
  return moved;
}

(List<DayIssue>, List<Suggestion>) analyze(List<List<Stop>> plan) {
  final issues = <DayIssue>[];
  final tips = <Suggestion>[];
  for (var d = 0; d < plan.length; d++) {
    final day = plan[d];
    final cs = conflictsIn(day);
    if (cs.isNotEmpty) {
      final involved = conflictIndexes(day).toList()..sort();
      issues.add(
        DayIssue(
          day: d,
          conflict: true,
          title: 'Jadwal bertabrakan di Hari ${d + 1}',
          lines: [for (final i in involved) '${day[i].name}: ${day[i].start}–${day[i].end}'],
        ),
      );
      final (i, j) = cs.first;
      final a = day[i].startMin <= day[j].startMin ? day[i] : day[j];
      final b = identical(a, day[i]) ? day[j] : day[i];
      final ns = a.endMin + 15;
      // Pratinjau di salinan supaya teks saran sesuai hasil sebenarnya.
      final preview = [for (final s in day) s.copy()];
      final pb = preview[day.indexOf(b)];
      final others = shiftCascade(preview, pb, ns);
      tips.add(
        Suggestion(
          icon: 'schedule',
          title: 'Geser ${b.name} ke ${fromMinutes(ns)}',
          sub: others.isEmpty ? 'Durasi tetap ${durationText(b.duration)}' : 'Jadwal ${others.first}',
          apply: (p) {
            final target = p[d].firstWhere((s) => s.name == b.name && s.start == b.start);
            shiftCascade(p[d], target, ns);
          },
        ),
      );
    }
    if (isPacked(day)) {
      final s = [...day]..sort((x, y) => x.startMin.compareTo(y.startMin));
      final gap = shortestGap(day);
      issues.add(
        DayIssue(
          day: d,
