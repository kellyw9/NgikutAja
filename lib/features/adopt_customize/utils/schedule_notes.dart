import '../models/trip_draft.dart';
import '../models/trip_stop_model.dart';
import 'format_utils.dart';
import 'time_utils.dart';

/// Ambang "jadwal terlalu padat": total durasi aktivitas berjam dalam sehari.
/// Desain mencontohkan 9 jam sebagai padat dan 7 jam 30 menit sebagai wajar.
/// TODO(KONFIRMASI): angka 8 jam ini usulan, belum disepakati tim.
const int kBusyDayMinutes = 8 * 60;

enum ScheduleNoteKind { conflict, busy }

/// Satu catatan per hari (desain: kotak merah "Jadwal bertabrakan di Hari 1"
/// atau kotak kuning "Jadwal terlalu padat di Hari 2"). Hanya peringatan.
class ScheduleNote {
  const ScheduleNote({
    required this.kind,
    required this.dayId,
    required this.title,
    required this.lines,
  });

  final ScheduleNoteKind kind;
  final String dayId;
  final String title;
  final List<String> lines;
}

enum SuggestionKind { shiftTime, moveToDay }

/// Saran penyesuaian (desain: "Geser Mie Aceh Titi Bobrok ke 14.45",
/// "Pindahkan Museum Negeri ke Hari 3") dengan tombol "Terapkan".
class ScheduleSuggestion {
  const ScheduleSuggestion({
    required this.kind,
    required this.stopId,
    required this.title,
    this.subtitle,
    this.newStartMinutes,
    this.targetDayId,
  });

  final SuggestionKind kind;
  final String stopId;
  final String title;
  final String? subtitle;

  /// Untuk [SuggestionKind.shiftTime].
  final int? newStartMinutes;

  /// Untuk [SuggestionKind.moveToDay].
  final String? targetDayId;
}

class ScheduleReport {
  const ScheduleReport({
    required this.notes,
    required this.suggestions,
    required this.conflictedStopIds,
  });

  static const empty = ScheduleReport(
    notes: [],
    suggestions: [],
    conflictedStopIds: {},
  );

  final List<ScheduleNote> notes;
  final List<ScheduleSuggestion> suggestions;
  final Set<String> conflictedStopIds;

  List<ScheduleNote> notesOfDay(String dayId) =>
      notes.where((n) => n.dayId == dayId).toList();
}

