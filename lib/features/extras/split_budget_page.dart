import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 7.1 Split Budget: bagi rata atau kustom (porsi per anggota), lalu siapa transfer ke siapa.
class SplitBudgetPage extends StatefulWidget {
  const SplitBudgetPage({super.key, required this.trip});
  final Trip trip;

  @override
  State<SplitBudgetPage> createState() => _SplitBudgetPageState();
}

class _SplitBudgetPageState extends State<SplitBudgetPage> {
  bool custom = false;
  late final Map<String, int> portion = {for (final m in widget.trip.members) m.first: 1};

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = widget.trip;
    final total = t.expenseTotal;
    final members = t.members;
    final parts = custom ? members.fold<int>(0, (a, m) => a + (portion[m.first] ?? 1)) : members.length;
    int shareOf(Member m) => parts == 0 ? 0 : (total * (custom ? (portion[m.first] ?? 1) : 1) / parts).round();
    int paidBy(Member m) => t.expenses.where((e) => e.by == m.first).fold(0, (a, e) => a + e.amount);
    final net = {for (final m in members) m.first: paidBy(m) - shareOf(m)};

    // Penyelesaian: yang kurang bayar transfer ke yang menerima (greedy).
    final debt = [
      for (final e in net.entries)
        if (e.value < 0) [e.key, -e.value],
    ];
    final cred = [
      for (final e in net.entries)
        if (e.value > 0) [e.key, e.value],
    ];
    final settle = <(String, String, int)>[];
    var di = 0, ci = 0;
    while (di < debt.length && ci < cred.length) {
      final amt = (debt[di][1] as int) < (cred[ci][1] as int) ? debt[di][1] as int : cred[ci][1] as int;
      if (amt > 0) settle.add((debt[di][0] as String, cred[ci][0] as String, amt));
      debt[di][1] = (debt[di][1] as int) - amt;
      cred[ci][1] = (cred[ci][1] as int) - amt;
      if (debt[di][1] == 0) di++;
      if (cred[ci][1] == 0) ci++;
    }

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(title: 'Split budget', sub: t.title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
        children: [
          Gap(
            16,
            children: [
              FactStrip([
                ('Total pengeluaran', rp(total)),
                (custom ? 'Per porsi' : 'Bagi rata per orang', rp(parts == 0 ? 0 : (total / parts).round())),
              ]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Pembagian biaya', style: AppText.h2)),
                      NgChip('Rata', selected: !custom, onTap: () => setState(() => custom = false)),
                      const SizedBox(width: 6),
                      NgChip('Kustom', selected: custom, onTap: () => setState(() => custom = true)),
                    ],
                  ),
                  if (custom) ...[
                    const SizedBox(height: 6),
                    Text('Atur porsi tiap anggota. Misalnya 2 porsi untuk yang membawa pasangan.', style: AppText.small.muted),
                  ],
                  const SizedBox(height: 8),
                  BoxList(
                    inset: 56,
                    children: [
                      for (final m in members)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Avatar(m.name, size: 36, tint: m.tint),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m.first, style: AppText.bodyStrong),
                                        const SizedBox(height: 2),
                                        Text('Sudah bayar ${rp(paidBy(m))}', style: AppText.small.muted),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        net[m.first]! >= 0 ? '+${rp(net[m.first]!)}' : rp(net[m.first]!),
                                        style: AppText.bodyStrong.c(net[m.first]! >= 0 ? AppColors.positive : AppColors.negative),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(net[m.first]! > 0 ? 'menerima' : (net[m.first]! < 0 ? 'kurang bayar' : 'pas'), style: AppText.small.muted),
                                    ],
                                  ),
                                ],
                              ),
                              if (custom) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const SizedBox(width: 48),
                                    Expanded(child: Text('Porsi', style: AppText.small.muted)),
                                    NgStepper(
                                      value: portion[m.first] ?? 1,
                                      unit: ' porsi',
                                      min: 0,
                                      max: 5,
                                      onChanged: (v) => setState(() => portion[m.first] = v),
                                    ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detail penyelesaian saldo', style: AppText.h2),
                  const SizedBox(height: 8),
                  if (settle.isEmpty)
                    Text(
                      total == 0 ? 'Belum ada pengeluaran yang dicatat.' : 'Semua sudah pas, tidak ada yang perlu transfer.',
                      style: AppText.body.muted,
                    )
                  else
                    BoxList(
                      inset: 14,
                      children: [
                        for (final (from, to, amt) in settle)
                          Builder(
                            builder: (context) {
                              final key = '$from>$to';
                              final paid = t.settled.contains(key);
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              style: AppText.body,
                                              children: [
                                                TextSpan(text: from, style: AppText.bodyStrong),
                                                const TextSpan(text: ' transfer ke '),
                                                TextSpan(text: to, style: AppText.bodyStrong),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(rp(amt), style: AppText.small.muted),
                                        ],
                                      ),
                                    ),
                                    paid ? const Pill('Lunas', kind: PillKind.positive, icon: 'check') : const Pill('Belum', kind: PillKind.warning),
                                    const SizedBox(width: 6),
                                    NgToggle(
                                      paid,
                                      label: 'Tandai $from sudah transfer ke $to',
