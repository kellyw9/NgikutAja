// ===========================================================================
// DATA SEMENTARA: HAPUS SETELAH SELESAI DICOBA
// File ini menggantikan modul Anggota 1 (auth), Anggota 2 (itinerary),
// dan Anggota 6 (pembayaran). Hapus seluruh folder `dummy/` setelah
// ketiganya terintegrasi, lalu ganti implementasi di tempat pembuatan Provider.
// ===========================================================================

import '../repositories/itinerary_source_repository.dart';
import '../services/auth_bridge.dart';
import '../services/payment_checker.dart';

/// Bukan UID asli. Hanya penanda pengguna simulasi.
const String kDummyUserId = 'dummy_user_amel';
const String kDummyOtherUserId = 'dummy_user_orion';

const String kDummyFreeItineraryId = 'dummy_itin_jogja';
const String kDummyPaidItineraryId = 'dummy_itin_bali';

/// TODO(AUTH): ganti dengan implementasi asli dari Anggota 1.
class DummyAuthBridge implements AuthBridge {
  DummyAuthBridge({String? loggedInUserId = kDummyUserId})
    : _userId = loggedInUserId;

  String? _userId;

  /// Untuk mencoba kondisi belum login: `setUser(null)`.
  void setUser(String? userId) => _userId = userId;

  @override
  bool get isLoggedIn => _userId != null && _userId!.isNotEmpty;

  @override
  String? get currentUserId => _userId;
}

/// TODO(PAYMENT): ganti dengan implementasi asli dari Anggota 6.
class DummyPaymentChecker implements PaymentChecker {
  final Set<String> _paid = {};

  /// Simulasi pembayaran berhasil.
  void markPaid({required String userId, required String itineraryId}) {
    _paid.add('$userId|$itineraryId');
  }

  @override
  Future<bool> hasPaid({
    required String userId,
    required String itineraryId,
  }) async {
    return _paid.contains('$userId|$itineraryId');
  }
}

/// TODO(KONFIRMASI): ganti dengan pembaca `itineraries` asli (Anggota 2).
class DummyItinerarySourceRepository implements ItinerarySourceRepository {
  DummyItinerarySourceRepository()
    : _data = {
        kDummyFreeItineraryId: _buildJogja(),
        kDummyPaidItineraryId: _buildBali(),
      };

  final Map<String, SourceItinerary> _data;

  @override
  Future<SourceItinerary?> getItinerary(String itineraryId) async {
    return _data[itineraryId];
  }

  /// Untuk mencoba skenario "itinerary asli dihapus".
  void removeForTest(String itineraryId) => _data.remove(itineraryId);
}

// Isi stop dari contoh seed data di PDF. Koordinat sengaja dikosongkan.
SourceStop _stop(
  String id,
  int order,
  String name,
  String category,
  String time,
  int minutes,
  int cost,
  String note, {
  String description = '',
}) {
  return SourceStop(
    id: id,
    data: {
      'placeName': name,
      'description': description,
      'order': order,
      'category': category,
      'startTime': time,
      'durationMinutes': minutes,
      'cost': cost,
      'note': note,
    },
  );
}

