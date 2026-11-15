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
