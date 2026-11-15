import 'package:flutter_test/flutter_test.dart';
import 'package:ngikutaja/app.dart';
import 'package:ngikutaja/core/format.dart';
import 'package:ngikutaja/data/app_state.dart';
import 'package:ngikutaja/data/models.dart';
import 'package:ngikutaja/features/trips/schedule_logic.dart';

void main() {
  testWidgets('Splash lalu onboarding untuk pengguna baru', (tester) async {
    final state = AppState(null, now: DateTime(2026, 11, 4), watchNetwork: false);
    await tester.pumpWidget(NgikutAjaApp(state: state));
    expect(find.text('Liburan tinggal ngikut.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('Rencana liburan dari orang yang sudah ke sana'), findsOneWidget);
  });

  test('Estimasi itinerary dihitung dari biaya aktivitas', () {
    final state = AppState(null, now: DateTime(2026, 11, 4), watchNetwork: false);
    expect(state.itinerary('medan').estimate, 850000);
    expect(state.itinerary('toba').estimate, 1100000);
    expect(state.itinerary('medan').places, 12);
  });

  test('Jadwal bertabrakan terdeteksi dan saran menggeser jam', () {
    final day = [
      Stop(start: '13.00', end: '14.30', name: 'Tjong A Fie Mansion', cat: Category.budaya),
      Stop(start: '14.00', end: '15.00', name: 'Mie Aceh Titi Bobrok', cat: Category.makan),
    ];
    expect(conflictsIn(day), [(0, 1)]);
    final (issues, tips) = analyze([day]);
    expect(issues.single.conflict, isTrue);
    tips.first.apply([day]);
    expect(day[1].start, '14.45');
    expect(conflictsIn(day), isEmpty);
  });

  test('Format rupiah dan jam', () {
    expect(rp(1100000), 'Rp1.100.000');
    expect(rp(-97000), '−Rp97.000');
