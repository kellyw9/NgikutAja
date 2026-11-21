// ignore_for_file: prefer_initializing_formals

import '../utils/time_utils.dart';
import '../utils/trip_dates.dart';
import 'model_helpers.dart';
import 'trip_day_model.dart';
import 'trip_detail.dart';
import 'trip_photo_model.dart';
import 'trip_stop_model.dart';

/// Jeda (menit) antar aktivitas saat jam dihitung otomatis (pindah hari,
/// geser karena bentrok, drag and drop).
/// Desain: Hari 3 selesai 13.00, stop pindahan mulai 13.15.
/// TODO(KONFIRMASI): angka 15 menit diambil dari desain.
const int kMoveGapMinutes = 15;

/// Kesalahan input saat mengedit draft (nama kosong, jam tidak valid, dll).
class InvalidTripEditException implements Exception {
  final String message;
  const InvalidTripEditException(this.message);

  @override
  String toString() => message;
}

/// Validasi field stop. Mengembalikan pesan kesalahan, atau null jika valid.
/// Dipakai draft (sebelum simpan) dan repository (saat simpan).
/// Jadwal bentrok BUKAN kesalahan: bentrok hanya peringatan.
String? validateStopFields({
  required String placeName,
  String? startTime,
  int? durationMinutes,
  int? cost,
}) {
  if (placeName.trim().isEmpty) return 'Nama tempat wajib diisi';
  final start = parseHHmm(startTime);
  if (startTime != null && start == null) {
    return 'Format jam harus HH:mm, contoh 09:00';
  }
  if (durationMinutes != null && durationMinutes <= 0) {
    return 'Durasi harus lebih dari 0 menit';
  }
  if (start != null &&
      durationMinutes != null &&
      start + durationMinutes > kLastMinuteOfDay) {
    return 'Jadwal tidak boleh melewati pukul 23.59';
  }
  if (cost != null && cost < 0) return 'Biaya tidak boleh negatif';
  return null;
}

/// Satu perubahan jam hasil hitungan otomatis (untuk teks saran).
class TimeShift {
  const TimeShift({required this.stop, required this.newStartMinutes});

  final TripStopModel stop;
  final int newStartMinutes;
}

/// Salinan kerja trip di layar Customize.
///
/// Desain memakai pola "edit dulu, simpan sekaligus": semua perubahan
/// (stop, hari, info trip, sampul, foto) hanya mengubah draft ini. Data baru
/// tersimpan saat tombol "Simpan perubahan" memanggil
/// [TripRepository.saveTripDraft]. Jika simpan gagal, draft tetap utuh.
///
/// ATURAN URUTAN: `order` dalam satu hari mengikuti jam mulai; stop tanpa
/// jam paling akhir. Drag and drop TIDAK melanggar aturan ini: stop yang
/// digeser mendapat jam baru sesuai posisinya (lihat [reorderStop]).
class TripDraft {
  TripDraft._({
    required this.tripId,
    required this.baseUpdatedAt,
    required String title,
    required String destination,
    required String description,
    required DateTime? startDate,
    required String? coverUrl,
    required List<TripDayModel> days,
    required List<TripStopModel> stops,
    required List<TripPhotoModel> photos,
    required String Function(String prefix) newId,
  }) : _title = title,
       _destination = destination,
       _description = description,
       _startDate = startDate,
       _coverUrl = coverUrl,
       _days = days,
       _stops = stops,
       _photos = photos,
       _newId = newId;

  /// [newId] bisa diganti untuk tes. Default: ID sementara berbasis waktu.
  factory TripDraft.fromDetail(
    TripDetail detail, {
    String Function(String prefix)? newId,
  }) {
    final trip = detail.trip;
    final days = [...detail.days]
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return TripDraft._(
      tripId: trip.id,
      baseUpdatedAt: trip.updatedAt,
      title: trip.title,
      destination: trip.destination,
      description: trip.description,
      startDate: trip.startDate,
      coverUrl: trip.coverUrl,
      days: days,
      stops: [...detail.stops],
      photos: [...detail.photos],
      newId: newId ?? _defaultNewId,
    );
  }

  final String tripId;

