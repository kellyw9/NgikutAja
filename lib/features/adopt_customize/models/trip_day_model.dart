import 'model_helpers.dart';

class TripDayModel {
  final String id;
  final String tripId;

  /// Urutan hari: 1, 2, 3, dst.
  final int dayNumber;

  /// Tanggal nyata, dihitung dari startDate trip. Bisa kosong jika startDate belum ada.
  final DateTime? date;

  const TripDayModel({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    this.date,
  });

  factory TripDayModel.fromMap(String id, Map<String, dynamic> map) {
    return TripDayModel(
      id: id,
      tripId: (map['tripId'] as String?) ?? '',
      dayNumber: (map['dayNumber'] as num?)?.toInt() ?? 0,
      date: parseDate(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'dayNumber': dayNumber,
      'date': dateToStorage(date),
    };
  }

  TripDayModel copyWith({int? dayNumber, DateTime? date}) {
    return TripDayModel(
      id: id,
      tripId: tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
    );
  }
}
