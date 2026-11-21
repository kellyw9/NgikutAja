import 'package:flutter/foundation.dart';

import '../models/trip_detail.dart';
import '../models/trip_draft.dart';
import '../models/trip_photo_model.dart';
import '../repositories/trip_repository.dart';
import '../services/auth_bridge.dart';
import '../utils/schedule_notes.dart';
import '../utils/trip_permissions.dart';
import 'safe_notifier.dart';

/// State halaman Customize.
///
/// Pola "edit dulu, simpan sekaligus" (desain): semua operasi hanya mengubah
/// [TripDraft] di memori. Data baru tersimpan saat [save] dipanggil
/// (tombol "Simpan" / "Simpan perubahan"). Jika simpan gagal, perubahan
/// tetap ada di layar.
class CustomizeViewModel extends ChangeNotifier with SafeNotifier {
  CustomizeViewModel({
    required AuthBridge authBridge,
    required TripRepository tripRepository,
  }) : _auth = authBridge,
       _repo = tripRepository;

  final AuthBridge _auth;
  final TripRepository _repo;

  /// Kalimat penutup banner jadwal bentrok (desain).
  static const String scheduleWarningFooter = 'Tetap bisa disimpan.';

  String? _tripId;
  TripDetail? _saved; // versi tersimpan terakhir dari repository
  TripDraft? _draft; // salinan kerja
  TripDetail? _preview; // tampilan dari draft
  bool _dirty = false;

  ScheduleReport _report = ScheduleReport.empty;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _loadErrorMessage;
  String? _errorMessage;
  String? _successMessage;

  /// Isi trip yang DITAMPILKAN (sudah termasuk perubahan yang belum disimpan).
  TripDetail? get detail => _preview;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  /// True jika ada perubahan yang belum disimpan (untuk konfirmasi keluar).
  bool get hasUnsavedChanges => _dirty;

  /// Error saat memuat trip (halaman tidak bisa ditampilkan).
  String? get loadErrorMessage => _loadErrorMessage;

  /// Error dari operasi terakhir (tampilkan sebagai snackbar/banner).
  String? get errorMessage => _errorMessage;

  /// Pesan berhasil. Hanya terisi setelah penyimpanan benar-benar berhasil.
  String? get successMessage => _successMessage;

  bool get canEdit {
    final d = _saved;
    return d != null && TripPermissions.canEdit(d.trip, _auth.currentUserId);
  }

  // ------------------------------------------------------ CATATAN JADWAL

  /// Semua catatan (bentrok + padat) dan saran untuk sheet "Catatan jadwal".
  ScheduleReport get scheduleReport => _report;

  List<ScheduleNote> notesOfDay(String dayId) => _report.notesOfDay(dayId);

  bool get hasScheduleWarnings => _report.notes.isNotEmpty;

  /// True jika stop ini bertumpang tindih dengan stop lain di harinya.
  bool hasConflict(String stopId) =>
      _report.conflictedStopIds.contains(stopId);

  /// Menerapkan satu saran ("Terapkan").
  bool applySuggestion(ScheduleSuggestion s) {
    switch (s.kind) {
      case SuggestionKind.shiftTime:
        final start = s.newStartMinutes;
        if (start == null) return false;
        return _edit((d) => d.shiftStop(s.stopId, start));
      case SuggestionKind.moveToDay:
        final target = s.targetDayId;
        if (target == null) return false;
        return _edit(
          (d) => d.moveStop(stopId: s.stopId, targetDayId: target),
        );
    }
  }

