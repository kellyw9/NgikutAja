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
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/fonts/PlusJakartaSans-$w.ttf'));
    }
    await loader.load();
  });

  testWidgets('Login: password salah menampilkan error, password benar masuk', (tester) async {
    await phone(tester);
    final s = newState(loggedIn: false);
    await tester.pumpWidget(host(s, const LoginPage()));
    await tester.enterText(find.byType(TextField).at(0), 'dinda.saragi@gmail.com');
    await tester.enterText(find.byType(TextField).at(1), 'salah1234');
    await tapText(tester, 'Masuk', button: true);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Email atau password salah'), findsOneWidget);
    expect(find.text('Password tidak cocok dengan email ini'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), 'ngikutaja');
    await tapText(tester, 'Masuk', button: true);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(seconds: 1));
    expect(s.loggedIn, isTrue);
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('Adopt itinerary: konfirmasi, proses, berhasil masuk Trip Saya', (tester) async {
    await phone(tester);
    final s = newState();
    final before = s.trips.length;
    await tester.pumpWidget(host(s, ItineraryDetailPage(it: s.itinerary('medan'))));
    await tapText(tester, 'Adopt itinerary', button: true);
    await tester.pumpAndSettle();
    await tapText(tester, 'Adopt ke Trip Saya', button: true);
    await tester.pumpAndSettle();
    expect(find.text('Adopt itinerary ini?'), findsOneWidget);
    await tapText(tester, 'Adopt sekarang', button: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Menyalin itinerary...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Trip berhasil ditambahkan'), findsOneWidget);
    expect(s.trips.length, before + 1);
    expect(s.statusOf(s.trips.first), TripStatus.diadopsi);
  });

  testWidgets('Customize: jadwal bentrok terdeteksi, saran diterapkan, lalu tersimpan', (tester) async {
    await phone(tester);
    final s = newState();
    final t = s.trips.firstWhere((x) => x.id == 'medan-libur');
    t.plan[0].add(Stop(start: '14.00', end: '15.00', name: 'Mie Aceh Titi Bobrok', cat: Category.makan, cost: 75000));
    await tester.pumpWidget(host(s, CustomizePage(trip: t)));
    expect(find.text('Jadwal bertabrakan di Hari 1'), findsOneWidget);
    await tapText(tester, 'Lihat saran');
    await tester.pumpAndSettle();
    expect(find.text('Geser Mie Aceh Titi Bobrok ke 14.45'), findsOneWidget);
    await tapText(tester, 'Terapkan', button: true);
    await tester.pumpAndSettle();
    expect(find.text('Jadwal bertabrakan di Hari 1'), findsNothing);

    await tapText(tester, 'Simpan perubahan', button: true);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Menyimpan...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    // snackbar "Saran diterapkan" keluar dulu, lalu snackbar sukses masuk
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Perubahan tersimpan. Pengingat ikut diperbarui.'), findsOneWidget);
    expect(t.plan[0].last.start, '14.45');
  });

  testWidgets('Beli itinerary berbayar dengan QRIS (simulasi) membuka detail penuh', (tester) async {
    await phone(tester);
    final s = newState();
    final toba = s.itinerary('toba');
    await tester.pumpWidget(host(s, PaidPreviewPage(it: toba)));
    expect(find.text('4 aktivitas di Hari 2 terkunci'), findsOneWidget);
    await tapText(tester, 'Beli Rp25.000', button: true);
    await tester.pumpAndSettle();
    await tapText(tester, 'Lanjut pembayaran', button: true);
    await tester.pumpAndSettle();
    await tapText(tester, 'Konfirmasi pembelian', button: true);
    await tester.pumpAndSettle();
    await tapText(tester, 'Bayar Rp25.000', button: true);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Memproses pembayaran...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Pembayaran berhasil'), findsOneWidget);
    expect(s.purchased, contains('toba'));
    expect(s.transactions.first.status, TxStatus.berhasil);
  });

  testWidgets('Create: judul wajib, hari tanpa stop menahan publish', (tester) async {
    await phone(tester);
