import '../models/adopt_result.dart';
import '../models/trip_detail.dart';
import '../models/trip_draft.dart';
import '../models/trip_model.dart';

class TripNotFoundException implements Exception {
  final String tripId;
  const TripNotFoundException(this.tripId);

  @override
  String toString() => 'Trip tidak ditemukan: $tripId';
}

class TripAccessDeniedException implements Exception {
  const TripAccessDeniedException();

  @override
  String toString() => 'Tidak memiliki izin untuk trip ini';
}

class InvalidTripOperationException implements Exception {
  final String message;
  const InvalidTripOperationException(this.message);

  @override
  String toString() => message;
}

/// Trip sudah diubah (oleh pengguna lain atau perangkat lain) sejak draft
/// dibuka. Draft tidak disimpan agar perubahan orang lain tidak tertimpa.
class TripConflictException implements Exception {
  const TripConflictException();

  @override
  String toString() =>
      'Trip ini baru saja diubah di tempat lain. Muat ulang lalu coba lagi.';
}

/// Kontrak data trip hasil Adopt.
///
/// Semua method menerima [userId] agar izin diperiksa di lapisan data.
/// Pemeriksaan di sini TIDAK menggantikan Firebase Security Rules.
///
/// Customize memakai pola "edit dulu, simpan sekaligus" (desain):
/// perubahan dikumpulkan di [TripDraft], lalu disimpan lewat [saveTripDraft].
/// Aturan urutan, pindah hari, dan tambah hari ada di [TripDraft].
///
/// ATURAN HARI: hari selalu berurutan dari startDate (Hari 1 = startDate).
/// Tanggal pulang = startDate + jumlah hari - 1 (tidak disimpan).
abstract class TripRepository {
  /// Membuat salinan independen itinerary ke Trip Saya.
  ///
  /// Jumlah hari sama dengan sumber. Tanggal selesai dihitung dari
  /// [startDate] (desain hanya meminta "Tanggal keberangkatan").
  ///
  /// [requestId] dibuat satu kali oleh ViewModel untuk SATU aksi Adopt.
  /// Request dengan requestId sama tidak membuat trip kedua (anti double tap).
  /// Method ini tidak boleh melempar exception: kegagalan dikembalikan
  /// sebagai [AdoptResult.failed].
  Future<AdoptResult> adoptItinerary({
    required String userId,
    required String itineraryId,
    required DateTime startDate,
    required String requestId,
  });

  /// Trip milik pengguna yang sudah selesai disalin (bukan `copying`).
  Future<List<TripModel>> getMyTrips(String userId);

  /// Throw [TripNotFoundException] atau [TripAccessDeniedException].
  Future<TripDetail> getTripDetail({
    required String userId,
    required String tripId,
  });

  /// Menyimpan seluruh isi [draft] sebagai SATU operasi: semua berhasil atau
  /// tidak ada yang berubah.
  ///
  /// - Validasi ulang semua data (draft bisa saja dibuat klien yang curang).
  /// - Hanya judul, destinasi, deskripsi, startDate, hari, dan stop yang
  ///   diambil dari draft. ownerId, creatorId, parentId, dll tidak bisa diubah.
  /// - Foto milik stop yang dihapus ikut dihapus.
  ///
  /// Throw [TripNotFoundException], [TripAccessDeniedException],
  /// [TripConflictException], atau [InvalidTripOperationException].
  /// Mengembalikan detail terbaru (untuk membuat draft baru).
  Future<TripDetail> saveTripDraft({
    required String userId,
    required String tripId,
    required TripDraft draft,
  });

  // TODO(TAHAP-LANJUT): operasi foto (ganti foto, tambah foto pribadi trip, sampul).
}