import '../models/travel_model.dart';

/// file ini dihapus setelah Anggota 4 dan Firestore siap.
class DummyTravelData {
  static final trip = TripModel(
    id: 'trip1',
    title: '3 Hari Kuliner dan Sejarah di Medan',
    description: 'Menjelajahi kuliner legendaris dan situs bersejarah Medan.',
    destination: 'Medan, Sumatera Utara',
    durationDays: 3,
    ownerId: 'u1',
    creatorId: 'u2',
    creatorName: 'Rahmat Siregar',
    startDate: DateTime.now(),
    tripStatus: 'ongoing',
    memberIds: ['u1'],
  );

  static final days = [
    DayModel(id: 'd1', tripId: 'trip1', dayNumber: 1, date: DateTime.now()),
    DayModel(
        id: 'd2',
        tripId: 'trip1',
        dayNumber: 2,
        date: DateTime.now().add(const Duration(days: 1))),
    DayModel(
        id: 'd3',
        tripId: 'trip1',
        dayNumber: 3,
        date: DateTime.now().add(const Duration(days: 2))),
  ];

  static final stops = [
    StopModel(
      id: 's1', tripId: 'trip1', dayId: 'd1', order: 0,
      placeName: 'Soto Kesawan',
      description: 'Sarapan soto khas Medan.',
      category: 'Makan', startTime: '07:30', durationMinutes: 60, cost: 35000,
      note: 'Coba soto udang. Datang pagi agar tidak antre.',
      latitude: 3.5897, longitude: 98.6733,
    ),
    StopModel(
      id: 's2', tripId: 'trip1', dayId: 'd1', order: 1,
      placeName: 'Istana Maimun',
      description: 'Istana Kesultanan Deli.',
      category: 'Budaya', startTime: '09:00', durationMinutes: 90, cost: 10000,
      latitude: 3.5753, longitude: 98.6838,
    ),
    StopModel(
      id: 's3', tripId: 'trip1', dayId: 'd1', order: 2,
      placeName: 'Masjid Raya Al-Mashun',
      description: 'Masjid bersejarah di pusat kota.',
      category: 'Budaya', startTime: '10:45', durationMinutes: 45, cost: 0,
      latitude: 3.5750, longitude: 98.6870,
    ),
    StopModel(
      id: 's4', tripId: 'trip1', dayId: 'd1', order: 3,
      placeName: 'Durian Ucok',
      description: 'Makan siang dan durian.',
      category: 'Makan', startTime: '12:30', durationMinutes: 60, cost: 80000,
      latitude: 3.5659, longitude: 98.6585,
    ),
    StopModel(
      id: 's5', tripId: 'trip1', dayId: 'd2', order: 0,
      placeName: 'Tjong A Fie Mansion',
      description: 'Rumah peninggalan saudagar Tionghoa.',
      category: 'Sejarah', startTime: '09:00', durationMinutes: 90, cost: 35000,
      latitude: 3.5871, longitude: 98.6862,
    ),
    StopModel(
      id: 's6', tripId: 'trip1', dayId: 'd3', order: 0,
      placeName: 'Pasar Ikan Lama',
      description: 'Jajan pagi di pasar tradisional.',
      category: 'Makan', startTime: '08:00', durationMinutes: 60, cost: 40000,
      latitude: 3.5886, longitude: 98.6891,
    ),
  ];
}