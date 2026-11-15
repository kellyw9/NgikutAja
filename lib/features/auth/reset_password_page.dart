import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import 'login_page.dart';

String maskEmail(String e) {
  final at = e.indexOf('@');
  if (at < 1) return e;
  return '${e[0]}***${e.substring(at)}';
}

/// 1.5 Reset password: masukkan email, lalu tautan terkirim.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.email = ''});
  final String email;

  @override
