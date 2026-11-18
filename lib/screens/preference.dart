import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/icons.dart';
import '../core/nav.dart';
import '../core/text.dart';
import '../widgets/app_buttons.dart';
import '../widgets/image_box.dart';
import '../widgets/onboarding.dart';
import 'login.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  // (judul, deskripsi, asset gambar, nama ikon pengganti)
  static const _options = [
    ('Alam', 'Gunung, danau, dan pantai', 'assets/images/alam.jpg', 'landscape'),
    ('Kuliner', 'Sesuai tempat makan, makan lokal', 'assets/images/kuliner.jpg', 'restaurant'),
    ('Budaya', 'Situs sejarah, seni, dan museum', 'assets/images/budaya.jpg', 'account_balance'),
  ];

  final Set<String> _selected = {'Kuliner', 'Budaya'};

  void _toggle(String title) {
    setState(() {
      if (!_selected.remove(title)) _selected.add(title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kMargin, 12, kMargin, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingTopBar(
                current: 2,
                onSkip: () => resetTo(context, const LoginScreen()),
              ),
              const SizedBox(height: 20),
              Text('Kamu suka liburan yang seperti apa?', style: AppText.h1),
              const SizedBox(height: 6),
              Text(
                'Pilih satu atau lebih. Feed Explore akan menyesuaikan itinerary yang sesuai.',
                style: AppText.body.muted,
              ),
              const SizedBox(height: 16),
              for (final o in _options) ...[
                _PreferenceCard(
                  title: o.$1,
                  subtitle: o.$2,
                  asset: o.$3,
                  fallbackIcon: o.$4,
                  selected: _selected.contains(o.$1),
                  onTap: () => _toggle(o.$1),
                ),
                const SizedBox(height: 10),
              ],
              Text('${_selected.length} sudah dipilih', style: AppText.small.muted),
              const Spacer(),
              PrimaryButton(
                label: 'Mulai cari itinerary',
                onPressed: _selected.isEmpty ? null : () => resetTo(context, const LoginScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.fallbackIcon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String asset;
  final String fallbackIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.teal : AppColors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              AssetImageBox(
                asset: asset,
                width: 62,
                height: 52,
                radius: BorderRadius.circular(AppRadius.inner),
                fallbackIcon: fallbackIcon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.bodyStrong),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppText.small.muted),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.teal : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppColors.teal : AppColors.control,
                    width: 1.5,
                  ),
                ),
                child: selected ? const AppIcon('check', size: 14, color: AppColors.white) : null,
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}