import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../purchase/purchase_pages.dart';
import '../trips/adopt_page.dart';
import 'creator_profile_page.dart';
import 'reviews_page.dart';

/// Buka itinerary: berbayar dan belum dibeli -> preview, selain itu detail lengkap.
void openItinerary(BuildContext context, Itinerary it) => pushItinerary(Navigator.of(context), AppScope.read(context), it);
