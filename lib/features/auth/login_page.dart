import 'package:flutter/material.dart';
import 'package:path_parsing/path_parsing.dart';

import '../../widgets/ui.dart';
import '../shell/home_shell.dart';
import 'register_page.dart';
import 'reset_password_page.dart';

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String v) {
  if (v.trim().isEmpty) return 'Isi email dulu';
  if (!_emailRe.hasMatch(v.trim())) return 'Format email belum benar';
  return null;
}
