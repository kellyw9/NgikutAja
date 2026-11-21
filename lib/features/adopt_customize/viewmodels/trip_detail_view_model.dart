import 'package:flutter/foundation.dart';

import '../models/trip_detail.dart';
import '../repositories/trip_repository.dart';
import '../services/auth_bridge.dart';
import '../utils/trip_permissions.dart';
import 'safe_notifier.dart';

/// State halaman Detail Trip. Tombol Customize hanya tampil jika [canEdit].
class TripDetailViewModel extends ChangeNotifier with SafeNotifier {
  TripDetailViewModel({
    required AuthBridge authBridge,
    required TripRepository tripRepository,
  }) : _auth = authBridge,
       _repo = tripRepository;

  final AuthBridge _auth;
  final TripRepository _repo;

  TripDetail? _detail;
  bool _isLoading = false;
  String? _errorMessage;

  TripDetail? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get canEdit {
    final d = _detail;
    return d != null && TripPermissions.canEdit(d.trip, _auth.currentUserId);
  }

  Future<void> load(String tripId) async {
    // TODO(AUTH): UID dan status login dari AuthBridge asli (Anggota 1).
    final userId = _auth.currentUserId;
    if (!_auth.isLoggedIn || userId == null) {
      _detail = null;
      _errorMessage = 'Silakan login terlebih dahulu';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _detail = await _repo.getTripDetail(userId: userId, tripId: tripId);
    } on TripNotFoundException {
      _detail = null;
      _errorMessage = 'Trip tidak ditemukan';
    } on TripAccessDeniedException {
      _detail = null;
      _errorMessage = 'Kamu tidak memiliki akses ke trip ini';
    } catch (_) {
      _detail = null;
      _errorMessage = 'Gagal memuat trip. Periksa koneksi lalu coba lagi.';
    }
    _isLoading = false;
    notifyListeners();
  }
}
