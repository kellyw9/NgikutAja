/// Alasan Adopt gagal.
enum AdoptFailure {
  notLoggedIn,
  itineraryNotFound,
  paymentRequired,
  paymentFailed,
  sourceIncomplete,
  invalidDates,
  noConnection,
  unknown,
}

class AdoptResult {
  final bool isSuccess;

  /// ID trip baru. Hanya terisi jika berhasil.
  final String? tripId;

  /// Terisi jika gagal.
  final AdoptFailure? failure;

  /// Pesan teknis opsional, bukan untuk ditampilkan mentah ke pengguna.
  final String? detail;

  const AdoptResult._({
    required this.isSuccess,
    this.tripId,
    this.failure,
    this.detail,
  });

  factory AdoptResult.success(String tripId) {
    return AdoptResult._(isSuccess: true, tripId: tripId);
  }

  factory AdoptResult.failed(AdoptFailure failure, {String? detail}) {
    return AdoptResult._(isSuccess: false, failure: failure, detail: detail);
  }
}
