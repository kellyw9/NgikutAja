import 'model_helpers.dart';

class StopLocation {
  final double latitude;
  final double longitude;

  const StopLocation({required this.latitude, required this.longitude});

  factory StopLocation.fromMap(Map<String, dynamic> map) {
    return StopLocation(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

class TripStopModel {
  final String id;
  final String tripId;
  final String dayId;
  final String placeName;
  final String description;
  final StopLocation? location;

  /// Urutan dalam satu hari. Harus tersimpan ke database saat diubah.
  final int order;

  // TODO(KONFIRMASI): field di bawah ini berasal dari PDF rancangan,
  // belum ada di spec modul. Sesuaikan dengan model Anggota 2.
  final String? category;

  /// Format 'HH:mm', contoh '08:00'.
  final String? startTime;
  final int? durationMinutes;
  final int? cost;
  final String? note;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TripStopModel({
    required this.id,
    required this.tripId,
    required this.dayId,
    required this.placeName,
    required this.order,
    this.description = '',
    this.location,
    this.category,
    this.startTime,
    this.durationMinutes,
    this.cost,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory TripStopModel.fromMap(String id, Map<String, dynamic> map) {
    final rawLocation = map['location'];
    return TripStopModel(
      id: id,
      tripId: (map['tripId'] as String?) ?? '',
      dayId: (map['dayId'] as String?) ?? '',
      placeName: (map['placeName'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      location: rawLocation is Map<String, dynamic>
          ? StopLocation.fromMap(rawLocation)
          : null,
      order: (map['order'] as num?)?.toInt() ?? 0,
      category: map['category'] as String?,
      startTime: map['startTime'] as String?,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt(),
      cost: (map['cost'] as num?)?.toInt(),
      note: map['note'] as String?,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'dayId': dayId,
      'placeName': placeName,
      'description': description,
      'location': location?.toMap(),
      'order': order,
      'category': category,
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'cost': cost,
      'note': note,
      'createdAt': dateToStorage(createdAt),
      'updatedAt': dateToStorage(updatedAt),
    };
  }

  /// Catatan: copyWith tidak bisa mengosongkan field nullable (set ke null).
  TripStopModel copyWith({
    String? dayId,
    String? placeName,
    String? description,
    StopLocation? location,
    int? order,
    String? category,
    String? startTime,
    int? durationMinutes,
    int? cost,
    String? note,
    DateTime? updatedAt,
  }) {
    return TripStopModel(
      id: id,
      tripId: tripId,
      dayId: dayId ?? this.dayId,
      placeName: placeName ?? this.placeName,
      description: description ?? this.description,
      location: location ?? this.location,
      order: order ?? this.order,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      cost: cost ?? this.cost,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
