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
      if (wait <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const NgAppBar(),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 24),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Atur ulang password', style: AppText.h1),
                    const SizedBox(height: 8),
                    Text('Masukkan email akunmu. Kami kirim tautan untuk membuat password baru.', style: AppText.body.muted),
                    const SizedBox(height: 24),
                    NgField(
                      label: 'Email',
                      icon: 'mail',
                      controller: email,
                      hint: 'nama@email.com',
                      error: err,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: sent,
                      onSubmitted: (_) => _send(),
                    ),
                    if (sent) ...[
                      const SizedBox(height: 24),
                      NgBanner(
                        kind: BannerKind.success,
                        title: 'Tautan terkirim',
                        text: 'Cek kotak masuk ${maskEmail(email.text.trim())}. Kalau tidak ada, lihat folder spam.',
                      ),
                      const SizedBox(height: 16),
                      if (wait > 0)
                        Text('Kirim ulang dalam 00.${wait.toString().padLeft(2, '0')}', style: AppText.small.muted)
                      else
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextLink('Kirim ulang tautan', onTap: _send),
                        ),
                    ],
                    const Spacer(),
                    const SizedBox(height: 24),
                    sent
                        ? NgButton('Kembali ke Masuk', kind: BtnKind.secondary, expand: true, onPressed: () => Navigator.pop(context))
                        : NgButton('Kirim tautan', expand: true, loading: loading, onPressed: _send),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 1.5 Buat password baru. Dibuka dari tautan di email (rute /reset-password?email=...).
class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key, required this.email});
  final String email;

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final p1 = TextEditingController();
  final p2 = TextEditingController();
  bool o1 = true, o2 = true, tried = false;

  String? get e1 {
    if (!tried) return null;
    final p = p1.text;
    if (p.length < 8) return 'Minimal 8 karakter';
    if (!(RegExp(r'[A-Za-z]').hasMatch(p) && RegExp(r'\d').hasMatch(p))) return 'Campur huruf dan angka';
    return null;
  }

  String? get e2 => p2.text.isNotEmpty && p2.text != p1.text ? 'Password belum sama' : null;

  void _save() {
    setState(() => tried = true);
    if (e1 != null || e2 != null || p2.text.isEmpty) return;
    AppScope.read(context).resetPassword(widget.email, p1.text);
    resetTo(context, const LoginPage());
    showNgSnack(context, 'Password baru tersimpan. Silakan masuk.', kind: SnackKind.success);
  }

  @override
  void dispose() {
    p1.dispose();
    p2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(back: 'close', onBack: () => resetTo(context, const LoginPage())),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 24),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Buat password baru', style: AppText.h1),
                    const SizedBox(height: 8),
                    Text('Untuk akun ${widget.email}.', style: AppText.body.muted),
                    const SizedBox(height: 24),
                    NgField(
                      label: 'Password baru',
                      icon: 'lock',
                      controller: p1,
                      obscure: o1,
                      onChanged: (_) => setState(() {}),
                      helper: 'Minimal 8 karakter, campur huruf dan angka.',
                      error: e1,
                      trailing: ObscureToggle(obscured: o1, onTap: () => setState(() => o1 = !o1)),
                    ),
                    const SizedBox(height: 14),
                    NgField(
                      label: 'Konfirmasi password baru',
                      icon: 'lock',
