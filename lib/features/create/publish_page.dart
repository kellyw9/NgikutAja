import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../explore/itinerary_detail_page.dart';
import '../trips/schedule_logic.dart';
import 'create_itinerary_page.dart';

/// Langkah 5: Publish Itinerary.
class PublishPage extends StatefulWidget {
  const PublishPage({super.key, required this.d});
  final Itinerary d;

  @override
