import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/format.dart';
import '../core/icons.dart';
import '../core/nav.dart';
import '../core/text.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../data/services.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import 'basics.dart';
import 'feedback.dart';
import 'inputs.dart';
import 'layout.dart';

/// Pilih tanggal keberangkatan. Rentang [days] hari ikut ditandai.
Future<DateTime?> pickDate(BuildContext context, {required DateTime initial, int days = 1, String title = 'Tanggal keberangkatan', DateTime? first}) {
  return showNgSheet<DateTime>(
    context,
    title: title,
