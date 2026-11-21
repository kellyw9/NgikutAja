import 'model_helpers.dart';

/// Status trip yang DISIMPAN di data.
/// TODO(KONFIRMASI): nilai status belum disepakati tim.
/// - `copying` adalah USULAN: trip belum lengkap tersalin, jangan tampil di Trip Saya.
/// - `planned`, `ongoing`, `done` mengikuti ERD di PDF rancangan.
/// - Belum ada aturan siapa yang boleh mengubah status (kemungkinan Travel Mode).
///
/// Untuk tab di Trip Saya JANGAN pakai enum ini langsung, pakai
/// [TripModel.phaseOn] yang juga memperhitungkan tanggal.
enum TripStatus {
  copying('copying'),
  planned('planned'),
  ongoing('ongoing'),
  done('done');

  const TripStatus(this.value);
  final String value;

  /// Nilai tidak dikenal dianggap `copying` agar data yang tidak jelas
  /// tidak tampil sebagai trip yang berhasil.
  static TripStatus fromValue(String? value) {
    for (final status in TripStatus.values) {
      if (status.value == value) return status;
    }
    return TripStatus.copying;
  }
}

/// Kelompok trip untuk tab Trip Saya.
/// Desain: Draft / Diadopsi / Berjalan / Selesai.
///
/// TIDAK disimpan. Dihitung dari status tersimpan + tanggal lewat
/// [TripModel.phaseOn], jadi tidak perlu ada proses yang memperbarui status
/// setiap hari.
///
/// - [draft]: tanggal keberangkatan belum diatur.
/// - [upcoming]: sudah ada tanggal, belum berangkat. Desain memberi label
///   "Diadopsi".
///   TODO(KONFIRMASI): kalau nanti ada trip yang bukan hasil Adopt (misal dari
///   Create), label "Diadopsi" tidak tepat untuknya.
/// - [ongoing]: hari ini di antara tanggal berangkat dan tanggal pulang.
/// - [done]: sudah lewat tanggal pulang, atau status tersimpan `done`.
///
/// TODO(KONFIRMASI): jika tim memutuskan status berjalan/selesai diubah
/// manual (misal oleh Travel Mode), turunan dari tanggal di [TripModel.phaseOn]
/// perlu disesuaikan.
enum TripPhase { draft, upcoming, ongoing, done }

class TripModel {
  final String id;
  final String title;
  final String description;
  final String destination;
  final int durationDays;

  /// UID pemilik trip hasil Adopt.
  final String ownerId;

  /// UID kreator asli itinerary (atribusi, tidak berubah saat Customize).
  final String creatorId;

  /// Nama kreator disimpan agar atribusi tetap tampil walau itinerary sumber dihapus.
  /// TODO(KONFIRMASI): field ini usulan, belum ada di spec.
  final String? creatorName;

  /// Username kreator tanpa '@' (desain: "@jalanjalanmedan").
  /// Alasan disimpan sama dengan [creatorName].
  /// TODO(KONFIRMASI): field usulan, tanya Anggota 1 (profil) soal nama field username.
  final String? creatorUsername;

  /// URL foto sampul (foto utama itinerary). Opsional di sisi tampilan:
  /// jika kosong, UI menampilkan placeholder. Kewajiban mengisi sampul
  /// ada di modul Create & Publish (Anggota 2).
  /// TODO(KONFIRMASI): nama field usulan; PDF memakai `cover_url`.
  final String? coverUrl;

  /// ID itinerary sumber. Hanya referensi, bukan relasi hidup.
  final String? parentId;

  final DateTime? startDate;
  final TripStatus tripStatus;

