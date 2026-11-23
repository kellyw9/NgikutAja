import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/travel_model.dart';

/// Pengingat lokal: H-1 keberangkatan trip, plus 1 jam dan 30 menit sebelum tiap stop.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const List<int> reminderOffsetsMinutes = [60, 30];
  static const int h1Hour = 19; // pengingat H-1 muncul jam 19:00

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'travel_reminder',
      'Pengingat perjalanan',
      channelDescription: 'Pengingat jadwal stop dan keberangkatan trip',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> init() async {
    if (_ready || kIsWeb) return; // plugin ini tidak jalan di web
    tz_data.initializeTimeZones();
    // Medan = WIB. Ganti jika perlu zona lain.
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _ready = true;
  }

  /// Jadwalkan ulang semua pengingat untuk satu trip.
  Future<void> scheduleAllForTrip(
    TripModel trip,
    List<DayModel> days,
    List<StopModel> stops,
  ) async {
    if (!_ready) return;

    final start = trip.startDate;
    if (start != null) {
      await _schedule(
        id: _id('h1_${trip.id}'),
        when: DateTime(start.year, start.month, start.day - 1, h1Hour),
        title: 'Besok berangkat!',
        body: '${trip.title} dimulai besok. Cek perlengkapanmu.',
      );
    }

    for (final stop in stops) {
      final time = _stopTime(trip, days, stop);
      if (time == null) continue;
      for (final offset in reminderOffsetsMinutes) {
        await _schedule(
          id: _id('stop_${stop.id}_$offset'),
          when: time.subtract(Duration(minutes: offset)),
          title: stop.placeName,
          body: 'Mulai ${stop.startTime} • ${_label(offset)} lagi',
        );
      }
    }
  }

  Future<void> scheduleTest() async {
    if (!_ready) return;
    await _schedule(
      id: 999999,
      when: DateTime.now().add(const Duration(seconds: 10)),
      title: 'Tes pengingat',
      body: 'Notifikasi jadwal lokal berfungsi.',
    );
  }

  Future<void> _schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    if (when.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: _details,
    
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  DateTime? _stopTime(TripModel trip, List<DayModel> days, StopModel stop) {
    final st = stop.startTime;
    if (st == null) return null;

    final idx = days.indexWhere((d) => d.id == stop.dayId);
    if (idx < 0) return null;
    final day = days[idx];

    final base = day.date ??
        (trip.startDate?.add(Duration(days: day.dayNumber - 1)));
    if (base == null) return null;

    final p = st.split(':');
    return DateTime(
        base.year, base.month, base.day, int.parse(p[0]), int.parse(p[1]));
  }

  String _label(int minutes) {
    if (minutes >= 60 && minutes % 60 == 0) return '${minutes ~/ 60} jam';
    return '$minutes menit';
  }


  int _id(String s) {
    var h = 0;
    for (final c in s.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }
}