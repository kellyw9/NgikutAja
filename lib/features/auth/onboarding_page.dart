import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../shell/home_shell.dart';

/// 1.2 Onboarding: pengenalan, alur lima langkah, pilih minat.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pc = PageController();
  int page = 0;
  final Set<String> picked = {'Kuliner', 'Budaya'};

  static const flow = [
    ('Create', 'Susun itinerary per hari: tempat, jam, dan biaya.'),
    ('Publish', 'Terbitkan gratis atau berbayar.'),
    ('Adopt', 'Salin itinerary orang lain ke Trip Saya.'),
    ('Customize', 'Geser jam, tambah, atau pindahkan tempat.'),
    ('Travel', 'Jalankan dengan Travel Mode saat liburan.'),
  ];

  static const interests = [
    ('Alam', 'Danau, bukit, dan pantai', 'toba'),
    ('Kuliner', 'Sarapan pasar sampai makan malam', 'soto'),
    ('Budaya', 'Istana, rumah tua, dan museum', 'maimun'),
  ];

  void _finish() {
