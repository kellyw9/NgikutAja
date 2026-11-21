import 'package:flutter/material.dart';

import '../adopt_customize_theme.dart';
import '../models/trip_day_model.dart';
import '../models/trip_detail.dart';
import '../models/trip_model.dart';
import '../models/trip_stop_model.dart';
import '../utils/format_utils.dart';
import '../utils/schedule_notes.dart';
import '../utils/time_utils.dart';
import '../utils/trip_dates.dart';
import '../widgets/ng_widgets.dart';

// ============================================================ FORMAT KECIL
// Format tampilan desain ("13.00", "Sabtu, 12 Des").
// TODO(TAHAP-LANJUT): pindahkan ke utils/format_utils.dart.

const List<String> _dayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];
const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// "Sabtu, 12 Des" (atau "Sabtu 12 Des" jika [comma] false).
String dayDateLabel(DateTime? date, {bool comma = true}) {
  if (date == null) return 'Tanggal belum diatur';
  final day = _dayNames[date.weekday - 1];
  return '$day${comma ? ',' : ''} ${date.day} ${_monthNames[date.month - 1]}';
}

/// Menit sejak 00:00 menjadi "13.00".
String dotTime(int minutes) {
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$h.$m';
}

/// 'HH:mm' menjadi "HH.mm". Null/tidak valid menjadi ''.
String dotTimeOf(String? hhmm) {
  final minutes = parseHHmm(hhmm);
  return minutes == null ? '' : dotTime(minutes);
}

/// "07.30–08.30", "07.30" (tanpa durasi), atau '' (tanpa jam).
String stopTimeRange(TripStopModel stop) {
  final start = parseHHmm(stop.startTime);
  if (start == null) return '';
  final duration = stop.durationMinutes;
  if (duration == null) return dotTime(start);
  return '${dotTime(start)}–${dotTime(start + duration)}';
}

/// Jam selesai paling akhir (menit) di daftar stop. Null jika tidak ada stop berjam.
int? lastEndMinutes(Iterable<TripStopModel> stops) {
  int? last;
  for (final s in stops) {
    final start = parseHHmm(s.startTime);
    if (start == null) continue;
    final end = start + (s.durationMinutes ?? 0);
    if (last == null || end > last) last = end;
  }
  return last;
}

/// Judul + subjudul di atas bottom sheet (gaya desain).
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: NgColors.teal,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(color: NgColors.textMuted)),
          ],
        ],
      ),
    );
  }
}

/// Lingkaran nomor aktivitas (putih, garis hijau, angka hijau).
class NumberBadge extends StatelessWidget {
  const NumberBadge(this.number, {super.key, this.size = 28});

  final int number;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: NgColors.tealMid, width: 1.5),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: NgColors.teal,
        ),
      ),
    );
  }
}

// =================================================================== HAPUS

Future<bool?> confirmDeleteStop(BuildContext context, String placeName) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.delete_outline, color: NgColors.red),
      title: const Text('Hapus aktivitas?'),
      content: Text(
        '"$placeName" akan dihapus dari trip ini setelah kamu menyimpan '
        'perubahan. Itinerary asli tidak berubah.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: NgColors.red),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}

// ================================================================== PINDAH

/// Bottom sheet "Pindahkan aktivitas" (desain). Mengembalikan id hari tujuan.
Future<String?> askMoveTarget(
  BuildContext context, {
  required TripDetail detail,
  required TripStopModel stop,
  required String? Function(String dayId) previewStartTime,
}) {
  if (detail.days.length < 2) return Future<String?>.value(null);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => _MoveSheet(
      detail: detail,
      stop: stop,
      previewStartTime: previewStartTime,
    ),
  );
}

class _MoveSheet extends StatefulWidget {
  const _MoveSheet({
    required this.detail,
    required this.stop,
    required this.previewStartTime,
  });

