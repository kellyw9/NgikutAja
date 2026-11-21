/// Kontrak membaca itinerary sumber dari collection `itineraries`
/// (dikelola Anggota 2). Modul ini hanya MEMBACA, tidak pernah menulis.
///
/// TODO(KONFIRMASI): nama field di `data` di bawah masih ASUMSI dan harus
/// dicocokkan dengan struktur final Anggota 2:
/// title, description, destination, durationDays, creatorId, creatorName, price.
/// Day: dayNumber. Stop: sama dengan field TripStopModel (tanpa tripId/dayId).
/// Foto: stopId, uploadedBy, photoUrl, visibility.
abstract class ItinerarySourceRepository {
  /// Null jika itinerary tidak ditemukan atau tidak dapat diakses.
  Future<SourceItinerary?> getItinerary(String itineraryId);
}

class SourceStop {
  final String id;
  final Map<String, dynamic> data;
  const SourceStop({required this.id, required this.data});
}

class SourceDay {
  final String id;
  final Map<String, dynamic> data;
  final List<SourceStop> stops;
  const SourceDay({required this.id, required this.data, required this.stops});
}

class SourcePhoto {
  final String id;
  final Map<String, dynamic> data;
  const SourcePhoto({required this.id, required this.data});
}

class SourceItinerary {
  final String id;
  final Map<String, dynamic> data;
  final List<SourceDay> days;
  final List<SourcePhoto> photos;

  const SourceItinerary({
    required this.id,
    required this.data,
    required this.days,
    this.photos = const [],
  });

  /// Harga dalam rupiah. 0 atau kosong berarti gratis.
  int get price => (data['price'] as num?)?.toInt() ?? 0;
}
