import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/ui.dart';
import '../auth/login_page.dart';
import '../shell/home_shell.dart';
import '../travel/offline_page.dart';

/// 9.7 Pengaturan (+ konfirmasi logout).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final r = await showNgDialog(
      context,
      icon: 'logout',
      title: 'Keluar dari akun?',
