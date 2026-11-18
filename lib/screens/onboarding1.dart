import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/nav.dart';
import '../core/text.dart';
import '../widgets/app_buttons.dart';
import '../widgets/image_box.dart';
import '../widgets/onboarding.dart';
import 'login.dart';
import 'onboarding2.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

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
                current: 0,
                onSkip: () => resetTo(context, const LoginScreen()),
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: AssetImageBox(
                  asset: 'assets/images/danau.jpg',
                  width: double.infinity,
                  radius: BorderRadius.all(Radius.circular(AppRadius.dialog)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Rencana liburan dari orang yang sudah ke sana', style: AppText.h1),
              const SizedBox(height: 6),
              Text(
                'Cari itinerary perfekmu. Lihat urutan jam, aktivitas, dan tips.',
                style: AppText.body.muted,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Lanjut',
                onPressed: () => push(context, const Onboarding2Screen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}