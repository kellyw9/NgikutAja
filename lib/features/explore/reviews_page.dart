import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 2.3 Review & Komentar.
class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key, required this.it, this.comments = false});
  final Itinerary it;
