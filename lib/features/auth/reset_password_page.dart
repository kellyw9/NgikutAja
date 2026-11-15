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
