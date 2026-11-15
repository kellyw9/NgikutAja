import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../explore/itinerary_detail_page.dart';
import '../trips/adopt_page.dart';

String txDate(DateTime d) => '${d.day} ${monthsShort[d.month - 1]} ${d.year}, ${fromMinutes(d.hour * 60 + d.minute)}';

const _simNote = NgBanner(kind: BannerKind.info, icon: 'info', text: 'Mode simulasi: tidak ada uang sungguhan yang ditarik.');

class _ItemRow extends StatelessWidget {
  const _ItemRow(this.it);
  final Itinerary it;

  @override
  Widget build(BuildContext context) => NgCard(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        Photo(it.cover, width: 72, height: 72, radius: AppRadius.inner),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(it.title, style: AppText.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              MetaRow([('location_on', it.city), ('schedule', '${it.days} hari'), ('pin_drop', '${it.places} tempat')]),
            ],
          ),
        ),
      ],
    ),
  );
}

/// 8.1 Detail Pembelian.
class PurchaseDetailPage extends StatelessWidget {
  const PurchaseDetailPage({super.key, required this.it});
  final Itinerary it;

  @override
  Widget build(BuildContext context) {
    final perks = [
      '${it.places} tempat lengkap dengan jam dan catatan creator',
      'Peta rute perjalanan ${it.days} hari',
      'Dapat diadopsi dan diedit jadwalnya',
      'Bisa dibuka offline saat berada di ${it.city}',
    ];
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const NgAppBar(title: 'Beli itinerary'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
        children: [
          Gap(
            14,
            children: [
              _ItemRow(it),
              Row(
                children: [
                  Avatar(it.creator.name, size: 36, tint: it.creator.tint),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.creator.name, style: AppText.bodyStrong),
                        const SizedBox(height: 2),
                        Text('${it.creator.handle}, ${thousands(it.creator.followers)} pengikut', style: AppText.small.muted),
                      ],
                    ),
                  ),
                ],
              ),
              NgCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Keuntungan yang kamu peroleh', style: AppText.title),
                    for (final p in perks) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const AppIcon('check', size: 18, color: AppColors.positive),
                          const SizedBox(width: 10),
                          Expanded(child: Text(p, style: AppText.body)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rp(it.price), style: AppText.h2),
                const SizedBox(height: 2),
                Text('Sekali bayar (simulasi)', style: AppText.small.muted),
              ],
            ),
          ),
          NgButton('Lanjut pembayaran', onPressed: () => push(context, PurchaseConfirmPage(it: it))),
        ],
      ),
    );
  }
}

/// 8.2 Konfirmasi Pembelian.
class PurchaseConfirmPage extends StatelessWidget {
  const PurchaseConfirmPage({super.key, required this.it});
  final Itinerary it;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.ground,
    appBar: const NgAppBar(title: 'Konfirmasi pembelian'),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
      children: [
        Gap(
          14,
          children: [
            _ItemRow(it),
            KeyValueBox(
              [('Harga itinerary', rp(it.price)), ('Biaya layanan', rp(0))],
              total: ('Total pembayaran', rp(it.price)),
              fill: AppColors.surface,
            ),
            _simNote,
          ],
        ),
      ],
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 16),
        child: NgButton('Konfirmasi pembelian', expand: true, onPressed: () => push(context, PaymentPage(it: it))),
      ),
    ),
  );
}

const _methods = [
  ('account_balance_wallet', 'E-Wallet', 'GoPay, OVO, DANA'),
  ('account_balance', 'Transfer Bank', 'Virtual account bank'),
  ('qr_code_2', 'QRIS', 'Scan dari aplikasi mobile banking mana pun'),
];

/// 8.3 Pembayaran Simulasi.
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.it, this.method = 'QRIS'});
  final Itinerary it;
  final String method;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late String method = widget.method;
  bool processing = false;

  Future<void> _pay() async {
    final app = AppScope.read(context);
    setState(() => processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final tx = app.startPayment(widget.it, method);
    // Simulasi: transfer bank menunggu dibayar; QRIS dan e-wallet langsung selesai; tanpa koneksi gagal.
    if (!app.online) {
      app.completePayment(tx, success: false);
    } else if (method != 'Transfer Bank') {
      app.completePayment(tx);
    }
    setState(() => processing = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentStatusPage(tx: tx, offlineFail: !app.online, fromFlow: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !processing,
    child: Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(title: 'Pembayaran', sub: 'Total ${rp(widget.it.price)}'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
        children: [
          Gap(
            14,
            children: [
              _simNote,
              Text('Pilih metode pembayaran', style: AppText.h2),
              BoxList(
                children: [
                  for (final (icon, title, sub) in _methods)
                    Opacity(
                      opacity: processing && title != method ? .5 : 1,
                      child: Semantics(
                        inMutuallyExclusiveGroup: true,
                        checked: title == method,
                        child: Tap(
                          onTap: processing ? null : () => setState(() => method = title),
                          child: SizedBox(
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                children: [
                                  AppIcon(icon, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title, style: AppText.bodyStrong),
                                        const SizedBox(height: 2),
                                        Text(sub, style: AppText.small.muted),
                                      ],
                                    ),
                                  ),
