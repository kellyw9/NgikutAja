import 'package:flutter_test/flutter_test.dart';
import 'package:ngikutaja/app.dart';
import 'package:ngikutaja/core/format.dart';
import 'package:ngikutaja/data/app_state.dart';
import 'package:ngikutaja/data/models.dart';
import 'package:ngikutaja/features/trips/schedule_logic.dart';

void main() {
  testWidgets('Splash lalu onboarding untuk pengguna baru', (tester) async {
    final state = AppState(null, now: DateTime(2026, 11, 4), watchNetwork: false);
