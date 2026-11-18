import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/text.dart';

const double _kButtonHeight = 48;
const double _kButtonRadius = 24; // pill, sesuai desain layar

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _kButtonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.sunk,
          disabledForegroundColor: AppColors.control,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kButtonRadius)),
          textStyle: AppText.button,
        ),
        child: Text(label),
      ),
    );
  }
}

class OutlineActionButton extends StatelessWidget {
  const OutlineActionButton({super.key, required this.label, this.onPressed, this.leading});

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _kButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.ink, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kButtonRadius)),
          textStyle: AppText.button,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Text(label),
          ],
        ),
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlineActionButton(
      label: 'Masuk dengan Google',
      onPressed: onPressed,
      // Biru "G" adalah warna merek Google, bukan token NgikutAja.
      leading: Text('G', style: AppText.bodyStrong.c(const Color(0xFF4285F4))),
    );
  }
}