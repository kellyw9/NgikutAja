import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../shell/home_shell.dart';
import 'login_page.dart';

/// 1.4 Register.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.popOnSuccess = false});
  final bool popOnSuccess;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();
  bool ob1 = true, ob2 = true, loading = false, tried = false;

  (double, String, Color) get strength {
    final p = pass.text;
    if (p.isEmpty) return (0, 'Minimal 8 karakter', AppColors.sunk);
    if (p.length < 8) return (.33, 'Terlalu pendek, minimal 8 karakter', AppColors.negative);
