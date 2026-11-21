// ignore_for_file: prefer_initializing_formals
// Parameter named bertipe private (`this._x`) belum tentu didukung versi Dart
// proyek ini, jadi field diisi lewat initializer list.

import '../models/adopt_result.dart';
import '../models/model_helpers.dart';
import '../models/trip_day_model.dart';
import '../models/trip_detail.dart';
import '../models/trip_draft.dart';
import '../models/trip_model.dart';
import '../models/trip_photo_model.dart';
import '../models/trip_stop_model.dart';
import '../services/payment_checker.dart';
import '../utils/trip_dates.dart';
import 'itinerary_source_repository.dart';
import 'trip_repository.dart';

/// Implementasi SEMENTARA di memori. Gantikan dengan FirestoreTripRepository
/// setelah struktur Firestore final dan Firebase terpasang.
class MockTripRepository implements TripRepository {
  MockTripRepository({
    required ItinerarySourceRepository sourceRepository,
    required PaymentChecker paymentChecker,
  }) : _sourceRepository = sourceRepository,
       _paymentChecker = paymentChecker;

  final ItinerarySourceRepository _sourceRepository;
  final PaymentChecker _paymentChecker;

  // ALAT UJI (HAPUS SETELAH SELESAI DICOBA): jika true, Adopt berikutnya
  // sengaja gagal setelah data ditulis, untuk menguji pembersihan data parsial.
  bool failNextAdoptAfterWrite = false;

  // ALAT UJI (HAPUS SETELAH SELESAI DICOBA): jika true, simpan Customize
  // berikutnya sengaja gagal, untuk menguji pesan "Gagal menyimpan".
  bool failNextSave = false;

  // ALAT UJI (HAPUS SETELAH SELESAI DICOBA): jumlah dokumen trip di memori,
  // termasuk yang berstatus `copying`.
  int get debugTripCount => _trips.length;

  // Penyimpanan di memori, dipisah per tripId.
  final Map<String, TripModel> _trips = {};
  final Map<String, List<TripDayModel>> _days = {};
  final Map<String, List<TripStopModel>> _stops = {};
  final Map<String, List<TripPhotoModel>> _photos = {};

  // Pencegah double tap: satu requestId hanya diproses satu kali.
  final Map<String, Future<AdoptResult>> _adoptRequests = {};

  int _idCounter = 0;

  /// ID unik sementara. Di Firestore gunakan `collection.doc().id`.
  String _newId(String prefix) {
    _idCounter++;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }

  Future<void> _fakeDelay() =>
      Future<void>.delayed(const Duration(milliseconds: 300));

  // ---------------------------------------------------------------- ADOPT

  @override
  Future<AdoptResult> adoptItinerary({
    required String userId,
    required String itineraryId,
    required DateTime startDate,
    required String requestId,
  }) async {
    if (userId.isEmpty) return AdoptResult.failed(AdoptFailure.notLoggedIn);

    final key = '$userId|$requestId';
    final running = _adoptRequests[key];
    if (running != null) return running;

    final future = _guardedAdopt(
      userId: userId,
      itineraryId: itineraryId,
      startDate: startDate,
    );
    _adoptRequests[key] = future;
    final result = await future;
    // Jika gagal, requestId yang sama boleh dicoba lagi.
    if (!result.isSuccess) _adoptRequests.remove(key);
    return result;
  }

  /// Memastikan exception apa pun (sumber, pembayaran, penyalinan)
  /// berubah menjadi hasil gagal, bukan exception yang lolos ke pemanggil.
  Future<AdoptResult> _guardedAdopt({
    required String userId,
    required String itineraryId,
    required DateTime startDate,
  }) async {
    try {
      return await _runAdopt(
        userId: userId,
        itineraryId: itineraryId,
        startDate: startDate,
      );
    } catch (e) {
      return AdoptResult.failed(AdoptFailure.unknown, detail: '$e');
    }
  }

