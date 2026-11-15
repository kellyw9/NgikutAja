import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../explore/itinerary_detail_page.dart';
import '../extras/journal_page.dart';
import '../extras/memory_pages.dart';
import '../extras/packing_page.dart';
import '../extras/recap_page.dart';
import '../extras/split_budget_page.dart';
import '../extras/tips_page.dart';
import '../travel/offline_page.dart';
import '../travel/travel_mode_page.dart';
import 'customize_page.dart';
import 'members_page.dart';

/// 5.3 Detail Trip.
class TripDetailPage extends StatefulWidget {
  const TripDetailPage({super.key, required this.trip});
