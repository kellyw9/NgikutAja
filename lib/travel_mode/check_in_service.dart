import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/travel_model.dart';

enum CheckInResult {
  success,
  tooFar,
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  noLocation,
  error,
}

class CheckInOutcome {
  final CheckInResult result;
  final double? distanceMeters;

  const CheckInOutcome(this.result, {this.distanceMeters});
}

/// Penyimpanan check-in sementara (di memori).
/// TODO: simpan ke Firestore / penyimpanan lokal (offline mode).
class CheckInStore {
  static final ValueNotifier<Map<String, CheckInModel>> checkIns =
      ValueNotifier({});

  static bool isCheckedIn(String stopId) =>
      checkIns.value.containsKey(stopId);

  static CheckInModel? of(String stopId) => checkIns.value[stopId];

  static void add(CheckInModel c) {
    checkIns.value = {...checkIns.value, c.stopId: c};
  }
}

class CheckInService {
  /// Jarak maksimum dari stop agar check-in dianggap valid.
  static const double radiusMeters = 100;

  static Future<CheckInOutcome> checkIn(
    StopModel stop, {
    String userId = 'u1', // TODO: ganti dengan user login
    bool bypassDistance = false, // hanya untuk simulasi saat debug
  }) async {
    if (stop.latitude == null || stop.longitude == null) {
      return const CheckInOutcome(CheckInResult.noLocation);
    }

    try {
      double lat = stop.latitude!;
      double lng = stop.longitude!;
      double? distance;

      if (!bypassDistance) {
        if (!await Geolocator.isLocationServiceEnabled()) {
          return const CheckInOutcome(CheckInResult.serviceDisabled);
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied) {
          return const CheckInOutcome(CheckInResult.permissionDenied);
        }
        if (permission == LocationPermission.deniedForever) {
          return const CheckInOutcome(CheckInResult.permissionDeniedForever);
        }

        final pos = await Geolocator.getCurrentPosition();
        lat = pos.latitude;
        lng = pos.longitude;
        distance = Geolocator.distanceBetween(
          lat,
          lng,
          stop.latitude!,
          stop.longitude!,
        );

        if (distance > radiusMeters) {
          return CheckInOutcome(CheckInResult.tooFar,
              distanceMeters: distance);
        }
      }

      CheckInStore.add(CheckInModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        stopId: stop.id,
        userId: userId,
        latitude: lat,
        longitude: lng,
        checkedAt: DateTime.now(),
      ));
      return CheckInOutcome(CheckInResult.success, distanceMeters: distance);
    } catch (_) {
      return const CheckInOutcome(CheckInResult.error);
    }
  }
}