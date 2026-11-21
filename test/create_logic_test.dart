import 'package:flutter_test/flutter_test.dart';
import 'package:ngikutaja/data/app_state.dart';
import 'package:ngikutaja/data/models.dart';
import 'package:ngikutaja/features/trips/schedule_logic.dart';

/// Tes logika bagian Create & Publish (tanpa tampilan).
/// Jalankan: flutter test test/create_logic_test.dart
AppState newState() => AppState(null, now: DateTime(2026, 11, 4, 9, 41), watchNetwork: false);

Stop stop(String start, String end, {String name = 'Tempat', int cost = 0}) =>
    Stop(start: start, end: end, name: name, cat: Category.makan, cost: cost);

void main() {
  group('Draft baru', () {
    test('newDraft kosong, berstatus draft, dan milik akun yang login', () {
      final s = newState();
      final d = s.newDraft();
      expect(d.isDraft, isTrue);
      expect(d.title, isEmpty);
      expect(d.days, 1);
      expect(d.plan.length, 1);
      expect(d.plan[0], isEmpty);
      expect(d.creator, same(s.me));
      expect(d.hasFullPlan, isFalse); // hari 1 belum punya stop
    });

    test('saveDraft menambahkan ke daftar draft dan tidak menggandakan', () {
      final s = newState();
      final before = s.drafts.length;
      final d = s.newDraft()..title = 'Kuliner Medan';
      s.saveDraft(d);
      s.saveDraft(d); // simpan dua kali
      expect(s.drafts.length, before + 1);
      expect(s.drafts.first, same(d)); // draft terbaru di paling atas
    });

    test('deleteDraft menghapus draft', () {
      final s = newState();
      final d = s.newDraft();
      s.saveDraft(d);
      s.deleteDraft(d);
      expect(s.drafts.contains(d), isFalse);
    });
  });

  group('Stop, hari, dan budget', () {
    test('durasi stop dihitung dari jam mulai dan selesai', () {
      expect(stop('07.30', '08.30').duration, 60);
      expect(stop('09.00', '10.30').duration, 90);
    });

    test('budget otomatis = jumlah biaya semua stop', () {
      final s = newState();
      final d = s.newDraft()
        ..title = 'Medan 1 Hari'
        ..plan = [
          [stop('07.30', '08.30', cost: 35000), stop('09.00', '10.30', cost: 10000)],
        ];
      expect(d.stopCount, 2);
      expect(d.dayCost(0), 45000);
      expect(d.hasFullPlan, isTrue);
      expect(d.estimate, 45000);
    });

    test('itinerary belum lengkap bila ada hari tanpa stop', () {
      final s = newState();
      final d = s.newDraft()
        ..days = 2
        ..plan = [
          [stop('08.00', '09.00')],
          [],
        ];
      expect(d.hasFullPlan, isFalse);
    });

    test('judul hari memakai judul isian, atau "Hari N" kalau kosong', () {
      final s = newState();
      final d = s.newDraft()..dayTitles = ['Istana dan kota tua'];
      expect(d.dayTitle(0), 'Istana dan kota tua');
      d.dayTitles = [''];
      expect(d.dayTitle(0), 'Hari 1');
    });

    test('harga 0 = gratis, harga lebih dari 0 = berbayar', () {
      final s = newState();
      final d = s.newDraft();
      expect(d.isPaid, isFalse);
      d.price = 25000;
      expect(d.isPaid, isTrue);
    });
  });

  group('Jam bentrok', () {
    test('stop yang jamnya tumpang tindih terdeteksi bentrok', () {
      final day = [stop('09.00', '10.30'), stop('10.00', '11.00')];
      expect(conflictsIn(day).length, 1);
    });

    test('stop berurutan (selesai = mulai berikutnya) tidak bentrok', () {
      final day = [stop('08.00', '09.00'), stop('09.00', '10.00')];
      expect(conflictsIn(day), isEmpty);
    });

    test('stop dengan jeda tidak bentrok', () {
      final day = [stop('08.00', '09.00'), stop('12.00', '13.00')];
      expect(conflictsIn(day), isEmpty);
    });
  });

  group('Publish', () {
    test('publish mengubah draft jadi terbit dan memindahkannya dari draft', () {
      final s = newState();
      final d = s.newDraft()
        ..title = 'Kuliner Medan'
        ..plan = [
          [stop('08.00', '09.00', cost: 20000)],
        ];
      s.saveDraft(d);
      s.publish(d);

      expect(d.isDraft, isFalse);
      expect(s.drafts.contains(d), isFalse);
      expect(s.itineraries.first, same(d));
      expect(s.itinerary(d.id), same(d));
    });

    test('itinerary milik sendiri tidak tampil di feed Explore (sesuai kode saat ini)', () {
      final s = newState();
      final d = s.newDraft()
        ..title = 'Punyaku'
        ..plan = [
          [stop('08.00', '09.00')],
        ];
      s.publish(d);
      expect(s.published.contains(d), isFalse);
      expect(s.latest().contains(d), isTrue);
    });

    test('salinan stop (copy) tidak ikut berubah saat aslinya diubah', () {
      final a = [
        [stop('08.00', '09.00', name: 'Asli')],
      ];
      final b = copyPlan(a);
      b[0][0].name = 'Salinan diubah';
      expect(a[0][0].name, 'Asli');
    });
  });
}