  /// `updatedAt` trip saat draft dibuat. Repository menolak simpan jika
  /// trip sudah diubah orang lain sejak itu (penting untuk Shared Trip).
  final DateTime? baseUpdatedAt;

  final String Function(String prefix) _newId;
  String _title;
  String _destination;
  String _description;
  DateTime? _startDate;
  String? _coverUrl;
  final List<TripDayModel> _days; // selalu urut dayNumber
  final List<TripStopModel> _stops;
  final List<TripPhotoModel> _photos;

  static int _idCounter = 0;

  /// TODO(FIRESTORE): ganti dengan `collection.doc().id`.
  static String _defaultNewId(String prefix) {
    _idCounter++;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }

  /// Nilai `order` sementara agar stop baru/pindahan berada setelah stop
  /// lain dengan jam yang sama.
  static const int _lateOrder = 1 << 20;

  // ------------------------------------------------------------------ BACA

  String get title => _title;
  String get destination => _destination;
  String get description => _description;
  DateTime? get startDate => _startDate;
  String? get coverUrl => _coverUrl;

  List<TripDayModel> get days => List.unmodifiable(_days);
  List<TripStopModel> get stops => List.unmodifiable(_stops);
  List<TripPhotoModel> get photos => List.unmodifiable(_photos);

  /// Tanggal pulang (tidak disimpan).
  DateTime? get endDate {
    final start = _startDate;
    if (start == null || _days.isEmpty) return null;
    return dayDate(start, _days.length - 1);
  }