  /// Jumlah stop di seluruh trip (desain kartu: "12 tempat").
  /// Disimpan di dokumen trip agar daftar Trip Saya tidak perlu membaca
  /// semua stop. Repository WAJIB memperbaruinya setiap tambah/hapus stop.
  /// TODO(KONFIRMASI): field usulan (denormalisasi).
  final int stopCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TripModel({
    required this.id,
    required this.title,
    required this.description,
    required this.destination,
    required this.durationDays,
    required this.ownerId,
    required this.creatorId,
    this.creatorName,
    this.creatorUsername,
    this.coverUrl,
    this.parentId,
    this.startDate,
    this.tripStatus = TripStatus.copying,
    this.stopCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Tanggal pulang, dihitung dari startDate + durationDays (tidak disimpan).
  DateTime? get endDate {
    final start = startDate;
    if (start == null || durationDays < 1) return null;
    return DateTime(start.year, start.month, start.day + durationDays - 1);
  }

  /// True jika trip berasal dari Adopt (desain: "Diadopsi dari itinerary @...").
  bool get isAdopted => (parentId ?? '').isNotEmpty;

  /// Tab Trip Saya untuk trip ini pada tanggal [now].
  /// Mengembalikan null untuk trip `copying` (tidak boleh tampil).
  TripPhase? phaseOn(DateTime now) {
    if (tripStatus == TripStatus.copying) return null;
    if (tripStatus == TripStatus.done) return TripPhase.done;

    final start = startDate;
    final end = endDate;
    if (start == null || end == null) return TripPhase.draft;

    if (_daysBetween(end, now) > 0) return TripPhase.done;
    if (tripStatus == TripStatus.ongoing) return TripPhase.ongoing;
    if (_daysBetween(now, start) > 0) return TripPhase.upcoming;
    return TripPhase.ongoing;
  }

  /// Sisa hari menuju keberangkatan (desain: "Berangkat 38 hari lagi").
  /// 0 = berangkat hari ini, negatif = sudah lewat, null = tanggal belum diatur.
  int? daysUntilStart(DateTime now) {
    final start = startDate;
    if (start == null) return null;
    return _daysBetween(now, start);
  }

  /// Nomor hari yang sedang berjalan (desain: "Hari 1 dari 2").
  /// Null jika [now] di luar rentang trip atau tanggal belum diatur.
  int? currentDayNumber(DateTime now) {
    final start = startDate;
    if (start == null) return null;
    final dayNumber = _daysBetween(start, now) + 1;
    if (dayNumber < 1 || dayNumber > durationDays) return null;
    return dayNumber;
  }

  /// Selisih hari kalender dari [from] ke [to], jam diabaikan.
  /// Memakai UTC agar tidak terpengaruh pergantian zona/DST.
  static int _daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  factory TripModel.fromMap(String id, Map<String, dynamic> map) {
    return TripModel(
      id: id,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      destination: (map['destination'] as String?) ?? '',
      durationDays: (map['durationDays'] as num?)?.toInt() ?? 0,
      ownerId: (map['ownerId'] as String?) ?? '',
      creatorId: (map['creatorId'] as String?) ?? '',
      creatorName: map['creatorName'] as String?,
      creatorUsername: map['creatorUsername'] as String?,
      coverUrl: map['coverUrl'] as String?,
      parentId: map['parentId'] as String?,
      startDate: parseDate(map['startDate']),
      tripStatus: TripStatus.fromValue(map['tripStatus'] as String?),
      stopCount: (map['stopCount'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  /// ID dokumen tidak ikut disimpan di dalam map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'destination': destination,
      'durationDays': durationDays,
      'ownerId': ownerId,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorUsername': creatorUsername,
      'coverUrl': coverUrl,
      'parentId': parentId,
      'startDate': dateToStorage(startDate),
      'tripStatus': tripStatus.value,
      'stopCount': stopCount,
      'createdAt': dateToStorage(createdAt),
      'updatedAt': dateToStorage(updatedAt),
    };
  }

  TripModel copyWith({
    String? title,
    String? description,
    String? destination,
    int? durationDays,
    DateTime? startDate,
    TripStatus? tripStatus,
    int? stopCount,
    String? coverUrl,
    DateTime? updatedAt,
  }) {
    // ownerId, creatorId, creatorName, creatorUsername, dan parentId
    // sengaja tidak bisa diubah lewat copyWith.
    // coverUrl bisa diganti (desain: "Ganti foto sampul"), tapi tidak bisa
    // dikosongkan lewat copyWith.
    return TripModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      destination: destination ?? this.destination,
      durationDays: durationDays ?? this.durationDays,
      ownerId: ownerId,
      creatorId: creatorId,
      creatorName: creatorName,
      creatorUsername: creatorUsername,
      coverUrl: coverUrl ?? this.coverUrl,
      parentId: parentId,
      startDate: startDate ?? this.startDate,
      tripStatus: tripStatus ?? this.tripStatus,
      stopCount: stopCount ?? this.stopCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}