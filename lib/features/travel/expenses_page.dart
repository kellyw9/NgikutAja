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
