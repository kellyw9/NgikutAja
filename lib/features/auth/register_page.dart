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
