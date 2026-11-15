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
    AppScope.read(context).finishOnboarding(picked.isEmpty ? {'Alam', 'Kuliner', 'Budaya'} : picked);
    resetTo(context, const HomeShell());
  }

  void _next() {
    if (page < 2) {
      _pc.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: kDarkIcons,
      child: Scaffold(
        backgroundColor: AppColors.ground,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.only(left: kMargin, right: 8),
                  child: Row(
                    children: [
                      Semantics(
                        label: 'Halaman ${page + 1} dari 3',
                        child: Row(
                          children: [
                            for (var k = 0; k < 3; k++) ...[
                              if (k > 0) const SizedBox(width: 6),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: k == page ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(color: k == page ? AppColors.ink : AppColors.sunk, borderRadius: BorderRadius.circular(4)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Spacer(),
                      NgButton('Lewati', kind: BtnKind.text, size: BtnSize.md, onPressed: _finish),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView(controller: _pc, onPageChanged: (i) => setState(() => page = i), children: [_intro(), _flow(), _interests()]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 24),
                child: NgButton(page == 2 ? 'Mulai cari itinerary' : 'Lanjut', expand: true, onPressed: page == 2 && picked.isEmpty ? null : _next),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scroll(List<Widget> children) => LayoutBuilder(
    builder: (context, c) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    ),
  );

  Widget _intro() => LayoutBuilder(
    builder: (context, c) => _scroll([
      Photo('holbung', height: (c.maxHeight - 180).clamp(220, 400), radius: AppRadius.card, semantic: 'Bukit Holbung di tepi Danau Toba'),
      const SizedBox(height: 24),
      Text('Rencana liburan dari orang yang sudah ke sana', style: AppText.h1),
      const SizedBox(height: 12),
      Text('Cari itinerary per kota, lihat rutenya jam demi jam, lalu salin ke tripmu.', style: AppText.body.muted),
    ]),
  );

  Widget _flow() => _scroll([
    Text('Dari rencana orang lain jadi tripmu sendiri', style: AppText.h1),
    const SizedBox(height: 12),
    Text('Lima langkah yang sama dipakai di seluruh aplikasi.', style: AppText.body.muted),
    const SizedBox(height: 28),
    Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Column(
        children: [
          for (var i = 0; i < flow.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 28,
                    child: Column(
                      children: [
                        Marker(i + 1, state: i == 4 ? MarkerState.next : MarkerState.todo),
                        if (i < 4) Expanded(child: Container(width: 3, color: AppColors.teal)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 3, bottom: i < 4 ? 18 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(flow[i].$1, style: AppText.title),
                          const SizedBox(height: 2),
                          Text(flow[i].$2, style: AppText.body.muted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  ]);

  Widget _interests() => _scroll([
    Text('Kamu suka liburan yang seperti apa?', style: AppText.h1),
    const SizedBox(height: 12),
    Text('Pilih satu atau lebih. Feed Explore akan mendahulukan itinerary yang sesuai.', style: AppText.body.muted),
    const SizedBox(height: 24),
    for (final (t, sub, img) in interests) ...[
      _InterestCard(
        title: t,
        sub: sub,
        photo: img,
        on: picked.contains(t),
        onTap: () => setState(() => picked.contains(t) ? picked.remove(t) : picked.add(t)),
      ),
      const SizedBox(height: 12),
    ],
    Text(picked.isEmpty ? 'Pilih minimal satu minat' : '${picked.length} minat dipilih', style: AppText.small.muted),
  ]);
}

class _InterestCard extends StatelessWidget {
  const _InterestCard({required this.title, required this.sub, required this.photo, required this.on, required this.onTap});
  final String title;
  final String sub;
  final String photo;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: on,
    child: NgCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      border: on ? AppColors.teal : AppColors.surface,
