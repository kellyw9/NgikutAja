import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../explore/itinerary_detail_page.dart';

class SearchRequest {
  SearchRequest(this.query);
  final String query;
}

/// Permintaan pencarian dari halaman lain (misalnya kartu kota di Explore).
final searchRequest = ValueNotifier<SearchRequest?>(null);

const _maxBudget = 5000000.0;
const _durations = ['1 hari', '2–3 hari', '4–5 hari', '> 5 hari'];
const _ratings = ['3+', '4+', '4,5+'];
const _sorts = ['Relevan', 'Rating tertinggi', 'Paling banyak diadopsi', 'Harga terendah'];

class SearchFilter {
  String? duration;
  RangeValues budget = const RangeValues(0, _maxBudget);
  String? rating;
  String price = 'Semua';

  bool get budgetOn => budget.start > 0 || budget.end < _maxBudget;
  int get count => [duration != null, budgetOn, rating != null, price != 'Semua'].where((x) => x).length;

  SearchFilter copy() => SearchFilter()
    ..duration = duration
    ..budget = budget
    ..rating = rating
    ..price = price;

  bool match(Itinerary it) {
    final d = it.days;
    if (duration == '1 hari' && d != 1) return false;
    if (duration == '2–3 hari' && (d < 2 || d > 3)) return false;
    if (duration == '4–5 hari' && (d < 4 || d > 5)) return false;
    if (duration == '> 5 hari' && d <= 5) return false;