  final TripDetail detail;
  final TripStopModel stop;
  final String? Function(String dayId) previewStartTime;

  @override
  State<_MoveSheet> createState() => _MoveSheetState();
}

class _MoveSheetState extends State<_MoveSheet> {
  late String _targetDayId;

  @override
  void initState() {
    super.initState();
    _targetDayId = widget.detail.days
        .firstWhere((d) => d.id != widget.stop.dayId)
        .id;
  }

  TripDayModel _dayById(String id) =>
      widget.detail.days.firstWhere((d) => d.id == id);

  String _daySummary(TripDayModel day) {
    final stops = widget.detail.stopsOfDay(day.id);
    if (stops.isEmpty) return 'Belum ada aktivitas';
    final last = lastEndMinutes(stops);
    return last == null
        ? '${stops.length} aktivitas'
        : '${stops.length} aktivitas, selesai ${dotTime(last)}';
  }

  String _moveNote(TripDayModel target) {
    final newStart = widget.previewStartTime(target.id);
    if (newStart == null) {
      return 'Masuk ke Hari ${target.dayNumber} tanpa jam, di urutan terakhir.';
    }
    if (newStart == widget.stop.startTime) {
      return 'Jam tetap ${dotTimeOf(newStart)}, urutannya mengikuti jam. '
          'Jam bisa diubah setelahnya.';
    }
    return 'Masuk di urutan terakhir Hari ${target.dayNumber}, mulai '
        '${dotTimeOf(newStart)}. Jam bisa diubah setelahnya.';
  }

  @override
  Widget build(BuildContext context) {
    final stop = widget.stop;
    final currentDay = _dayById(stop.dayId);
    final target = _dayById(_targetDayId);
    final range = stopTimeRange(stop);
    final category = categoryLabel(stop.category);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHeader(title: 'Pindahkan aktivitas'),
            // Aktivitas yang dipindah: kotak krem (desain), bukan putih.
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: NgColors.cream,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  NumberBadge(stop.order),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.placeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: NgColors.teal,
                          ),
                        ),
                        Text(
                          [
                            if (category.isNotEmpty) category,
                            'Hari ${currentDay.dayNumber}'
                                '${range.isEmpty ? '' : ' pukul $range'}',
                          ].join(', '),
                          style: const TextStyle(
                            fontSize: 13,
                            color: NgColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (final d in widget.detail.days) ...[
              _DayOption(
                title:
                    'Hari ${d.dayNumber}, ${dayDateLabel(d.date, comma: false)}',
                subtitle: d.id == stop.dayId
                    ? 'Posisi sekarang'
                    : _daySummary(d),
                selected: d.id == _targetDayId,
                enabled: d.id != stop.dayId,
                onTap: () => setState(() => _targetDayId = d.id),
              ),
              const Divider(height: 1),
            ],
            const SizedBox(height: 12),
            Text(
              _moveNote(target),
              style: const TextStyle(fontSize: 13, color: NgColors.textMuted),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_targetDayId),
                child: Text('Pindahkan ke Hari ${target.dayNumber}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayOption extends StatelessWidget {
  const _DayOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? NgColors.teal : NgColors.textMuted;
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, color: color)),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: NgColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? NgColors.teal : NgColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog "Pindahkan ke Hari 3?" (desain).
Future<bool?> confirmMove(
  BuildContext context, {
  required TripStopModel stop,
  required TripDayModel fromDay,
  required TripDayModel toDay,
  required String? newStartTime,
}) {
  final time = newStartTime == null ? '' : ' pukul ${dotTimeOf(newStartTime)}';
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      icon: const Icon(Icons.drive_file_move_outline, color: NgColors.teal),
      title: Text('Pindahkan ke Hari ${toDay.dayNumber}?'),
      content: Text(
        '${stop.placeName} pindah dari ${dayDateLabel(fromDay.date)} ke '
        '${dayDateLabel(toDay.date)}$time.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Pindahkan'),
        ),
      ],
    ),
  );
}

