import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../create/create_itinerary_page.dart';
import '../explore/explore_page.dart';
import '../profile/profile_page.dart';
import '../search/search_page.dart';
import '../trips/trips_page.dart';

/// Tab aktif di cangkang utama. Halaman lain bisa pindah tab lewat [goTab].
final shellTab = ValueNotifier<int>(0);

/// Segmen aktif di Trip Saya.
final tripsTab = ValueNotifier<TripStatus>(TripStatus.berjalan);

const tabExplore = 0, tabSearch = 1, tabTrips = 3, tabProfile = 4;

/// Tutup semua halaman di atas cangkang lalu buka tab [tab].
void goTab(BuildContext context, int tab, {TripStatus? trips}) {
  Navigator.of(context).popUntil((r) => r.isFirst);
  if (trips != null) tripsTab.value = trips;
  shellTab.value = tab;
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _pages = const [ExplorePage(), SearchPage(), SizedBox(), TripsPage(), ProfilePage()];

  void _select(int i) {
    if (i == 2) {
      if (requireLogin(context)) push(context, const CreateItineraryPage(), fullscreen: true);
      return;
    }
    if ((i == tabTrips || i == tabProfile) && !requireLogin(context)) return;
    shellTab.value = i;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: shellTab,
      builder: (context, tab, _) {
        // Tamu yang keluar akun dikembalikan ke Explore.