/// Menyusun catatan jadwal dan saran dari draft. Tidak mengubah draft.
ScheduleReport buildScheduleReport(TripDraft draft) {
  final notes = <ScheduleNote>[];
  final suggestions = <ScheduleSuggestion>[];
  final conflicted = <String>{};

  final totals = <String, int>{
    for (final d in draft.days) d.id: _totalMinutes(draft.stopsOfDay(d.id)),
  };

  for (final day in draft.days) {
    final timed = [
      for (final s in draft.stopsOfDay(day.id))
        if (parseHHmm(s.startTime) != null) s,
    ];

    // ---- Bentrok: pasangan yang waktunya beririsan.
    final pairs = <(TripStopModel, TripStopModel)>[];
    final latestEndBefore = <String, int>{}; // stop B -> selesai A paling akhir
    for (var i = 0; i < timed.length; i++) {
      for (var j = i + 1; j < timed.length; j++) {
        final a = timed[i];
        final b = timed[j];
        final aEnd = _end(a);
        if (_start(b) < aEnd) {
          pairs.add((a, b));
          conflicted..add(a.id)..add(b.id);
          final prev = latestEndBefore[b.id];
          if (prev == null || aEnd > prev) latestEndBefore[b.id] = aEnd;
        }
      }
    }
    if (pairs.isNotEmpty) {
      notes.add(
        ScheduleNote(
          kind: ScheduleNoteKind.conflict,
          dayId: day.id,
          title: 'Jadwal bertabrakan di Hari ${day.dayNumber}',
          lines: [
            for (final (a, b) in pairs.take(3))
              '${_label(a)} dan ${_label(b)}.',
            if (pairs.length > 3)
              'Dan ${pairs.length - 3} jadwal lain yang juga bertabrakan.',
          ],
        ),
      );
      for (final entry in latestEndBefore.entries) {
        final stop = timed.firstWhere((s) => s.id == entry.key);
        final newStart = entry.value + kMoveGapMinutes;
        final shifts = draft.previewShift(stop.id, newStart);
        if (shifts == null) continue;
        final followers = shifts.skip(1).map(
          (t) =>
              '${t.stop.placeName} ikut mundur ke '
              '${_range(t.newStartMinutes, t.stop.durationMinutes)}',
        );
        suggestions.add(
          ScheduleSuggestion(
            kind: SuggestionKind.shiftTime,
            stopId: stop.id,
            title: 'Geser ${stop.placeName} ke ${_dot(newStart)}',
            subtitle: followers.isEmpty ? null : followers.join('\n'),
            newStartMinutes: newStart,
          ),
        );
      }
    }

    // ---- Terlalu padat.
    final total = totals[day.id] ?? 0;
    if (total > kBusyDayMinutes && timed.isNotEmpty) {
      final first = _start(timed.first);
      final last = timed.map(_end).reduce((a, b) => a > b ? a : b);
      int? minGap;
      for (var i = 0; i + 1 < timed.length; i++) {
        final gap = _start(timed[i + 1]) - _end(timed[i]);
        if (gap >= 0 && (minGap == null || gap < minGap)) minGap = gap;
      }
      notes.add(
        ScheduleNote(
          kind: ScheduleNoteKind.busy,
          dayId: day.id,
          title: 'Jadwal terlalu padat di Hari ${day.dayNumber}',
          lines: [
            '${formatDuration(total)} aktivitas dari ${_dot(first)} sampai '
                '${_dot(last)}'
                '${minGap == null ? '' : ', jeda paling pendek ${formatDuration(minGap)}'}.',
          ],
        ),
      );

      // Saran: pindahkan aktivitas terlama ke hari paling longgar.
      final others = draft.days.where((d) => d.id != day.id).toList();
      if (others.isNotEmpty) {
        final target = others.reduce(
          (a, b) => (totals[a.id] ?? 0) <= (totals[b.id] ?? 0) ? a : b,
        );
        final longest = timed.reduce(
          (a, b) =>
              (a.durationMinutes ?? 0) >= (b.durationMinutes ?? 0) ? a : b,
        );
        final remaining = total - (longest.durationMinutes ?? 0);
        suggestions.add(
          ScheduleSuggestion(
            kind: SuggestionKind.moveToDay,
            stopId: longest.id,
            title:
                'Pindahkan ${longest.placeName} ke Hari ${target.dayNumber}',
            subtitle:
                'Hari ${day.dayNumber} jadi ${formatDuration(remaining)}',
            targetDayId: target.id,
          ),
        );
      }
    }
  }

  return ScheduleReport(
    notes: notes,
    suggestions: suggestions,
    conflictedStopIds: conflicted,
  );
}

int _start(TripStopModel s) => parseHHmm(s.startTime)!;
int _end(TripStopModel s) => _start(s) + (s.durationMinutes ?? 0);

int _totalMinutes(List<TripStopModel> stops) {
  var total = 0;
  for (final s in stops) {
    if (parseHHmm(s.startTime) != null) total += s.durationMinutes ?? 0;
  }
  return total;
}

String _dot(int minutes) {
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$h.$m';
}

String _range(int start, int? duration) =>
    duration == null ? _dot(start) : '${_dot(start)}–${_dot(start + duration)}';

/// "Tjong A Fie Mansion (13.00–14.30)"
String _label(TripStopModel s) =>
    '${s.placeName} (${_range(_start(s), s.durationMinutes)})';