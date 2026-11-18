import 'dart:async';

import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/nav.dart';
import '../core/text.dart';
import '../widgets/app_buttons.dart';
import '../widgets/text_field.dart';
import '../widgets/auth_part.dart';
import '../widgets/status_banner.dart';
import 'new_password.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;
  int _countdown = 59;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    super.dispose();
  }

  void _sendLink() {
    if (!_email.text.contains('@')) return;
    // TODO: panggil API kirim tautan reset di sini.
    setState(() {
      _sent = true;
      _countdown = 59;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  /// "dinda@gmail.com" -> "d•••@gmail.com"
  String get _maskedEmail {
    final parts = _email.text.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return _email.text;
    return '${parts[0][0]}•••@${parts[1]}';
  }

  String get _timerText => '00:${_countdown.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthBackButton(),
              const SizedBox(height: 4),
              const AuthHeader(
                title: 'Atur ulang password',
                subtitle: 'Masukkan email akunmu. Kami kirim tautan untuk membuat password baru.',
              ),
              AppTextField(
                label: 'Email',
                icon: 'mail',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              if (_sent) ...[
                const SizedBox(height: 14),
                StatusBanner(
                  isError: false,
                  title: 'Tautan terkirim',
                  message: 'Cek kotak masuk $_maskedEmail. Kalau tidak ada, lihat folder spam.',
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _countdown == 0 ? _sendLink : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _countdown == 0 ? 'Kirim ulang tautan' : 'Kirim ulang dalam $_timerText',
                      style: _countdown == 0
                          ? AppText.smallStrong.c(AppColors.primaryStrong)
                          : AppText.small.muted,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (!_sent)
                PrimaryButton(label: 'Kirim tautan', onPressed: _sendLink)
              else
                OutlineActionButton(
                  label: 'Kembali ke Masuk',
                  // Login ada di dasar tumpukan (lihat resetTo di onboarding).
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                ),
              // Hanya untuk demo alur: buka layar "Buat password baru".
              if (_sent)
                Center(
                  child: TextButton(
                    onPressed: () => push(context, const NewPasswordScreen()),
                    child: Text('(Demo) Buka tautan dari email', style: AppText.small.muted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}