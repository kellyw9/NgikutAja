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
                                    children: [
                                      Text(e.name, style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 2),
                                      Text('Dibayar ${e.by}, Hari ${e.day + 1} pukul ${e.time}', style: AppText.small.muted),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(rp(e.amount), style: AppText.bodyStrong),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 16),
          child: NgButton(
            'Tambah pengeluaran',
            icon: 'add',
            expand: true,
            onPressed: () => push(context, AddExpensePage(trip: trip), fullscreen: true),
          ),
        ),
      ),
    );
  }
}

/// 6.5 Tambah / edit pengeluaran.
class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key, required this.trip, this.edit});
  final Trip trip;
  final Expense? edit;

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  late final e = widget.edit;
  late final name = TextEditingController(text: e?.name ?? '');
  late final amount = TextEditingController(text: e == null ? '' : thousands(e!.amount));
  late ExpenseCat cat = e?.cat ?? ExpenseCat.makan;
  late int day = e?.day ?? AppScope.read(context).currentDay(widget.trip);
  late String by = e?.by ?? widget.trip.members.first.first;
  String? receipt;
  bool tried = false;

  void _save() {
    setState(() => tried = true);
    final n = parseRupiah(amount.text);
    if (name.text.trim().isEmpty || n <= 0) return;
    final app = AppScope.read(context);
    if (e != null) {
      e!
        ..name = name.text.trim()
        ..amount = n
        ..cat = cat
        ..day = day
        ..by = by;
      app.touch();
    } else {
      final now = DateTime.now();
      app.addExpense(
        widget.trip,
        Expense(
          id: 'e${now.microsecondsSinceEpoch}',
          name: name.text.trim(),
          cat: cat,
          amount: n,
          by: by,
          day: day,
          time: fromMinutes(now.hour * 60 + now.minute),
          receipt: receipt,
        ),
      );
    }
    Navigator.pop(context);
    showNgSnack(context, 'Pengeluaran tersimpan.', kind: SnackKind.success);
  }

  @override
  void dispose() {
    name.dispose();
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final date = t.dayDate(day);
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(title: e == null ? 'Tambah pengeluaran' : 'Edit pengeluaran', back: 'close'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
        children: [
          Gap(
            16,
            children: [
              NgField(
                label: 'Nama pengeluaran',
                controller: name,
                hint: 'Misal: Makan siang ikan mas arsik',
                error: tried && name.text.trim().isEmpty ? 'Nama pengeluaran wajib diisi' : null,
                onChanged: (_) => setState(() {}),
              ),
              NgField(
                label: 'Nominal',
                controller: amount,
                prefixText: 'Rp',
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                error: tried && parseRupiah(amount.text) <= 0 ? 'Isi nominal pengeluaran' : null,
                onChanged: (_) => setState(() {}),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategori', style: AppText.bodyStrong),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in ExpenseCat.values) NgChip(c.label, icon: c.icon, selected: c == cat, onTap: () => setState(() => cat = c)),
                    ],
                  ),
                ],
              ),
              NgField(
                label: 'Hari',
                icon: 'event',
                value: date == null
                    ? 'Hari ${day + 1}'
                    : 'Hari ${day + 1}, ${weekdaysLong[date.weekday - 1]} ${date.day} ${monthsShort[date.month - 1]}',
                trailing: 'expand_more',
                onTap: () async {
                  final d = await showNgSheet<int>(
                    context,
                    title: 'Pilih hari',
                    builder: (ctx) => Column(
                      children: [
                        for (var k = 0; k < t.days; k++)
                          RadioRow(
                            title: 'Hari ${k + 1}',
                            sub: t.dayDate(k) == null ? null : dateLong(t.dayDate(k)!),
                            selected: k == day,
                            onTap: () => Navigator.pop(ctx, k),
                          ),
                      ],
                    ),
                  );
                  if (d != null) setState(() => day = d);
