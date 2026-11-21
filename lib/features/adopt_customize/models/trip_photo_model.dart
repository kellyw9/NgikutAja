import 'model_helpers.dart';

/// Hanya dua nilai yang disepakati. Tidak ada `owner_only`.
enum PhotoVisibility {
  public('public'),
  tripOnly('trip_only');

  const PhotoVisibility(this.value);
  final String value;

  /// Nilai tidak dikenal atau kosong dianggap `trip_only`
  /// (default aman agar tidak membocorkan foto).
  static PhotoVisibility fromValue(String? value) {
    for (final v in PhotoVisibility.values) {
      if (v.value == value) return v;
    }
    return PhotoVisibility.tripOnly;
  }
}

class TripPhotoModel {
  final String id;
  final String tripId;
  final String? stopId;

  /// METADATA INTERNAL: jangan tampilkan ke publik dan jangan jadikan label UI.
  /// Jangan disamakan dengan creatorId.
  final String uploadedBy;

  final String photoUrl;
  final PhotoVisibility visibility;

  /// ID foto sumber jika foto ini hasil salinan saat Adopt.
  final String? sourcePhotoId;

  final DateTime? createdAt;

  const TripPhotoModel({
    required this.id,
    required this.tripId,
    required this.uploadedBy,
    required this.photoUrl,
    this.stopId,
    this.visibility = PhotoVisibility.tripOnly,
    this.sourcePhotoId,
    this.createdAt,
  });

  /// Hanya foto public yang boleh disalin saat Adopt.
  bool get isCopyableOnAdopt => visibility == PhotoVisibility.public;

  factory TripPhotoModel.fromMap(String id, Map<String, dynamic> map) {
    return TripPhotoModel(
      id: id,
      tripId: (map['tripId'] as String?) ?? '',
      stopId: map['stopId'] as String?,
      uploadedBy: (map['uploadedBy'] as String?) ?? '',
      photoUrl: (map['photoUrl'] as String?) ?? '',
      visibility: PhotoVisibility.fromValue(map['visibility'] as String?),
      sourcePhotoId: map['sourcePhotoId'] as String?,
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'stopId': stopId,
      'uploadedBy': uploadedBy,
      'photoUrl': photoUrl,
      'visibility': visibility.value,
      'sourcePhotoId': sourcePhotoId,
      'createdAt': dateToStorage(createdAt),
    };
  }

  TripPhotoModel copyWith({String? photoUrl, PhotoVisibility? visibility}) {
    return TripPhotoModel(
      id: id,
      tripId: tripId,
      stopId: stopId,
      uploadedBy: uploadedBy,
      photoUrl: photoUrl ?? this.photoUrl,
      visibility: visibility ?? this.visibility,
      sourcePhotoId: sourcePhotoId,
      createdAt: createdAt,
    );
  }
}
