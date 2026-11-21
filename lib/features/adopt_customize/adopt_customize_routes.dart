import 'package:go_router/go_router.dart';

import 'views/customize_trip_page.dart';
import 'views/my_trips_page.dart';
import 'views/trip_detail_page.dart';

class AdoptCustomizeRoutes {
  const AdoptCustomizeRoutes._();

  static const String myTrips = '/trips';
  static const String tripDetailPattern = '/trips/:tripId';
  static const String customizePattern = '/trips/:tripId/customize';

  static String tripDetail(String tripId) => '/trips/$tripId';
  static String customize(String tripId) => '/trips/$tripId/customize';
}

/// Daftarkan ke router utama: `routes: [..., ...adoptCustomizeRoutes()]`.
List<RouteBase> adoptCustomizeRoutes() {
  return [
    GoRoute(
      path: AdoptCustomizeRoutes.myTrips,
      builder: (context, state) => const MyTripsPage(),
    ),
    GoRoute(
      path: AdoptCustomizeRoutes.tripDetailPattern,
      builder: (context, state) =>
          TripDetailPage(tripId: state.pathParameters['tripId'] ?? ''),
    ),
    GoRoute(
      path: AdoptCustomizeRoutes.customizePattern,
      builder: (context, state) =>
          CustomizeTripPage(tripId: state.pathParameters['tripId'] ?? ''),
    ),
  ];
}
