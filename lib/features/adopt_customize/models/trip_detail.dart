import 'trip_day_model.dart';
import 'trip_model.dart';
import 'trip_photo_model.dart';
import 'trip_stop_model.dart';

/// Gabungan data satu trip untuk halaman Detail dan Customize.
class TripDetail {
  final TripModel trip;
  final List<TripDayModel> days;
  final List<TripStopModel> stops;
  final List<TripPhotoModel> photos;

  const TripDetail({
    required this.trip,
    required this.days,
    required this.stops,
    required this.photos,
  });

  /// Stop pada satu hari, terurut berdasarkan `order`.
  List<TripStopModel> stopsOfDay(String dayId) {
    final result = stops.where((s) => s.dayId == dayId).toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  /// Foto milik satu stop.
  List<TripPhotoModel> photosOfStop(String stopId) {
    return photos.where((p) => p.stopId == stopId).toList();
  }
}
