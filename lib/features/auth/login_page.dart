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

/// 1.3 Login. [popOnSuccess]: dibuka dari sheet "Masuk dulu", kembali ke halaman sebelumnya setelah masuk.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.popOnSuccess = false});
  final bool popOnSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool obscure = true;
  bool loading = false;
  bool wrong = false;
  String? emailErr;
  String? passErr;

  Future<void> _submit() async {
    setState(() {
      emailErr = validateEmail(email.text);
      passErr = pass.text.isEmpty ? 'Isi password dulu' : null;
      wrong = false;
    });
    if (emailErr != null || passErr != null) return;
    setState(() => loading = true);
    final ok = await AppScope.read(context).login(email.text, pass.text);
    if (!mounted) return;
    setState(() {
      loading = false;
      wrong = !ok;
      passErr = ok ? null : 'Password tidak cocok dengan email ini';
    });
    if (ok) {
      FocusScope.of(context).unfocus();
      if (widget.popOnSuccess) {
        Navigator.pop(context);
        showNgSnack(context, 'Kamu sudah masuk sebagai ${AppScope.read(context).me.name}.', kind: SnackKind.success);
      } else {
        resetTo(context, const HomeShell());
      }
    }
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: kDarkIcons,
      child: Scaffold(
        backgroundColor: AppColors.ground,
        appBar: widget.popOnSuccess ? const NgAppBar(back: 'close') : null,
        body: SafeArea(
