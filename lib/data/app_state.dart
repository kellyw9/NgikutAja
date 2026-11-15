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
