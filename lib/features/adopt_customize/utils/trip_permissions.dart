import '../models/trip_model.dart';

/// Aturan izin trip.
/// Ini pemeriksaan di sisi aplikasi untuk UX. TIDAK menggantikan
/// Firebase Security Rules.
///
/// TODO(SHARED_TRIP): tambahkan anggota dengan izin lihat/edit setelah
/// role dan permission Shared Trip disepakati.
class TripPermissions {
  const TripPermissions._();

  static bool canView(TripModel trip, String? userId) {
    return userId != null && userId.isNotEmpty && trip.ownerId == userId;
  }

  static bool canEdit(TripModel trip, String? userId) {
    return canView(trip, userId);
  }
}