  List<TripStopModel> stopsOfDay(String dayId) {
    final result = _stops.where((s) => s.dayId == dayId).toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  // ------------------------------------------------------------------ STOP

  /// Mengembalikan stop baru (id dipakai untuk menempelkan foto).
  TripStopModel addStop({
    required String dayId,
    required String placeName,
    String description = '',
    String? category,
    String? startTime,
    int? durationMinutes,
    int? cost,
    String? note,
  }) {
    _requireDay(dayId);
    _check(
      validateStopFields(
        placeName: placeName,
        startTime: startTime,
        durationMinutes: durationMinutes,
        cost: cost,
      ),
    );
    final now = DateTime.now();
    final stop = TripStopModel(
      id: _newId('stop'),
      tripId: tripId,
      dayId: dayId,
      placeName: placeName.trim(),
      description: description,
      order: _lateOrder,
      category: category,
      startTime: startTime,
      durationMinutes: durationMinutes,
      cost: cost,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
    _stops.add(stop);
    _normalize(dayId);
    return _requireStop(stop.id);
  }

  /// Semua field yang bisa diedit dikirim lengkap: null berarti dikosongkan.
  /// `dayId` tidak berubah (gunakan [moveStop]).
  TripStopModel updateStop({
    required String stopId,
    required String placeName,
    String description = '',
    String? category,
    String? startTime,
    int? durationMinutes,
    int? cost,
    String? note,
  }) {
    final current = _requireStop(stopId);
    _check(
      validateStopFields(
        placeName: placeName,
        startTime: startTime,
        durationMinutes: durationMinutes,
        cost: cost,
      ),
    );
    _replace(
      _rebuild(
        current,
        placeName: placeName.trim(),
        description: description,
        category: category,
        startTime: startTime,
        durationMinutes: durationMinutes,
        cost: cost,
        note: note,
      ),
    );
    _normalize(current.dayId);
    return _requireStop(stopId);
  }

  /// Menghapus stop beserta foto-fotonya.
  void deleteStop(String stopId) {
    final stop = _requireStop(stopId);
    _stops.removeWhere((s) => s.id == stopId);
    _photos.removeWhere((p) => p.stopId == stopId);
    _normalize(stop.dayId);
  }

  // ---------------------------------------------------------- PINDAH HARI

  /// Jam mulai stop jika dipindah ke [targetDayId], untuk teks dialog
  /// ("Masuk di urutan terakhir Hari 3, mulai 13.15").
  ///
  /// Aturan: mulai = jam selesai paling akhir di hari tujuan + [kMoveGapMinutes].
  /// Jam lama DIPERTAHANKAN jika hari tujuan belum punya stop berjam, atau
  /// jam baru + durasi melewati 23:59.
  /// TODO(KONFIRMASI): dua pengecualian di atas belum ada di desain.
  String? previewMoveStartTime({
    required String stopId,
    required String targetDayId,
  }) {
    _requireDay(targetDayId);
    final moving = _requireStop(stopId);
    if (moving.dayId == targetDayId) return moving.startTime;

    final lastEnd = _lastEnd(
      _stops.where((s) => s.dayId == targetDayId),
    );
    if (lastEnd == null) return moving.startTime;

    final candidate = lastEnd + kMoveGapMinutes;
    if (candidate + (moving.durationMinutes ?? 0) > kLastMinuteOfDay) {
      return moving.startTime;
    }
    return _toHHmm(candidate);
  }

  /// Memindahkan stop ke hari lain. Jam mulai mengikuti [previewMoveStartTime].
  TripStopModel moveStop({
    required String stopId,
    required String targetDayId,
  }) {
    final moving = _requireStop(stopId);
    if (moving.dayId == targetDayId) return moving;
    final newStart = previewMoveStartTime(
      stopId: stopId,
      targetDayId: targetDayId,
    );
    final fromDayId = moving.dayId;
    _replace(
      _rebuild(
        moving,
        dayId: targetDayId,
        startTime: newStart,
        order: _lateOrder,
      ),
    );
    _normalize(targetDayId);
    _normalize(fromDayId);
    return _requireStop(stopId);
  }

  // ------------------------------------------------- GESER JAM (+ BERUNTUN)

  /// Pratinjau menggeser [stopId] ke [newStartMinutes]. Stop berikutnya di
  /// hari yang sama yang jadi tumpang tindih ikut mundur (selesai stop
  /// sebelumnya + [kMoveGapMinutes]). Contoh desain: Mie Aceh digeser ke
  /// 14.45, Kesawan ikut mundur ke 16.00.
  ///
  /// Mengembalikan daftar perubahan (stop yang digeser lebih dulu), atau null
  /// jika ada jadwal yang akan melewati 23:59.
  List<TimeShift>? previewShift(String stopId, int newStartMinutes) {
    final target = _requireStop(stopId);
    if (newStartMinutes < 0) newStartMinutes = 0;
    final shifts = <TimeShift>[
      TimeShift(stop: target, newStartMinutes: newStartMinutes),
    ];
    var cursorEnd = newStartMinutes + (target.durationMinutes ?? 0);
    if (cursorEnd > kLastMinuteOfDay) return null;

    final others = _stops
        .where((s) => s.dayId == target.dayId && s.id != stopId)
        .where((s) => parseHHmm(s.startTime) != null)
        .toList()
      ..sort(
        (a, b) => parseHHmm(a.startTime)!.compareTo(parseHHmm(b.startTime)!),
      );

    for (final s in others) {
      final start = parseHHmm(s.startTime)!;
      if (start < newStartMinutes) continue; // sebelum stop yang digeser
      if (start >= cursorEnd) break; // tidak tumpang tindih lagi
      final shifted = cursorEnd + kMoveGapMinutes;
      final end = shifted + (s.durationMinutes ?? 0);
      if (end > kLastMinuteOfDay) return null;
      shifts.add(TimeShift(stop: s, newStartMinutes: shifted));
      cursorEnd = end;
    }
    return shifts;
  }

  /// Menerapkan [previewShift]. Throw jika jadwal tidak muat.
  void shiftStop(String stopId, int newStartMinutes) {
    final shifts = previewShift(stopId, newStartMinutes);
    if (shifts == null) {
      throw const InvalidTripEditException(
        'Jadwal tidak muat, akan melewati pukul 23.59',
      );
    }
    for (final shift in shifts) {
      final current = _requireStop(shift.stop.id);
      _replace(
        _rebuild(current, startTime: _toHHmm(shift.newStartMinutes)),
      );
    }
    _normalize(_requireStop(stopId).dayId);
  }

  // -------------------------------------------------------- DRAG AND DROP

  /// Drag and drop dalam satu hari. [newIndex] = posisi akhir (0 = paling atas)
  /// setelah stop diangkat dari posisi lamanya.
  ///
  /// Karena urutan selalu mengikuti jam, stop yang digeser mendapat jam baru:
  /// - ada stop berjam di atasnya: selesai stop itu + [kMoveGapMinutes];
  /// - paling atas: mulai stop di bawahnya - durasi - [kMoveGapMinutes];
  /// stop di bawahnya yang jadi tumpang tindih ikut mundur ([previewShift]).
  /// Stop tanpa jam, atau hari tanpa jam sama sekali, tidak bisa digeser.
  /// TODO(KONFIRMASI): aturan jam setelah drag and drop belum disepakati tim.
  void reorderStop(String stopId, int newIndex) {
    final moving = _requireStop(stopId);
    final list = stopsOfDay(moving.dayId)..removeWhere((s) => s.id == stopId);
    if (newIndex < 0) newIndex = 0;
    if (newIndex > list.length) newIndex = list.length;

    final above = newIndex > 0 ? list[newIndex - 1] : null;
    final below = newIndex < list.length ? list[newIndex] : null;
    final duration = moving.durationMinutes ?? 0;

    int? newStart;
    final aboveStart = parseHHmm(above?.startTime);
    final belowStart = parseHHmm(below?.startTime);
    if (above != null && aboveStart != null) {
      newStart = aboveStart + (above.durationMinutes ?? 0) + kMoveGapMinutes;
    } else if (above == null && belowStart != null) {
      newStart = belowStart - duration - kMoveGapMinutes;
      if (newStart < 0) newStart = 0;
    }

    if (newStart == null) {
      throw const InvalidTripEditException(
        'Isi jam mulai dulu agar aktivitas bisa digeser.',
      );
    }
    shiftStop(stopId, newStart);
  }

  // ------------------------------------------------------------------ HARI

  /// Menambah satu hari kosong di akhir trip (tanggal pulang ikut maju).
  TripDayModel addDay() {
    if (_days.length >= kMaxTripDays) {
      throw const InvalidTripEditException('Trip maksimal $kMaxTripDays hari');
    }
    final start = _startDate;
    final day = TripDayModel(
      id: _newId('day'),
      tripId: tripId,
      dayNumber: _days.length + 1,
      date: start == null ? null : dayDate(start, _days.length),
    );
    _days.add(day);
    return day;
  }

  // ------------------------------------------------------------------ INFO

  /// Desain "Edit informasi trip": judul, destinasi, tanggal keberangkatan,
  /// deskripsi. Jumlah hari TIDAK berubah; tanggal tiap hari ikut bergeser.
  /// [startDate] null berarti tanggal tidak diubah.
  void updateInfo({
    required String title,
    required String destination,
    required String description,
    DateTime? startDate,
  }) {
    if (title.trim().isEmpty) {
      throw const InvalidTripEditException('Judul trip wajib diisi');
    }
    _title = title.trim();
    _destination = destination.trim();
    _description = description;
    if (startDate != null) {
      final start = dateOnly(startDate);
      _startDate = start;
      for (var i = 0; i < _days.length; i++) {
        _days[i] = _days[i].copyWith(date: dayDate(start, i));
      }
    }
  }

  // ------------------------------------------------------------------ FOTO

  /// Mengganti sampul trip. [source] = path file lokal (dari galeri) atau URL.
  /// TODO(FIRESTORE): file lokal diunggah ke Storage saat simpan.
  void setCover(String source) {
    if (source.trim().isEmpty) {
      throw const InvalidTripEditException('Foto sampul tidak valid');
    }
    _coverUrl = source;
  }

  /// Menambah foto ke trip ([stopId] null = "Foto trip") atau ke satu stop.
  /// Visibilitas default `trip_only` (aman: tidak ikut tersalin saat Adopt).
  /// TODO(KONFIRMASI): pilihan public/trip_only belum ada di desain.
  TripPhotoModel addPhoto({
    required String source,
    required String uploadedBy,
    String? stopId,
  }) {
    if (stopId != null) _requireStop(stopId);
    if (source.trim().isEmpty) {
      throw const InvalidTripEditException('Foto tidak valid');
    }
    final photo = TripPhotoModel.fromMap(_newId('photo'), {
      'tripId': tripId,
      'stopId': stopId,
      'uploadedBy': uploadedBy,
      'photoUrl': source,
      'visibility': 'trip_only',
      'createdAt': dateToStorage(DateTime.now()),
    });
    _photos.add(photo);
    return photo;
  }

  void removePhoto(String photoId) {
    final before = _photos.length;
    _photos.removeWhere((p) => p.id == photoId);
    if (_photos.length == before) {
      throw const InvalidTripEditException('Foto tidak ditemukan');
    }
  }

  // ---------------------------------------------------------------- URUTAN

  /// Mengurutkan stop SATU hari berdasarkan jam lalu memberi nomor 1..n.
  /// Stop tanpa jam (atau jam tidak valid) paling akhir. Jam sama: urutan
  /// lama, lalu id (List.sort Dart tidak dijamin stabil).
  /// Dipakai juga oleh repository (Adopt dan simpan).
  static List<TripStopModel> scheduleDay(List<TripStopModel> stops) {
    final sorted = [...stops];
    sorted.sort((a, b) {
      final ta = parseHHmm(a.startTime);
      final tb = parseHHmm(b.startTime);
      if (ta != null && tb != null) {
        final byTime = ta.compareTo(tb);
        if (byTime != 0) return byTime;
      } else if (ta != null) {
        return -1;
      } else if (tb != null) {
        return 1;
      }
      final byOrder = a.order.compareTo(b.order);
      if (byOrder != 0) return byOrder;
      return a.id.compareTo(b.id);
    });
    final now = DateTime.now();
    return [
      for (var i = 0; i < sorted.length; i++)
        sorted[i].order == i + 1
            ? sorted[i]
            : sorted[i].copyWith(order: i + 1, updatedAt: now),
    ];
  }

  // ---------------------------------------------------------------- HELPER

  static int? _lastEnd(Iterable<TripStopModel> stops) {
    int? last;
    for (final s in stops) {
      final start = parseHHmm(s.startTime);
      if (start == null) continue;
      final end = start + (s.durationMinutes ?? 0);
      if (last == null || end > last) last = end;
    }
    return last;
  }

  void _normalize(String dayId) {
    final scheduled = {
      for (final s in scheduleDay(
        _stops.where((s) => s.dayId == dayId).toList(),
      ))
        s.id: s,
    };
    for (var i = 0; i < _stops.length; i++) {
      final replacement = scheduled[_stops[i].id];
      if (replacement != null) _stops[i] = replacement;
    }
  }

  void _replace(TripStopModel stop) {
    final index = _stops.indexWhere((s) => s.id == stop.id);
    if (index >= 0) _stops[index] = stop;
  }

  /// Membuat ulang stop secara langsung (bukan copyWith) agar field
  /// nullable bisa dikosongkan. location dan createdAt dipertahankan.
  TripStopModel _rebuild(
    TripStopModel s, {
    String? dayId,
    String? placeName,
    String? description,
    int? order,
    Object? category = _keep,
    Object? startTime = _keep,
    Object? durationMinutes = _keep,
    Object? cost = _keep,
    Object? note = _keep,
  }) {
    return TripStopModel(
      id: s.id,
      tripId: s.tripId,
      dayId: dayId ?? s.dayId,
      placeName: placeName ?? s.placeName,
      description: description ?? s.description,
      location: s.location,
      order: order ?? s.order,
      category: identical(category, _keep) ? s.category : category as String?,
      startTime: identical(startTime, _keep)
          ? s.startTime
          : startTime as String?,
      durationMinutes: identical(durationMinutes, _keep)
          ? s.durationMinutes
          : durationMinutes as int?,
      cost: identical(cost, _keep) ? s.cost : cost as int?,
      note: identical(note, _keep) ? s.note : note as String?,
      createdAt: s.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static const Object _keep = Object();

  TripDayModel _requireDay(String dayId) {
    for (final d in _days) {
      if (d.id == dayId) return d;
    }
    throw const InvalidTripEditException('Hari tidak ditemukan pada trip ini');
  }

  TripStopModel _requireStop(String stopId) {
    for (final s in _stops) {
      if (s.id == stopId) return s;
    }
    throw const InvalidTripEditException(
      'Aktivitas tidak ditemukan pada trip ini',
    );
  }

  void _check(String? error) {
    if (error != null) throw InvalidTripEditException(error);
  }

  /// Format penyimpanan 'HH:mm' (titik "13.15" hanya untuk tampilan).
  static String _toHHmm(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}