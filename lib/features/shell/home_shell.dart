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