// ============================================================= TAMBAH HARI

/// Bottom sheet "Tambah hari" (desain). [currentDays] = jumlah hari sekarang.
Future<bool?> confirmAddDay(
  BuildContext context, {
  required int currentDays,
  required DateTime? newDate,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHeader(
                title: 'Tambah hari',
                subtitle: 'Hari baru ditaruh setelah Hari $currentDays.',
              ),
              NgField(
                label: 'Nomor hari',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NgColors.cream,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: NgColors.fieldBorder),
                  ),
                  child: Text(
                    'Hari ${currentDays + 1}',
                    style: const TextStyle(color: NgColors.teal),
                  ),
                ),
              ),
              NgField(
                label: 'Tanggal perjalanan',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NgTapField(
                      icon: Icons.calendar_month_outlined,
                      text: newDate == null
                          ? 'Tanggal belum diatur'
                          : formatDateId(newDate),
                    ),
                    if (newDate != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Tanggal selesai trip ikut berubah jadi '
                        '${formatDateId(newDate, withWeekday: false)}.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: NgColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Tambah hari'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ========================================================= CATATAN JADWAL

/// Bottom sheet "Catatan jadwal" (desain, dibuka dari "Lihat saran").
/// Mengembalikan saran yang dipilih ("Terapkan"), atau null.
Future<ScheduleSuggestion?> showScheduleNotes(
  BuildContext context, {
  required ScheduleReport report,
}) {
  return showModalBottomSheet<ScheduleSuggestion>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHeader(
              title: 'Catatan jadwal',
              subtitle: 'Hanya peringatan. Perubahan tetap bisa disimpan.',
            ),
            for (final note in report.notes) ...[
              ScheduleNoteBox(note: note),
              const SizedBox(height: 12),
            ],
            if (report.suggestions.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Text(
                'Saran penyesuaian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: NgColors.teal,
                ),
              ),
              const SizedBox(height: 8),
              for (final s in report.suggestions)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        s.kind == SuggestionKind.shiftTime
                            ? Icons.schedule
                            : Icons.drive_file_move_outline,
                        color: NgColors.teal,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              style: const TextStyle(color: NgColors.teal),
                            ),
                            if (s.subtitle != null)
                              Text(
                                s.subtitle!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: NgColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(s),
                        child: const Text('Terapkan'),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Kotak catatan: merah (bentrok) atau kuning (padat). Dipakai di halaman
/// Customize (dengan "Lihat saran") dan di sheet "Catatan jadwal".
class ScheduleNoteBox extends StatelessWidget {
  const ScheduleNoteBox({
    super.key,
    required this.note,
    this.footer,
    this.onSeeSuggestions,
  });

  final ScheduleNote note;
  final String? footer;
  final VoidCallback? onSeeSuggestions;

  @override
  Widget build(BuildContext context) {
    final conflict = note.kind == ScheduleNoteKind.conflict;
    final bg = conflict ? NgColors.redSoft : NgColors.yellowSoft;
    final fg = conflict ? const Color(0xFFAC333A) : const Color(0xFF5C4400);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            conflict ? Icons.error_outline : Icons.warning_amber_rounded,
            size: 20,
            color: fg,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: fg),
                ),
                const SizedBox(height: 2),
                Text(
                  [...note.lines, if (footer != null) footer!].join(' '),
                  style: TextStyle(color: fg),
                ),
                if (onSeeSuggestions != null)
                  GestureDetector(
                    onTap: onSeeSuggestions,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Lihat saran',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================== BUANG PERUBAHAN

Future<bool?> confirmDiscardChanges(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Buang perubahan?'),
      content: const Text('Perubahan yang belum disimpan akan hilang.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Lanjut edit'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Buang'),
        ),
      ],
    ),
  );
}

// =============================================================== INFO TRIP

class TripInfoResult {
  const TripInfoResult({
    required this.title,
    required this.destination,
    required this.description,
    this.startDate,
    this.coverSource,
  });

  final String title;
  final String destination;
  final String description;

  /// Null jika tanggal keberangkatan tidak diubah.
  final DateTime? startDate;

  /// Path foto sampul baru dari galeri. Null jika sampul tidak diganti.
  final String? coverSource;
}

/// Halaman "Edit informasi trip" (desain), dibuka layar penuh.
Future<TripInfoResult?> askTripInfo(
  BuildContext context, {
  required TripModel trip,
}) {
  return Navigator.of(context).push<TripInfoResult>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _TripInfoPage(trip: trip),
    ),
  );
}