  void clearMessages() {
    if (_errorMessage == null && _successMessage == null) return;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------- MUAT

  Future<void> load(String tripId) async {
    _tripId = tripId;

    // TODO(AUTH): UID dan status login dari AuthBridge asli (Anggota 1).
    final userId = _auth.currentUserId;
    if (!_auth.isLoggedIn || userId == null) {
      _clearTrip();
      _loadErrorMessage = 'Silakan login terlebih dahulu';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _loadErrorMessage = null;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _startDraft(await _repo.getTripDetail(userId: userId, tripId: tripId));
    } on TripNotFoundException {
      _clearTrip();
      _loadErrorMessage = 'Trip tidak ditemukan';
    } on TripAccessDeniedException {
      _clearTrip();
      _loadErrorMessage = 'Kamu tidak memiliki akses ke trip ini';
    } catch (_) {
      _clearTrip();
      _loadErrorMessage = 'Gagal memuat trip. Periksa koneksi lalu coba lagi.';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Membuang semua perubahan yang belum disimpan.
  void discardChanges() {
    final saved = _saved;
    if (saved == null || _isSaving) return;
    _startDraft(saved);
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ------------------------------------------- OPERASI (BELUM TERSIMPAN)
  // Data BELUM tersimpan sampai [save] dipanggil.

  /// Mengembalikan id stop baru, atau null jika gagal (lihat [errorMessage]).
  String? addStop({
    required String dayId,
    required String placeName,
    String description = '',
    String? category,
    String? startTime,
    int? durationMinutes,
    int? cost,
    String? note,
  }) {
    String? newId;
    final ok = _edit((d) {
      newId = d
          .addStop(
            dayId: dayId,
            placeName: placeName,
            description: description.trim(),
            category: _blankToNull(category),
            startTime: _blankToNull(startTime),
            durationMinutes: durationMinutes,
            cost: cost,
            note: _blankToNull(note),
          )
          .id;
    });
    return ok ? newId : null;
  }

  /// Semua field dikirim lengkap: null/kosong berarti dikosongkan.
  bool updateStop({
    required String stopId,
    required String placeName,
    String description = '',
    String? category,
    String? startTime,
    int? durationMinutes,
    int? cost,
    String? note,
  }) {
    return _edit(
      (d) => d.updateStop(
        stopId: stopId,
        placeName: placeName,
        description: description.trim(),
        category: _blankToNull(category),
        startTime: _blankToNull(startTime),
        durationMinutes: durationMinutes,
        cost: cost,
        note: _blankToNull(note),
      ),
    );
  }

  bool deleteStop(String stopId) => _edit((d) => d.deleteStop(stopId));

  /// Drag and drop dalam satu hari (lihat [TripDraft.reorderStop]).
  bool reorderStop(String stopId, int newIndex) =>
      _edit((d) => d.reorderStop(stopId, newIndex));

  /// Jam mulai baru jika stop dipindah (untuk teks dialog "mulai 13.15").
  String? previewMoveStartTime({
    required String stopId,
    required String targetDayId,
  }) {
    try {
      return _draft?.previewMoveStartTime(
        stopId: stopId,
        targetDayId: targetDayId,
      );
    } on InvalidTripEditException {
      return null;
    }
  }

  bool moveStop({required String stopId, required String targetDayId}) {
    return _edit(
      (d) => d.moveStop(stopId: stopId, targetDayId: targetDayId),
    );
  }

  /// Desain "Edit informasi trip". Jumlah hari tidak berubah.
  /// [startDate] null = tanggal tidak diubah; [coverSource] null = sampul tetap.
  bool updateTripInfo({
    required String title,
    required String destination,
    required String description,
    DateTime? startDate,
    String? coverSource,
  }) {
    return _edit((d) {
      d.updateInfo(
        title: title,
        destination: destination,
        description: description.trim(),
        startDate: startDate,
      );
      if (coverSource != null) d.setCover(coverSource);
    });
  }

  /// Menambah satu hari kosong di akhir trip.
  bool addDay() => _edit((d) => d.addDay());

  // ------------------------------------------------------------------ FOTO

  /// Foto "Foto trip" (tidak terikat stop).
  List<TripPhotoModel> get tripPhotos => [
    for (final p in _preview?.photos ?? const <TripPhotoModel>[])
      if (p.stopId == null) p,
  ];

  List<TripPhotoModel> photosOfStop(String stopId) => [
    for (final p in _preview?.photos ?? const <TripPhotoModel>[])
      if (p.stopId == stopId) p,
  ];

  /// [source] = path file dari galeri. [stopId] null = foto trip.
  bool addPhoto({required String source, String? stopId}) {
    final userId = _auth.currentUserId ?? '';
    return _edit(
      (d) => d.addPhoto(source: source, uploadedBy: userId, stopId: stopId),
    );
  }

  bool removePhoto(String photoId) => _edit((d) => d.removePhoto(photoId));

  // ---------------------------------------------------------------- SIMPAN

  /// Menyimpan semua perubahan sekaligus.
  Future<bool> save() async {
    if (_isSaving) return false;

    // TODO(AUTH): UID dan status login dari AuthBridge asli (Anggota 1).
    final userId = _auth.currentUserId;
    final tripId = _tripId;
    final draft = _draft;
    if (!_auth.isLoggedIn || userId == null || tripId == null) {
      _errorMessage = 'Silakan login terlebih dahulu';
      notifyListeners();
      return false;
    }
    if (draft == null) return false;
    if (!canEdit) {
      _errorMessage = 'Tidak memiliki izin untuk mengedit trip ini';
      notifyListeners();
      return false;
    }
    if (!_dirty) return true; // tidak ada yang perlu disimpan

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    var saved = false;
    try {
      final fresh = await _repo.saveTripDraft(
        userId: userId,
        tripId: tripId,
        draft: draft,
      );
      _startDraft(fresh);
      // TODO(KONFIRMASI): desain menambahkan "Pengingat ikut diperbarui."
      // Tambahkan setelah fitur pengingat dibuat.
      _successMessage = 'Perubahan tersimpan.';
      saved = true;
    } on TripConflictException {
      _errorMessage =
          'Trip ini baru saja diubah di tempat lain. Perubahanmu belum '
          'tersimpan. Muat ulang untuk melihat versi terbaru.';
    } on TripAccessDeniedException {
      _errorMessage = 'Tidak memiliki izin untuk mengedit trip ini';
    } on TripNotFoundException {
      _errorMessage = 'Trip tidak ditemukan';
    } on InvalidTripOperationException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Gagal menyimpan. Perubahanmu masih ada di layar.';
    }

    _isSaving = false;
    notifyListeners();
    return saved;
  }

  // -------------------------------------------------------------- INTERNAL

  bool _edit(void Function(TripDraft draft) change) {
    final draft = _draft;
    if (draft == null || _isSaving) return false;
    if (!canEdit) {
      _errorMessage = 'Tidak memiliki izin untuk mengedit trip ini';
      notifyListeners();
      return false;
    }
    try {
      // Operasi draft memvalidasi dulu sebelum mengubah data.
      change(draft);
    } on InvalidTripEditException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
    _dirty = true;
    _errorMessage = null;
    _successMessage = null;
    _refreshPreview();
    notifyListeners();
    return true;
  }

  void _startDraft(TripDetail detail) {
    _saved = detail;
    _draft = TripDraft.fromDetail(detail);
    _dirty = false;
    _refreshPreview();
  }

  void _clearTrip() {
    _saved = null;
    _draft = null;
    _preview = null;
    _dirty = false;
    _report = ScheduleReport.empty;
  }

  /// Menyusun tampilan dari draft dan menghitung ulang catatan jadwal.
  void _refreshPreview() {
    final saved = _saved;
    final draft = _draft;
    if (saved == null || draft == null) return;

    final stops = draft.stops;
    _preview = TripDetail(
      trip: saved.trip.copyWith(
        title: draft.title,
        destination: draft.destination,
        description: draft.description,
        startDate: draft.startDate,
        durationDays: draft.days.length,
        stopCount: stops.length,
        coverUrl: draft.coverUrl,
      ),
      days: draft.days,
      stops: stops,
      photos: draft.photos,
    );
    _report = buildScheduleReport(draft);
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}