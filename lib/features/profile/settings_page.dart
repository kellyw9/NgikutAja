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
      body: 'Trip yang tersimpan offline tetap tersimpan di perangkat ini sampai kamu masuk dengan akun lain.',
      actions: const [
        DialogAction('Keluar', kind: BtnKind.danger, value: true),
        DialogAction('Batal'),
      ],
    );
    if (r == true && context.mounted) {
      AppScope.read(context).logout();
      shellTab.value = tabExplore;
      resetTo(context, const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final offline = app.trips.where((t) => t.offline).toList();
    Widget sw(String key, String title, [String? sub]) => ConstrainedBox(
      constraints: BoxConstraints(minHeight: sub != null ? 60 : 50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