class _TripInfoPage extends StatefulWidget {
  const _TripInfoPage({required this.trip});

  final TripModel trip;

  @override
  State<_TripInfoPage> createState() => _TripInfoPageState();
}

class _TripInfoPageState extends State<_TripInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _destinationCtrl;
  late final TextEditingController _descCtrl;
  DateTime? _startDate;
  bool _dateChanged = false;
  String? _newCover;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.trip.title);
    _destinationCtrl = TextEditingController(text: widget.trip.destination);
    _descCtrl = TextEditingController(text: widget.trip.description);
    _startDate = widget.trip.startDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _destinationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final path = await pickPhotoFromGallery(context);
    if (path == null || !mounted) return;
    setState(() => _newCover = path);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _startDate ?? dateOnly(now);
    final futureLimit = now.add(const Duration(days: 730));
    final picked = await showDatePicker(
      context: context,
      helpText: 'Tanggal keberangkatan',
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: initial.isAfter(futureLimit) ? initial : futureLimit,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _startDate = dateOnly(picked);
      _dateChanged = true;
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      TripInfoResult(
        title: _titleCtrl.text,
        destination: _destinationCtrl.text,
        description: _descCtrl.text,
        startDate: _dateChanged ? _startDate : null,
        coverSource: _newCover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = _startDate;
    final days = widget.trip.durationDays;
    final end = (start != null && days > 0) ? dayDate(start, days - 1) : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: NgColors.cream,
        leading: IconButton(
          tooltip: 'Tutup',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: const Text('Edit informasi trip'),
        actions: [TextButton(onPressed: _submit, child: const Text('Simpan'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // ---- Sampul + "Ganti foto sampul"
            Stack(
              children: [
                NgImage(
                  source: _newCover ?? widget.trip.coverUrl,
                  width: double.infinity,
                  height: 190,
                  radius: 18,
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Material(
                    color: Colors.white,
                    shape: const StadiumBorder(),
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: _pickCover,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_camera_outlined,
                              size: 18,
                              color: NgColors.teal,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Ganti foto sampul',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: NgColors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            NgField(
              label: 'Judul',
              child: TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: NgColors.teal),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Judul trip wajib diisi'
                    : null,
              ),
            ),
            NgField(
              label: 'Destinasi',
              child: TextFormField(
                controller: _destinationCtrl,
                style: const TextStyle(color: NgColors.teal),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.place_outlined, color: NgColors.teal),
                ),
              ),
            ),
            NgField(
              label: 'Tanggal keberangkatan',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NgTapField(
                    icon: Icons.calendar_month_outlined,
                    text: start == null ? 'Pilih tanggal' : formatDateId(start),
                    trailing: const Icon(
                      Icons.expand_more,
                      color: NgColors.teal,
                    ),
                    onTap: _pickDate,
                  ),
                  if (end != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Trip selesai ${formatDateId(end)} ($days hari).',
                      style: const TextStyle(
                        fontSize: 13,
                        color: NgColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            NgField(
              label: 'Deskripsi',
              child: TextFormField(
                controller: _descCtrl,
                minLines: 3,
                maxLines: 6,
                style: const TextStyle(color: NgColors.teal),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: _submit, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}