  Future<AdoptResult> _runAdopt({
    required String userId,
    required String itineraryId,
    required DateTime startDate,
  }) async {
    await _fakeDelay();

    final source = await _sourceRepository.getItinerary(itineraryId);
    if (source == null) {
      return AdoptResult.failed(AdoptFailure.itineraryNotFound);
    }

    // TODO(PAYMENT): verifikasi asli harus dari backend (Anggota 6).
    if (source.price > 0) {
      final paid = await _paymentChecker.hasPaid(
        userId: userId,
        itineraryId: itineraryId,
      );
      if (!paid) return AdoptResult.failed(AdoptFailure.paymentRequired);
    }

    final creatorId = source.data['creatorId'] as String?;
    if (source.days.isEmpty || creatorId == null || creatorId.isEmpty) {
      return AdoptResult.failed(
        AdoptFailure.sourceIncomplete,
        detail: 'hari kosong atau creatorId tidak ada',
      );
    }

    final departure = dateOnly(startDate);
    final sourceDays = [...source.days]
      ..sort(
        (a, b) =>
            _intOf(a.data['dayNumber']).compareTo(_intOf(b.data['dayNumber'])),
      );

    // Jumlah hari salinan = jumlah hari sumber.
    final totalDays = sourceDays.length;
    if (totalDays > kMaxTripDays) {
      return AdoptResult.failed(
        AdoptFailure.invalidDates,
        detail: 'jumlah hari $totalDays melebihi batas $kMaxTripDays',
      );
    }

    final tripId = _newId('trip');
    try {
      final now = DateTime.now();

      final dayIds = [for (var i = 0; i < totalDays; i++) _newId('day')];
      final newDays = <TripDayModel>[
        for (var i = 0; i < totalDays; i++)
          TripDayModel(
            id: dayIds[i],
            tripId: tripId,
            dayNumber: i + 1,
            date: dayDate(departure, i),
          ),
      ];

      final stopIdMap = <String, String>{}; // id stop sumber -> id stop salinan
      final newStops = <TripStopModel>[];

      for (var i = 0; i < totalDays; i++) {
        final sourceStops = [...sourceDays[i].stops]
          ..sort(
            (a, b) =>
                _intOf(a.data['order']).compareTo(_intOf(b.data['order'])),
          );

        final bucket = <TripStopModel>[];
        for (final sourceStop in sourceStops) {
          final newStopId = _newId('stop');
          stopIdMap[sourceStop.id] = newStopId;

          final map = Map<String, dynamic>.from(sourceStop.data)
            ..['tripId'] = tripId
            ..['dayId'] = dayIds[i]
            ..['createdAt'] = dateToStorage(now)
            ..['updatedAt'] = dateToStorage(now);
          bucket.add(
            TripStopModel.fromMap(
              newStopId,
              map,
            ).copyWith(order: bucket.length + 1),
          );
        }
        // Urutan salinan mengikuti jam mulai.
        newStops.addAll(TripDraft.scheduleDay(bucket));
      }

      // Status awal `copying`: trip belum tampil di Trip Saya.
      final trip = TripModel(
        id: tripId,
        title: (source.data['title'] as String?) ?? '',
        description: (source.data['description'] as String?) ?? '',
        destination: (source.data['destination'] as String?) ?? '',
        durationDays: totalDays,
        ownerId: userId,
        creatorId: creatorId,
        creatorName: source.data['creatorName'] as String?,
        creatorUsername: source.data['creatorUsername'] as String?,
        coverUrl: source.data['coverUrl'] as String?,
        parentId: source.id,
        startDate: departure,
        tripStatus: TripStatus.copying,
        stopCount: newStops.length,
        createdAt: now,
        updatedAt: now,
      );

      // Hanya foto public yang disalin. Foto trip_only TIDAK ikut.
      final newPhotos = <TripPhotoModel>[];
      for (final sourcePhoto in source.photos) {
        final photo = TripPhotoModel.fromMap(sourcePhoto.id, sourcePhoto.data);
        if (!photo.isCopyableOnAdopt) continue;
        final oldStopId = photo.stopId;
        newPhotos.add(
          TripPhotoModel(
            id: _newId('photo'),
            tripId: tripId,
            stopId: oldStopId == null ? null : stopIdMap[oldStopId],
            uploadedBy: photo.uploadedBy, // metadata internal dipertahankan
            photoUrl: photo.photoUrl,
            // TODO(KONFIRMASI): visibilitas foto salinan dipertahankan `public`.
            visibility: photo.visibility,
            sourcePhotoId: photo.id,
            createdAt: now,
          ),
        );
      }

      // Simulasi penulisan bertahap.
      // TODO(FIRESTORE): di Firestore: (1) tulis trip berstatus `copying`,
      // (2) tulis hari/stop/foto dalam batch <= 500 operasi per batch,
      // (3) ubah status menjadi `planned` HANYA jika semua batch berhasil,
      // (4) jika ada yang gagal, hapus data parsial lalu kembalikan failed.
      _trips[tripId] = trip;
      _days[tripId] = newDays;
      _stops[tripId] = newStops;
      _photos[tripId] = newPhotos;

      if (failNextAdoptAfterWrite) {
        failNextAdoptAfterWrite = false;
        throw StateError('Simulasi gagal di tengah penyalinan');
      }

      await _fakeDelay();

      _trips[tripId] = trip.copyWith(
        tripStatus: TripStatus.planned,
        updatedAt: DateTime.now(),
      );
      return AdoptResult.success(tripId);
    } catch (e) {
      _removeTrip(tripId); // jangan tinggalkan data parsial
      return AdoptResult.failed(AdoptFailure.unknown, detail: '$e');
    }
  }

