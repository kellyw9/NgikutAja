import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../extras/split_budget_page.dart';

String expenseTime(Trip t, Expense e) {
  final d = t.dayDate(e.day);
  return d == null
      ? 'Hari ${e.day + 1} pukul ${e.time}'
      : 'Hari ${e.day + 1}, ${weekdaysLong[d.weekday - 1]} ${d.day} ${monthsShort[d.month - 1]} pukul ${e.time}';
}

/// 6.5 Pengeluaran: daftar + detail.
class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key, required this.trip});
  final Trip trip;

  void _detail(BuildContext context, Expense e) {
    final app = AppScope.read(context);
    final n = trip.members.length;
    showNgSheet<void>(
      context,
      title: e.name,
      builder: (ctx) => Gap(
        16,
        children: [
          Text(rp(e.amount), style: AppText.display),
          KeyValueBox([
            ('Kategori', e.cat.label),
            ('Waktu', expenseTime(trip, e)),
            ('Dibayar oleh', e.by),
            ('Dibagi ke', '$n orang (${rp((e.amount / n).round())} per orang)'),
          ]),
          Row(
            children: [
              NgButton(
                'Hapus',
                kind: BtnKind.dangerText,
                icon: 'delete',
                onPressed: () async {
                  final r = await showNgDialog(
                    ctx,
                    icon: 'delete',
                    title: 'Hapus pengeluaran ini?',
                    body: '${e.name} (${rp(e.amount)}) dihapus dari catatan dan pembagian biaya.',
                    actions: const [
                      DialogAction('Hapus', kind: BtnKind.danger, value: true),
                      DialogAction('Batal'),
                    ],
                  );
                  if (r == true && ctx.mounted) {
                    Navigator.pop(ctx);
                    app.removeExpense(trip, e);
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NgButton(
                  'Edit',
                  kind: BtnKind.secondary,
                  icon: 'edit',
                  expand: true,
                  onPressed: () {
                    Navigator.pop(ctx);
                    push(context, AddExpensePage(trip: trip, edit: e), fullscreen: true);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppScope.of(context);
    final list = trip.expenses;
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(title: 'Pengeluaran', sub: trip.title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
        children: [
          Gap(
            14,
            children: [
              NgCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total pengeluaran tercatat', style: AppText.small.muted),
                    const SizedBox(height: 4),
                    Text(rp(trip.expenseTotal), style: AppText.display),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: Text('${list.length} pengeluaran, dibagi ${trip.members.length} orang', style: AppText.small.muted)),
                        TextLink(
                          'Split budget',
                          style: AppText.smallStrong,
                          onTap: () => push(context, SplitBudgetPage(trip: trip)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (list.isEmpty)
                const EmptyState(
                  icon: 'payments',
                  title: 'Belum ada pengeluaran',
                  text: 'Catat tiket, makan, dan transportasi supaya pembagian biaya dihitung otomatis.',
                  height: 220,
                )
              else
                BoxList(
                  children: [
                    for (final e in list)
                      Tap(
                        onTap: () => _detail(context, e),
                        child: SizedBox(
                          height: 60,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: [
                                AppIcon(e.cat.icon, size: 22, color: AppColors.muted),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
