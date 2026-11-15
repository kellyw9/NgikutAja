import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

class StopEditResult {
  StopEditResult({this.stop, this.deleted = false});
  final Stop? stop;
  final bool deleted;
}

const _durations = [15, 30, 45, 60, 90, 120, 150, 180, 240, 300];

Future<String?> pickTime(BuildContext context, String current) async {
  final m = toMinutes(current);
