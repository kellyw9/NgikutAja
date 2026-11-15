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
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final email = TextEditingController(text: widget.email);
  bool sent = false;
  bool loading = false;
  String? err;
  int wait = 0;
  Timer? _t;

  Future<void> _send() async {
    setState(() => err = validateEmail(email.text));
    if (err != null) return;
    setState(() => loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      loading = false;
      sent = true;
      wait = 59;
    });
    _t?.cancel();
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => wait--);