  void _removeTrip(String tripId) {
    _trips.remove(tripId);
    _days.remove(tripId);
    _stops.remove(tripId);
    _photos.remove(tripId);
  }

  int _intOf(Object? value) => (value as num?)?.toInt() ?? 0;

  // ---------------------------------------------------------------- BACA

  @override
  Future<List<TripModel>> getMyTrips(String userId) async {
    await _fakeDelay();
    // TODO(SHARED_TRIP): sertakan trip tempat pengguna menjadi anggota.
    final result = _trips.values
        .where((t) => t.ownerId == userId && t.tripStatus != TripStatus.copying)
        .toList();
    result.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return result;
  }

  @override
  Future<TripDetail> getTripDetail({
    required String userId,
    required String tripId,
  }) async {
    await _fakeDelay();
    final trip = _requireViewableTrip(userId, tripId);
    return _detailOf(trip);
  }

  TripDetail _detailOf(TripModel trip) {
    final days = [...(_days[trip.id] ?? <TripDayModel>[])]
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return TripDetail(
      trip: trip,
      days: days,
      stops: List<TripStopModel>.from(_stops[trip.id] ?? const []),
      photos: List<TripPhotoModel>.from(_photos[trip.id] ?? const []),
    );
  }

  // ----------------------------------------------------------- CUSTOMIZE

