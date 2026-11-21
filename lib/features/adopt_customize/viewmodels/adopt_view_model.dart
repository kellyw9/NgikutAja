import 'package:flutter/foundation.dart';

import '../models/adopt_result.dart';
import '../repositories/trip_repository.dart';
import '../services/auth_bridge.dart';
import '../services/payment_checker.dart';
import 'safe_notifier.dart';

enum AdoptStatus { idle, processing, success, failure }

class AdoptViewModel extends ChangeNotifier with SafeNotifier {
  AdoptViewModel({
    required AuthBridge authBridge,
    required TripRepository tripRepository,
    required PaymentChecker paymentChecker,
  }) : _auth = authBridge,
       _repo = tripRepository,
       _payment = paymentChecker;

  final AuthBridge _auth;
  final TripRepository _repo;
  final PaymentChecker _payment;

  AdoptStatus _status = AdoptStatus.idle;
  AdoptFailure? _failure;
  String? _newTripId;
  bool _hasPaid = false;
  bool _isCheckingPayment = false;
  int _requestCounter = 0;

  AdoptStatus get status => _status;
  AdoptFailure? get failure => _failure;

  /// ID trip hasil Adopt terakhir yang berhasil.
  String? get newTripId => _newTripId;

  bool get isProcessing => _status == AdoptStatus.processing;
  bool get hasPaid => _hasPaid;
  bool get isCheckingPayment => _isCheckingPayment;
  bool get isLoggedIn => _auth.isLoggedIn;

  /// Pesan untuk layar "Adopt belum berhasil". Null jika tidak ada kegagalan.
  /// Repository menjamin data parsial dihapus, jadi aman bilang
  /// "tidak ada yang tersimpan" untuk kegagalan saat menyalin.
  String? get errorMessage {
    if (_status != AdoptStatus.failure) return null;
    switch (_failure) {
      case AdoptFailure.notLoggedIn:
        return 'Silakan login terlebih dahulu.';
      case AdoptFailure.itineraryNotFound:
        return 'Itinerary ini sudah tidak tersedia.';
      case AdoptFailure.paymentRequired:
        return 'Itinerary ini berbayar. Selesaikan pembayaran terlebih dahulu.';
      case AdoptFailure.paymentFailed:
        return 'Pembayaran gagal, jadi Adopt belum bisa dilakukan.';
      case AdoptFailure.sourceIncomplete:
        return 'Data itinerary belum lengkap. Tidak ada yang tersimpan.';
      case AdoptFailure.invalidDates:
        return 'Tanggal keberangkatan tidak valid.';
      case AdoptFailure.noConnection:
        return 'Koneksi terputus saat menyalin. Tidak ada yang tersimpan, '
            'jadi aman untuk dicoba lagi.';
      case AdoptFailure.unknown:
      case null:
        return 'Terjadi kendala saat menyalin. Tidak ada yang tersimpan, '
            'jadi aman untuk dicoba lagi.';
    }
  }

  /// True jika tombol "Coba lagi" masuk akal untuk kegagalan ini.
  bool get canRetry {
    switch (_failure) {
      case AdoptFailure.noConnection:
      case AdoptFailure.unknown:
      case null:
        return true;
      default:
        return false;
    }
  }

  /// Memeriksa status pembayaran (dari PaymentChecker, bukan dari state UI).
  /// Tombol Adopt itinerary berbayar aktif hanya jika hasilnya true.
  Future<void> checkPayment(String itineraryId) async {
    // TODO(AUTH): userId berasal dari AuthBridge asli (Anggota 1).
    final userId = _auth.currentUserId;
    if (!_auth.isLoggedIn || userId == null) {
      _hasPaid = false;
      notifyListeners();
      return;
    }
    _isCheckingPayment = true;
    notifyListeners();
    try {
      _hasPaid = await _payment.hasPaid(
        userId: userId,
        itineraryId: itineraryId,
      );
    } catch (_) {
      _hasPaid = false; // gagal memeriksa = anggap belum bayar (aman)
    }
    _isCheckingPayment = false;
    notifyListeners();
  }

  /// Menjalankan Adopt. Desain hanya meminta tanggal keberangkatan;
  /// tanggal selesai dihitung dari jumlah hari itinerary.
  /// Mengembalikan true hanya jika data salinan benar-benar selesai dibuat.
  ///
  /// TODO(KONFIRMASI): pengingat dan "Simpan untuk offline" di bottom sheet
  /// belum diproses di sini (butuh notifikasi lokal dan penyimpanan offline).
  Future<bool> adopt({
    required String itineraryId,
    required DateTime startDate,
  }) async {
    // Anti double tap: abaikan jika proses sebelumnya masih berjalan.
    if (_status == AdoptStatus.processing) return false;

    // TODO(AUTH): status login dan UID harus dari AuthBridge asli (Anggota 1).
    final userId = _auth.currentUserId;
    if (!_auth.isLoggedIn || userId == null) {
      _status = AdoptStatus.failure;
      _failure = AdoptFailure.notLoggedIn;
      notifyListeners();
      return false;
    }

    _status = AdoptStatus.processing;
    _failure = null;
    _newTripId = null;
    notifyListeners();

    // Satu requestId untuk SATU aksi Adopt. Adopt ulang yang disengaja
    // (aksi baru) otomatis mendapat requestId baru.
    _requestCounter++;
    final requestId =
        '$userId-${DateTime.now().microsecondsSinceEpoch}-$_requestCounter';

    AdoptResult result;
    try {
      result = await _repo.adoptItinerary(
        userId: userId,
        itineraryId: itineraryId,
        startDate: startDate,
        requestId: requestId,
      );
    } catch (e) {
      result = AdoptResult.failed(AdoptFailure.unknown, detail: '$e');
    }

    final tripId = result.tripId;
    if (result.isSuccess && tripId != null) {
      _status = AdoptStatus.success;
      _newTripId = tripId;
      notifyListeners();
      return true;
    }

    _status = AdoptStatus.failure;
    _failure = result.failure ?? AdoptFailure.unknown;
    notifyListeners();
    return false;
  }

  /// Kembali ke kondisi awal (misalnya saat bottom sheet dibuka lagi).
  void reset() {
    if (_status == AdoptStatus.processing) return;
    _status = AdoptStatus.idle;
    _failure = null;
    _newTripId = null;
    notifyListeners();
  }
}