import 'package:flutter/foundation.dart';

import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';
import '../services/auth_bridge.dart';
import 'safe_notifier.dart';

/// State halaman Trip Saya (tab Draft / Diadopsi / Berjalan / Selesai).
class MyTripsViewModel extends ChangeNotifier with SafeNotifier {
  MyTripsViewModel({
    required AuthBridge authBridge,
    required TripRepository tripRepository,
  }) : _auth = authBridge,
       _repo = tripRepository;

  final AuthBridge _auth;
  final TripRepository _repo;

  /// Urutan tab sesuai desain.
  static const List<TripPhase> tabOrder = [
    TripPhase.draft,
    TripPhase.upcoming,
    TripPhase.ongoing,
    TripPhase.done,
  ];

  List<TripModel> _trips = const [];
  Map<TripPhase, List<TripModel>> _groups = const {};
  DateTime _today = DateTime.now();
  bool _isLoading = false;
  bool _requiresLogin = false;
  String? _errorMessage;
  int _loadToken = 0;

  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;
  bool get requiresLogin => _requiresLogin;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => !_isLoading && _errorMessage == null && _trips.isEmpty;

  /// Tanggal acuan saat data terakhir dimuat (untuk "Berangkat N hari lagi").
  DateTime get today => _today;

  /// Trip di satu tab, sudah diurutkan.
  List<TripModel> tripsOf(TripPhase phase) => _groups[phase] ?? const [];

  /// Tab yang dibuka pertama: Berjalan jika ada, lalu Diadopsi, Draft, Selesai.
  int get initialTabIndex {
    for (final phase in const [
      TripPhase.ongoing,
      TripPhase.upcoming,
      TripPhase.draft,
      TripPhase.done,
    ]) {
      if (tripsOf(phase).isNotEmpty) return tabOrder.indexOf(phase);
    }
    return tabOrder.indexOf(TripPhase.upcoming);
  }

  Future<void> load() async {
    // Token mencegah hasil load lama menimpa hasil load yang lebih baru.
    final token = ++_loadToken;

    // TODO(AUTH): UID dan status login dari AuthBridge asli (Anggota 1).
    final userId = _auth.currentUserId;
    if (!_auth.isLoggedIn || userId == null) {
      _trips = const [];
      _groups = const {};
      _requiresLogin = true;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _requiresLogin = false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repo.getMyTrips(userId);
      if (token != _loadToken) return;
      _today = DateTime.now();
      _trips = result;
      _groups = _group(result, _today);
    } catch (_) {
      if (token != _loadToken) return;
      _errorMessage = 'Gagal memuat Trip Saya. Periksa koneksi lalu coba lagi.';
    }
    _isLoading = false;
    notifyListeners();
  }

  static Map<TripPhase, List<TripModel>> _group(
    List<TripModel> trips,
    DateTime today,
  ) {
    final groups = {for (final p in TripPhase.values) p: <TripModel>[]};
    for (final t in trips) {
      final phase = t.phaseOn(today);
      if (phase != null) groups[phase]!.add(t); // `copying` tidak tampil
    }
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    int byStart(TripModel a, TripModel b) =>
        (a.startDate ?? epoch).compareTo(b.startDate ?? epoch);

    groups[TripPhase.upcoming]!.sort(byStart); // paling dekat dulu
    groups[TripPhase.ongoing]!.sort(byStart);
    groups[TripPhase.done]!.sort((a, b) => byStart(b, a)); // terbaru dulu
    // Draft: urutan repository (dibuat terbaru dulu).
    return groups;
  }
}