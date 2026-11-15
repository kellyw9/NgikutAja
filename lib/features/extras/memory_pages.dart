import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

String photoDayLabel(Trip t, int d) {
  final date = t.dayDate(d);
  return date == null ? 'Hari ${d + 1}' : 'Hari ${d + 1}, ${weekdaysLong[date.weekday - 1]} ${date.day} ${monthsShort[date.month - 1]}';
}

/// 7.5 Photo Memory.