  @override
  Future<TripDetail> saveTripDraft({
    required String userId,
    required String tripId,
    required TripDraft draft,
  }) async {
    await _fakeDelay();
    final trip = _requireEditableTrip(userId, tripId);
    if (draft.tripId != tripId) {
      throw const InvalidTripOperationException('Draft bukan milik trip ini');
    }
    if (trip.updatedAt != draft.baseUpdatedAt) {
      throw const TripConflictException();
    }

    // ---- Validasi ulang SEMUA data sebelum ada yang diubah.
    final title = draft.title.trim();
    if (title.isEmpty) {
      throw const InvalidTripOperationException('Judul trip wajib diisi');
    }

    final days = draft.days;
    if (days.isEmpty || days.length > kMaxTripDays) {
      throw const InvalidTripOperationException(
        'Jumlah hari harus 1 sampai $kMaxTripDays',
      );
    }
    final dayIds = <String>{};
    for (var i = 0; i < days.length; i++) {
      if (days[i].dayNumber != i + 1 ||
          days[i].tripId != tripId ||
          !dayIds.add(days[i].id)) {
        throw const InvalidTripOperationException('Susunan hari tidak valid');
      }
    }

    final stopIds = <String>{};
    for (final s in draft.stops) {
      if (!dayIds.contains(s.dayId) ||
          s.tripId != tripId ||
          !stopIds.add(s.id)) {
        throw const InvalidTripOperationException('Data tempat tidak valid');
      }
      final error = validateStopFields(
        placeName: s.placeName,
        startTime: s.startTime,
        durationMinutes: s.durationMinutes,
        cost: s.cost,
      );
      if (error != null) throw InvalidTripOperationException(error);
    }

    if (failNextSave) {
      failNextSave = false;
      throw StateError('Simulasi gagal menyimpan');
    }

    // ---- Susun data baru. Tanggal hari dan urutan dihitung ulang di sini,
    // tidak dipercaya dari draft.
    final rawStart = draft.startDate;
    final start = rawStart == null ? null : dateOnly(rawStart);
    final newDays = [
      for (var i = 0; i < days.length; i++)
        start == null ? days[i] : days[i].copyWith(date: dayDate(start, i)),
    ];
    final newStops = <TripStopModel>[
      for (final d in newDays)
        ...TripDraft.scheduleDay(
          draft.stops.where((s) => s.dayId == d.id).toList(),
        ),
    ];
    // Foto dari draft. Foto milik stop yang sudah tidak ada dibuang.
    final photoIds = <String>{};
    final newPhotos = <TripPhotoModel>[];
    for (final p in draft.photos) {
      final stopId = p.stopId;
      if (stopId != null && !stopIds.contains(stopId)) continue;
      final String? url = p.photoUrl;
      if (url == null || url.trim().isEmpty || !photoIds.add(p.id)) {
        throw const InvalidTripOperationException('Data foto tidak valid');
      }
      newPhotos.add(p);
    }

    // TODO(FIRESTORE): (1) unggah foto/sampul yang masih berupa file lokal
    // ke Storage dan ganti path-nya dengan URL unduhan; (2) satu transaction:
    // baca trip, cek updatedAt, lalu tulis SELISIHNYA saja (hapus
    // hari/stop/foto yang hilang, set yang baru atau berubah). Batas 500 tulis
    // per transaction. Hapus juga file Storage milik foto yang dihapus.
    _days[tripId] = newDays;
    _stops[tripId] = newStops;
    _photos[tripId] = newPhotos;
    final updated = trip.copyWith(
      title: title,
      destination: draft.destination,
      description: draft.description,
      startDate: start,
      durationDays: newDays.length,
      stopCount: newStops.length,
      coverUrl: draft.coverUrl,
      updatedAt: DateTime.now(),
    );
    _trips[tripId] = updated;
    return _detailOf(updated);
  }

  // ------------------------------------------------------------- HELPER

  /// TODO(SHARED_TRIP): saat ini hanya pemilik. Tambahkan anggota dengan izin
  /// lihat setelah role/permission Shared Trip disepakati.
  TripModel _requireViewableTrip(String userId, String tripId) {
    final trip = _trips[tripId];
    if (trip == null || trip.tripStatus == TripStatus.copying) {
      throw TripNotFoundException(tripId);
    }
    if (userId.isEmpty || trip.ownerId != userId) {
      throw const TripAccessDeniedException();
    }
    return trip;
  }

  /// TODO(SHARED_TRIP): tambahkan anggota dengan izin edit.
  TripModel _requireEditableTrip(String userId, String tripId) {
    return _requireViewableTrip(userId, tripId);
  }
}