import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/format.dart';
import 'models.dart';
import 'seed.dart';
import 'services.dart';

/// Gagal menyimpan karena perangkat offline (simulasi panggilan ke server).
class OfflineException implements Exception {
  const OfflineException();
}

class CityInfo {
  const CityInfo(this.name, this.photo, this.match);
  final String name;
  final String photo;
  final bool Function(Itinerary) match;
}

/// State aplikasi di memori. Belum ada backend: semua data berasal dari [Seed],
/// lalu berubah sesuai aksi pengguna selama aplikasi berjalan.
class AppState extends ChangeNotifier {
  AppState(this._prefs, {DateTime? now, bool watchNetwork = true}) : seed = Seed(now ?? DateTime.now()) {
    me = seed.me;
    itineraries = [...seed.itineraries];
    drafts = [...seed.drafts];
    trips = [...seed.trips];
    comments = {
      for (final e in seed.comments.entries) e.key: [...e.value],
    };
    transactions = [...seed.transactions];
    notifications = [...seed.notifications];
    recentSearches = [...Seed.recentSearches];
    onboarded = _prefs?.getBool('onboarded') ?? false;
    loggedIn = _prefs?.getBool('loggedIn') ?? false;
    interests = (_prefs?.getStringList('interests') ?? ['Kuliner', 'Budaya']).toSet();
    final saved = _prefs?.getString('accounts');
    if (saved != null) {
      _accounts.addAll((jsonDecode(saved) as Map).cast<String, String>());
    }
    if (watchNetwork) {
      // Plugin koneksi bisa tidak tersedia (tes, platform tertentu): anggap online.
      try {
        _netSub = Network.watch().listen((v) {
          if (v != online) {
            online = v;
            notifyListeners();
          }
        }, onError: (_) {});
        Network.check()
            .then((v) {
              online = v;
              notifyListeners();
            })
            .catchError((_) {});
      } catch (_) {}
    }
  }

  final SharedPreferences? _prefs;
  final Seed seed;
  StreamSubscription<bool>? _netSub;

  DateTime get today => seed.today;
  bool online = true;

  // ---------------- akun ----------------
  late bool onboarded;
  late bool loggedIn;
  late Set<String> interests;

  /// Akun demo: dinda.saragi@gmail.com / ngikutaja. Akun baru dari Register ikut tersimpan di perangkat.
  final Map<String, String> _accounts = {'dinda.saragi@gmail.com': 'ngikutaja'};

  void finishOnboarding(Set<String> picked) {
    onboarded = true;
    interests = picked;
    _prefs?.setBool('onboarded', true);
    _prefs?.setStringList('interests', picked.toList());
    notifyListeners();
  }

  bool emailRegistered(String email) => _accounts.containsKey(email.trim().toLowerCase());

  Future<bool> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final ok = _accounts[email.trim().toLowerCase()] == password;
    if (ok) _setLoggedIn(true);
    return ok;
  }

  Future<void> register(String name, String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _accounts[email.trim().toLowerCase()] = password;
    _prefs?.setString('accounts', jsonEncode(_accounts));
    me.name = name.trim();
    _setLoggedIn(true);
  }

  void resetPassword(String email, String password) {
    _accounts[email.trim().toLowerCase()] = password;
    _prefs?.setString('accounts', jsonEncode(_accounts));
  }

  void logout() => _setLoggedIn(false);

  void _setLoggedIn(bool v) {
    loggedIn = v;
    _prefs?.setBool('loggedIn', v);
    notifyListeners();
  }

  // ---------------- profil ----------------
  late Creator me;

  void updateProfile({required String name, required String username, required String bio}) {
    me
      ..name = name.trim()
      ..handle = '@${username.trim()}'
      ..bio = bio.trim();
    notifyListeners();
  }

  bool usernameAvailable(String u) {
    final h = '@${u.trim().toLowerCase()}';
    if (h == me.handle.toLowerCase()) return true;
    return !seed.creators.values.any((c) => c.handle.toLowerCase() == h) && !seed.followers.any((p) => p.handle == h);
  }

  // ---------------- itinerary ----------------
  late List<Itinerary> itineraries;
  late List<Itinerary> drafts;

  Itinerary itinerary(String id) => itineraries.firstWhere((x) => x.id == id, orElse: () => drafts.firstWhere((x) => x.id == id));

  List<Itinerary> get published => itineraries.where((x) => !x.isDraft && x.creator != me).toList();
  List<Itinerary> get mine => itineraries.where((x) => x.creator == me).toList();

  List<Itinerary> byCreator(Creator c) => itineraries.where((x) => x.creator == c).toList();

  /// Trending: adopsi per hari sejak terbit, itinerary yang cocok dengan minat pengguna diberi bobot 1,5x.
  List<Itinerary> trending() {
    final list = [...published];
    double score(Itinerary x) {
      final age = today.difference(x.publishedAt).inDays.clamp(1, 3650);
      return x.adopted / age * (x.tags.any(interests.contains) ? 1.5 : 1);
    }

    list.sort((a, b) => score(b).compareTo(score(a)));
    return list;
  }

  List<Itinerary> latest() => [...itineraries.where((x) => !x.isDraft)]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

  List<Itinerary> fromFollowing() => latest().where((x) => following.contains(x.creator.id)).toList();

  /// Simulasi mengambil feed dari server.
  Future<void> loadFeed() => Future<void>.delayed(const Duration(milliseconds: 700));

  static final cities = <CityInfo>[
    CityInfo('Medan', 'masjidraya', (x) => x.city == 'Medan'),
    CityInfo('Danau Toba', 'holbung', (x) => x.city == 'Samosir' || x.title.contains('Toba')),
    CityInfo('Yogyakarta', 'tamansari', (x) => x.city == 'Yogyakarta'),
    CityInfo('Bali', 'lovina', (x) => x.region.contains('Bali')),
    CityInfo('Labuan Bajo', 'labuanbajo', (x) => x.city == 'Labuan Bajo'),
    CityInfo('Lombok', 'lombok', (x) => x.region.contains('Lombok')),
  ];

  int cityCount(CityInfo c) => itineraries.where((x) => !x.isDraft && c.match(x)).length;

  // ---------------- wishlist, follow, like ----------------
  final Set<String> wishlist = {'toba', 'bali', 'bajo'};
  final Set<String> following = {};
  final Set<String> liked = {};

  bool toggleWish(String id) {
    final on = !wishlist.contains(id);
    on ? wishlist.add(id) : wishlist.remove(id);
    notifyListeners();
    return on;
  }

  void restoreWish(String id) {
