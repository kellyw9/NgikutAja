// Tes asap: setiap halaman dirender di HP kecil (360x740) dan sedang (390x844).
// Gagal kalau ada error layout (misalnya teks meluber) atau exception saat build.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngikutaja/app.dart';
import 'package:ngikutaja/data/app_state.dart';
import 'package:ngikutaja/data/models.dart';
import 'package:ngikutaja/features/auth/login_page.dart';
import 'package:ngikutaja/features/auth/onboarding_page.dart';
import 'package:ngikutaja/features/auth/register_page.dart';
import 'package:ngikutaja/features/auth/reset_password_page.dart';
import 'package:ngikutaja/features/create/add_stop_page.dart';
import 'package:ngikutaja/features/create/create_itinerary_page.dart';
import 'package:ngikutaja/features/create/day_editor_page.dart';
import 'package:ngikutaja/features/create/publish_page.dart';
import 'package:ngikutaja/features/explore/creator_profile_page.dart';
import 'package:ngikutaja/features/explore/itinerary_detail_page.dart';
import 'package:ngikutaja/features/explore/reviews_page.dart';
import 'package:ngikutaja/features/extras/journal_page.dart';
import 'package:ngikutaja/features/extras/memory_pages.dart';
import 'package:ngikutaja/features/extras/packing_page.dart';
import 'package:ngikutaja/features/extras/recap_page.dart';
import 'package:ngikutaja/features/extras/split_budget_page.dart';
import 'package:ngikutaja/features/extras/tips_page.dart';
import 'package:ngikutaja/features/notifications/notifications_page.dart';
import 'package:ngikutaja/features/profile/dashboard_page.dart';
import 'package:ngikutaja/features/profile/edit_profile_page.dart';
import 'package:ngikutaja/features/profile/people_page.dart';
import 'package:ngikutaja/features/profile/settings_page.dart';
import 'package:ngikutaja/features/profile/wishlist_page.dart';
import 'package:ngikutaja/features/purchase/purchase_pages.dart';
import 'package:ngikutaja/features/shell/home_shell.dart';
import 'package:ngikutaja/features/travel/checkin_page.dart';
import 'package:ngikutaja/features/travel/expenses_page.dart';
import 'package:ngikutaja/features/travel/offline_page.dart';
import 'package:ngikutaja/features/travel/travel_mode_page.dart';
import 'package:ngikutaja/features/trips/adopt_page.dart';
import 'package:ngikutaja/features/trips/customize_page.dart';
import 'package:ngikutaja/features/trips/members_page.dart';
import 'package:ngikutaja/features/trips/trip_detail_page.dart';

typedef PageFor = Widget Function(AppState s);

final Map<String, PageFor> pages = {
  'onboarding': (s) => const OnboardingPage(),
  'login': (s) => const LoginPage(),
  'register': (s) => const RegisterPage(),
  'reset': (s) => const ResetPasswordPage(email: 'dinda.saragi@gmail.com'),
  'new password': (s) => const NewPasswordPage(email: 'dinda.saragi@gmail.com'),
  'explore': (s) => const HomeShell(),
  'detail': (s) => ItineraryDetailPage(it: s.itinerary('medan')),
  'detail tanpa jadwal': (s) => ItineraryDetailPage(it: s.itinerary('bandung')),
  'preview berbayar': (s) => PaidPreviewPage(it: s.itinerary('toba')),
  'preview tanpa jadwal': (s) => PaidPreviewPage(it: s.itinerary('bali')),
  'reviews': (s) => ReviewsPage(it: s.itinerary('medan')),
  'comments': (s) => ReviewsPage(it: s.itinerary('medan'), comments: true),
  'creator': (s) => CreatorProfilePage(c: s.seed.creators['rahmat']!),
  'create': (s) => CreateItineraryPage(draft: s.drafts[1]),
  'day editor': (s) => DayEditorPage(d: s.itinerary('samosirmotor')),
  'add stop': (s) => AddStopPage(stop: s.itinerary('medan').plan[0][0].copy(), city: 'Medan'),
  'pick location': (s) => const PickLocationPage(query: 'Soto Kesawan', city: 'Medan', photo: 'soto'),
  'publish': (s) => PublishPage(d: s.itinerary('samosirmotor')),
  'published': (s) => PublishedPage(d: s.itinerary('samosirmotor')),
  'adopt': (s) => AdoptPage(it: s.itinerary('medan')),
  'trip detail': (s) => TripDetailPage(trip: s.trips[1]),
  'trip detail berjalan': (s) => TripDetailPage(trip: s.trips[0]),
  'customize': (s) => CustomizePage(trip: s.trips[1]),
  'edit stop': (s) => EditStopPage(stop: s.trips[1].plan[0][3].copy(), dayLabel: 'Hari 1, Sabtu 12 Des'),
  'edit trip info': (s) => EditTripInfoPage(trip: s.trips[1]),
  'members': (s) => MembersPage(trip: s.trips[0]),
  'travel mode': (s) => TravelModePage(trip: s.trips[0]),
  'travel stop': (s) => TravelStopPage(trip: s.trips[0], day: 0, i: 2),
  'navigation': (s) => NavigationPage(trip: s.trips[0], day: 0, i: 2),
  'checkin': (s) => CheckinPage(trip: s.trips[0], day: 0, i: 2),
  'checkin jauh': (s) => CheckinPage(trip: s.trips[0], day: 0, i: 3),
  'permission': (s) => PermissionDeniedPage(place: 'Bukit Holbung', onOpenSettings: () {}),
  'expenses': (s) => ExpensesPage(trip: s.trips[0]),
