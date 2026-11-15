import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngikutaja/app.dart';
import 'package:ngikutaja/data/app_state.dart';
import 'package:ngikutaja/data/models.dart';
import 'package:ngikutaja/features/auth/login_page.dart';
import 'package:ngikutaja/features/create/create_itinerary_page.dart';
import 'package:ngikutaja/features/explore/itinerary_detail_page.dart';
import 'package:ngikutaja/features/profile/wishlist_page.dart';
import 'package:ngikutaja/features/shell/home_shell.dart';
import 'package:ngikutaja/features/trips/customize_page.dart';
import 'package:ngikutaja/widgets/basics.dart';

AppState newState({bool loggedIn = true}) => AppState(null, now: DateTime(2026, 11, 4, 9, 41), watchNetwork: false)
  ..onboarded = true
  ..loggedIn = loggedIn;

Widget host(AppState s, Widget home) => AppScope(
  state: s,
  child: MaterialApp(theme: buildTheme(), home: home),
);

Future<void> phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> tapText(WidgetTester tester, String text, {bool button = false}) async {
  final f = button ? find.widgetWithText(NgButton, text) : find.text(text);
  await tester.ensureVisible(f.first);
  await tester.pump();
  await tester.tap(f.first);
}

void main() {
  // Pakai font asli supaya lebar teks sama dengan aplikasi (font tes bawaan jauh lebih lebar).
  setUpAll(() async {
    final loader = FontLoader('PlusJakartaSans');
