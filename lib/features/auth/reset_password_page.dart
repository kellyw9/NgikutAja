import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import 'login_page.dart';

String maskEmail(String e) {
  final at = e.indexOf('@');
  if (at < 1) return e;
  return '${e[0]}***${e.substring(at)}';
}