/// Itinerary contoh mengikuti desain ("3 Hari Kuliner dan Sejarah di Medan").
/// ID tetap memakai [kDummyFreeItineraryId] agar halaman dummy lain tidak
/// perlu diubah. Hari 1 sengaja punya jadwal bentrok (Tjong A Fie Mansion
/// 13.00–14.30 dan Mie Aceh 14.00–15.00) seperti di desain.
SourceItinerary _buildJogja() {
  return SourceItinerary(
    id: kDummyFreeItineraryId,
    data: {
      'title': '3 Hari Kuliner dan Sejarah di Medan',
      'description':
          'Keliling kuliner legendaris dan bangunan bersejarah di Medan.',
      'destination': 'Medan',
      'durationDays': 3,
      'creatorId': 'dummy_creator_rahmat',
      'creatorName': 'Rahmat Siregar',
      'creatorUsername': 'jalanjalanmedan',
      'price': 0,
      // TODO: URL contoh, gambar tidak akan termuat (placeholder tampil).
      'coverUrl': 'https://example.com/dummy/istana_maimun.jpg',
    },
    days: [
      SourceDay(
        id: 'dummy_medan_d1',
        data: {'dayNumber': 1},
        stops: [
          _stop('dummy_medan_s1', 1, 'Soto Kesawan', 'food', '07:30', 60,
              35000, ''),
          _stop('dummy_medan_s2', 2, 'Istana Maimun', 'culture', '09:00', 90,
              10000, ''),
          _stop('dummy_medan_s3', 3, 'Masjid Raya Al-Mashun', 'culture',
              '10:45', 45, 0, ''),
          _stop('dummy_medan_s4', 4, 'Tjong A Fie Mansion', 'culture',
              '13:00', 90, 35000, 'Ikut tur pemandu, sekitar 45 menit.',
              description: 'Rumah saudagar Tionghoa tahun 1900 di Jalan '
                  'Ahmad Yani, sekarang museum dengan perabot aslinya.'),
          _stop('dummy_medan_s5', 5, 'Mie Aceh Titi Bobrok', 'food', '14:00',
              60, 75000, ''),
          _stop('dummy_medan_s6', 6, 'Jalan kaki di Kesawan', 'social',
              '15:00', 60, 0, ''),
          _stop('dummy_medan_s7', 7, 'Bika Ambon Jalan Mojopahit', 'food',
              '16:15', 45, 60000, ''),
        ],
      ),
      SourceDay(
        id: 'dummy_medan_d2',
        data: {'dayNumber': 2},
        stops: [
          _stop('dummy_medan_s8', 1, 'Museum Negeri Sumatera Utara',
              'museum', '09:00', 120, 5000, ''),
          _stop('dummy_medan_s9', 2, 'Merdeka Walk', 'social', '17:00', 120,
              0, ''),
          _stop('dummy_medan_s10', 3, 'Durian Ucok', 'food', '19:30', 90,
              100000, 'Buka sampai larut malam.'),
        ],
      ),
      SourceDay(
        id: 'dummy_medan_d3',
        data: {'dayNumber': 3},
        stops: [
          _stop('dummy_medan_s11', 1, 'Lontong Kak Lin', 'food', '08:00', 60,
              30000, ''),
          _stop('dummy_medan_s12', 2, 'Oleh-oleh di Jalan Mojopahit',
              'shopping', '11:00', 120, 0, ''),
        ],
      ),
    ],
    photos: [
      // public: harus ikut tersalin
      const SourcePhoto(
        id: 'dummy_medan_p1',
        data: {
          'stopId': 'dummy_medan_s4',
          'uploadedBy': 'dummy_creator_rahmat',
          'photoUrl': 'https://example.com/dummy/tjong_a_fie.jpg',
          'visibility': 'public',
        },
      ),
      // trip_only: TIDAK boleh tersalin
      const SourcePhoto(
        id: 'dummy_medan_p2',
        data: {
          'stopId': 'dummy_medan_s1',
          'uploadedBy': 'dummy_creator_rahmat',
          'photoUrl': 'https://example.com/dummy/pribadi.jpg',
          'visibility': 'trip_only',
        },
      ),
    ],
  );
}

SourceItinerary _buildBali() {
  return SourceItinerary(
    id: kDummyPaidItineraryId,
    data: {
      'title': 'Bali Hemat (dummy, berbayar)',
      'description': 'Contoh itinerary berbayar untuk uji coba.',
      'destination': 'Bali',
      'durationDays': 1,
      'creatorId': 'dummy_creator_backpacker',
      'creatorName': 'Backpacker Bali',
      'creatorUsername': 'backpacker.bali',
      'price': 29000,
    },
    days: [
      SourceDay(
        id: 'dummy_bali_d1',
        data: {'dayNumber': 1},
        stops: [
          _stop(
            'dummy_bali_s1',
            1,
            'Sarapan nasi jinggo',
            'food',
            '08:00',
            45,
            10000,
            'Dekat hostel.',
          ),
          _stop(
            'dummy_bali_s2',
            2,
            'Pura Luhur Uluwatu',
            'culture',
            '15:30',
            150,
            0,
            'Sunset dan tari Kecak.',
          ),
        ],
      ),
    ],
  );
}