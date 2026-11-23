import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/travel_model.dart';
import 'check_in_service.dart';

class CachedTrip {
  final TripModel trip;
  final List<DayModel> days;
  final List<StopModel> stops;

  const CachedTrip(this.trip, this.days, this.stops);
}

/// Penyimpanan lokal agar trip dan check-in tetap bisa dibuka tanpa internet.
class OfflineStorage {
  static const _tripKey = 'offline_trip_v1';
  static const _checkInKey = 'offline_checkins_v1';

  // ---------- Trip ----------

  /// Panggil saat trip diadopsi / data trip berhasil diambil.
  static Future<void> saveTrip(
    TripModel trip,
    List<DayModel> days,
    List<StopModel> stops,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'trip': _tripToMap(trip),
      'days': days.map(_dayToMap).toList(),
      'stops': stops.map(_stopToMap).toList(),
    };
    await prefs.setString(_tripKey, jsonEncode(data));
  }

  /// Panggil saat tidak ada internet / gagal mengambil data.
  static Future<CachedTrip?> loadTrip() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tripKey);
    if (raw == null) return null;

    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;

      final tripMap = _restoreDates(
        Map<String, dynamic>.from(m['trip']),
        ['startDate', 'createdAt', 'updatedAt'],
      );
      final days = (m['days'] as List).map((e) {
        final d = _restoreDates(Map<String, dynamic>.from(e), ['date']);
        return DayModel.fromMap(d['id'], d);
      }).toList();
      final stops = (m['stops'] as List).map((e) {
        final s = Map<String, dynamic>.from(e);
        return StopModel.fromMap(s['id'], s);
      }).toList();

      return CachedTrip(TripModel.fromMap(tripMap['id'], tripMap), days, stops);
    } catch (_) {
      return null; // cache rusak: abaikan
    }
  }

  // ---------- Check-in ----------

  static Future<void> saveCheckIns() async {
    final prefs = await SharedPreferences.getInstance();
    final list = CheckInStore.checkIns.value.values.map((c) => {
          'id': c.id,
          'stopId': c.stopId,
          'userId': c.userId,
          'location': {'lat': c.latitude, 'lng': c.longitude},
          'photoUrl': c.photoUrl,
          'checkedAt': c.checkedAt?.toIso8601String(),
        }).toList();
    await prefs.setString(_checkInKey, jsonEncode(list));
  }

  /// Isi CheckInStore dari penyimpanan. Panggil sekali saat halaman dibuka.
  static Future<void> loadCheckIns() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_checkInKey);
    if (raw == null) return;

    try {
      final map = <String, CheckInModel>{};
      for (final e in jsonDecode(raw) as List) {
        final d = _restoreDates(Map<String, dynamic>.from(e), ['checkedAt']);
        final c = CheckInModel.fromMap(d['id'], d);
        map[c.stopId] = c;
      }
      CheckInStore.checkIns.value = map;
    } catch (_) {
      // cache rusak: abaikan
    }
  }

  // ---------- Helper konversi ----------

  static Map<String, dynamic> _restoreDates(
      Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is String) m[k] = DateTime.tryParse(v);
    }
    return m;
  }

  static Map<String, dynamic> _tripToMap(TripModel t) => {
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'destination': t.destination,
        'durationDays': t.durationDays,
        'ownerId': t.ownerId,
        'creatorId': t.creatorId,
        'creatorName': t.creatorName,
        'coverUrl': t.coverUrl,
        'parentId': t.parentId,
        'startDate': t.startDate?.toIso8601String(),
        'tripStatus': t.tripStatus,
        'memberIds': t.memberIds,
        'createdAt': t.createdAt?.toIso8601String(),
        'updatedAt': t.updatedAt?.toIso8601String(),
      };

  static Map<String, dynamic> _dayToMap(DayModel d) => {
        'id': d.id,
        'tripId': d.tripId,
        'dayNumber': d.dayNumber,
        'date': d.date?.toIso8601String(),
      };

  static Map<String, dynamic> _stopToMap(StopModel s) => {
        'id': s.id,
        'tripId': s.tripId,
        'dayId': s.dayId,
        'placeName': s.placeName,
        'description': s.description,
        'category': s.category,
        'startTime': s.startTime,
        'durationMinutes': s.durationMinutes,
        'cost': s.cost,
        'note': s.note,
        'location': {'lat': s.latitude, 'lng': s.longitude},
        'order': s.order,
      };
}