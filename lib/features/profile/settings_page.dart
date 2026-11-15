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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.body),
                  if (sub != null) ...[const SizedBox(height: 2), Text(sub, style: AppText.small.muted)],
                ],
              ),
            ),
            const SizedBox(width: 12),
            NgToggle(app.settings[key]!, label: title, onChanged: (v) => app.setSetting(key, v)),
          ],
        ),
      ),
    );
    Widget group(String title, List<Widget> rows) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.smallStrong.muted),
        const SizedBox(height: 6),
        BoxList(inset: 14, children: rows),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const NgAppBar(title: 'Pengaturan'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
        children: [
          Gap(
            16,
            children: [
              group('Aplikasi', [ListRow(icon: 'language', title: 'Bahasa tampilan', sub: 'Bahasa Indonesia', trailing: null, padH: 14)]),
              group('Notifikasi pengingat', [
                sw('remindEach', 'Pengingat sebelum aktivitas', '30 menit sebelumnya'),
                sw('remindDayBefore', 'Pengingat H-1 perjalanan', 'Pukul 19.00 malam sebelum berangkat'),
                sw('invites', 'Undangan trip bersama'),
                sw('social', 'Interaksi sosial (like dan komentar)'),
                sw('payments', 'Status transaksi dan pembelian'),
              ]),
              group('Penyimpanan offline', [
                sw('autoDownload', 'Unduh otomatis trip yang diadopsi', 'Hanya melalui jaringan Wi-Fi'),
                ListRow(
                  icon: 'download_for_offline',
                  title: 'Kelola data offline',
                  sub: offline.isEmpty
                      ? 'Belum ada trip tersimpan'
                      : '${offline.length} trip tersimpan (${offline.fold(0, (a, t) => a + t.offlineSize)} MB)',
                  padH: 14,
                  onTap: () => push(context, const OfflinePage()),
