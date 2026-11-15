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
