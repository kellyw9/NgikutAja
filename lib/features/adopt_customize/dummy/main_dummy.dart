import '../adopt_customize_theme.dart';

// ===========================================================================
// SEMENTARA: HAPUS SETELAH SELESAI DICOBA
// Entry point alternatif. lib/main.dart tidak disentuh.
//
// Jalankan:
//   flutter run -t lib/features/adopt_customize/dummy/main_dummy.dart
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../adopt_customize_routes.dart';
import '../repositories/itinerary_source_repository.dart';
import '../repositories/mock_trip_repository.dart';
import '../repositories/trip_repository.dart';
import '../services/auth_bridge.dart';
import '../services/payment_checker.dart';
import 'dummy_data.dart';
import 'dummy_home_page.dart';
import 'dummy_itinerary_detail_page.dart';

void main() {
  // TODO(AUTH): ganti dengan implementasi asli Anggota 1.
  final auth = DummyAuthBridge();
  // TODO(PAYMENT): ganti dengan implementasi asli Anggota 6.
  final payment = DummyPaymentChecker();
  // TODO(KONFIRMASI): ganti dengan pembaca `itineraries` asli (Anggota 2).
  final source = DummyItinerarySourceRepository();
  // TODO(FIRESTORE): ganti dengan FirestoreTripRepository.
  final repo = MockTripRepository(
    sourceRepository: source,
    paymentChecker: payment,
  );

  runApp(DummyApp(auth: auth, payment: payment, source: source, repo: repo));
}

class DummyApp extends StatefulWidget {
  const DummyApp({
    super.key,
    required this.auth,
    required this.payment,
    required this.source,
    required this.repo,
  });

  final DummyAuthBridge auth;
  final DummyPaymentChecker payment;
  final DummyItinerarySourceRepository source;
  final MockTripRepository repo;

  @override
  State<DummyApp> createState() => _DummyAppState();
}

class _DummyAppState extends State<DummyApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DummyHomePage()),
      GoRoute(
        path: '/itinerary/:id',
        builder: (context, state) => DummyItineraryDetailPage(
          itineraryId: state.pathParameters['id'] ?? '',
        ),
      ),
      ...adoptCustomizeRoutes(),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthBridge>.value(value: widget.auth),
        Provider<DummyAuthBridge>.value(value: widget.auth),
        Provider<PaymentChecker>.value(value: widget.payment),
        Provider<DummyPaymentChecker>.value(value: widget.payment),
        Provider<ItinerarySourceRepository>.value(value: widget.source),
        Provider<TripRepository>.value(value: widget.repo),
      ],
      child: MaterialApp.router(
        theme: adoptCustomizeTheme(),
        builder: adoptCustomizeAppBuilder,
        title: 'NgikutAja (dummy)',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
