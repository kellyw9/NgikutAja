import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/nav.dart';
import '../core/text.dart';
import '../widgets/app_buttons.dart';
import '../widgets/onboarding.dart';
import 'login.dart';
import 'preference.dart';

class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  static const _steps = [
    ('Create', 'Susun itinerary pertamamu: tempat, jam, dan biaya.'),
    ('Publish', 'Terbitkan gratis atau bersifat privat.'),
    ('Adopt', 'Salin itinerary orang lain ke Trip-Saya.'),
    ('Customize', 'Sesuaikan jam, tambah, atau ganti tempat.'),
    ('Travel', 'Jalankan dengan Travel Mode saat liburan.'),
  ];

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
                current: 1,
                onSkip: () => resetTo(context, const LoginScreen()),
              ),
              const SizedBox(height: 20),
              Text('Dari rencana orang lain jadi tripmu sendiri', style: AppText.h1),
              const SizedBox(height: 6),
              Text('Lima langkah yang dipakai di seluruh aplikasi.', style: AppText.body.muted),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.dialog),
                  ),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _steps.length,
                    itemBuilder: (_, i) => _StepTile(
                      number: i + 1,
                      title: _steps[i].$1,
                      description: _steps[i].$2,
                      isLast: i == _steps.length - 1,
                      highlight: i == _steps.length - 1, // langkah "berikutnya" = kuning
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Lanjut',
                onPressed: () => push(context, const PreferenceScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.title,
    required this.description,
    required this.isLast,
    required this.highlight,
  });

  final int number;
  final String title;
  final String description;
  final bool isLast;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: highlight ? AppColors.yellow : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: highlight ? AppColors.yellow : AppColors.teal,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '$number',
                  style: AppText.smallStrong.copyWith(fontSize: 11, height: 1),
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 1.5, color: AppColors.line)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.bodyStrong),
                  const SizedBox(height: 2),
                  Text(description, style: AppText.small.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}