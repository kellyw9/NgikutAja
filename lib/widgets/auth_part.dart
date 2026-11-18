import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/icons.dart';
import '../core/text.dart';

/// Judul + subjudul di layar login, register, dan reset password.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.h1),
        const SizedBox(height: 6),
        Text(subtitle, style: AppText.body.muted),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Tombol kembali (panah) atau tutup (silang) di kiri atas.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.icon = 'arrow_back'});

  final String icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: icon == 'close' ? 'Tutup' : 'Kembali',
      onPressed: () => Navigator.of(context).pop(),
      icon: AppIcon(icon, size: 24),
      padding: EdgeInsets.zero,
      alignment: Alignment.centerLeft,
    );
  }
}

/// Teks bawah layar: "Belum punya akun? Daftar".
class BottomLink extends StatelessWidget {
  const BottomLink({super.key, required this.text, required this.action, required this.onTap});

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text.rich(
            TextSpan(
              style: AppText.small.muted,
              children: [
                TextSpan(text: '$text '),
                TextSpan(text: action, style: AppText.smallStrong.c(AppColors.primaryStrong)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(child: Text('atau', style: AppText.small.muted)),
    );
  }
}