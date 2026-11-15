import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/format.dart';
import '../core/icons.dart';
import '../core/nav.dart';
import '../core/text.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../data/services.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import 'basics.dart';
import 'feedback.dart';
import 'inputs.dart';
import 'layout.dart';

/// Pilih tanggal keberangkatan. Rentang [days] hari ikut ditandai.
Future<DateTime?> pickDate(BuildContext context, {required DateTime initial, int days = 1, String title = 'Tanggal keberangkatan', DateTime? first}) {
  return showNgSheet<DateTime>(
    context,
    title: title,
    scroll: true,
    builder: (_) => _Calendar(initial: initial, days: days, first: first ?? AppScope.read(context).today),
  );
}

class _Calendar extends StatefulWidget {
  const _Calendar({required this.initial, required this.days, required this.first});
  final DateTime initial;
  final int days;
  final DateTime first;

  @override
  State<_Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<_Calendar> {
  late DateTime sel = widget.initial;
  late DateTime month = DateTime(widget.initial.year, widget.initial.month);

  @override
  Widget build(BuildContext context) {
    final lead = DateTime(month.year, month.month, 1).weekday - 1; // Senin = 0
    final count = DateUtils.getDaysInMonth(month.year, month.month);
    final cells = <int?>[...List.filled(lead, null), for (var d = 1; d <= count; d++) d];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    final end = sel.add(Duration(days: widget.days - 1));
    bool same(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
    final firstMonth = DateTime(widget.first.year, widget.first.month);

    Widget cell(int? d) {
      if (d == null) return const Expanded(child: SizedBox(height: 40));
      final date = DateTime(month.year, month.month, d);
      final disabled = date.isBefore(widget.first);
      final isEdge = same(date, sel) || same(date, end);
      final inRange = date.isAfter(sel) && date.isBefore(end);
      return Expanded(
        child: Container(
          height: 40,
          color: inRange ? AppColors.tealPale : null,
          alignment: Alignment.center,
          child: Semantics(
            button: true,
            selected: isEdge,
            enabled: !disabled,
            label: dateLong(date),
            child: InkWell(
              onTap: disabled ? null : () => setState(() => sel = date),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: isEdge ? AppColors.ink : null, borderRadius: BorderRadius.circular(4)),
                child: Text(
                  '$d',
                  style: (isEdge ? AppText.bodyStrong : AppText.body).c(isEdge ? AppColors.white : (disabled ? AppColors.control : AppColors.ink)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Gap(
      16,
      children: [
        Row(
          children: [
            IconBtn(
              'chevron_left',
              label: 'Bulan sebelumnya',
              size: 36,
              iconSize: 20,
              onTap: month.isAfter(firstMonth) ? () => setState(() => month = DateTime(month.year, month.month - 1)) : null,
            ),
            Expanded(
              child: Text('${monthsLong[month.month - 1]} ${month.year}', style: AppText.title, textAlign: TextAlign.center),
            ),
            IconBtn(
              'chevron_right',
              label: 'Bulan berikutnya',
              size: 36,
              iconSize: 20,
              onTap: () => setState(() => month = DateTime(month.year, month.month + 1)),
            ),
          ],
        ),
        Column(
          children: [
            Row(
              children: [
                for (final d in weekdaysShort)
                  Expanded(
                    child: SizedBox(
                      height: 28,
                      child: Center(child: Text(d, style: AppText.small.muted)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            for (var r = 0; r < cells.length / 7; r++) Row(children: [for (final d in cells.sublist(r * 7, r * 7 + 7)) cell(d)]),
          ],
        ),
        Text(
          widget.days > 1
              ? '${dateShort(sel).replaceFirst(weekdaysShort[sel.weekday - 1], weekdaysLong[sel.weekday - 1])} sampai '
                    '${weekdaysLong[end.weekday - 1]}, ${end.day} ${monthsShort[end.month - 1]} ${end.year} (durasi ${widget.days} hari)'
              : dateLong(sel),
          style: AppText.body.muted,
        ),
        NgButton('Pilih tanggal ini', expand: true, onPressed: () => Navigator.pop(context, sel)),
      ],
    );
  }
}

/// Pilih kategori aktivitas (radio).
Future<Category?> pickCategory(BuildContext context, Category current) {
  return showNgSheet<Category>(
    context,
    title: 'Kategori aktivitas',
    builder: (ctx) => Column(
      children: [
        for (var i = 0; i < Category.values.length; i++) ...[
          if (i > 0) const NgDivider(inset: 40, color: AppColors.line),
          Tap(
            onTap: () => Navigator.pop(ctx, Category.values[i]),
            child: Semantics(
              inMutuallyExclusiveGroup: true,
              checked: Category.values[i] == current,
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    AppIcon(Category.values[i].icon, size: 22),
                    const SizedBox(width: 14),
                    Expanded(child: Text(Category.values[i].label, style: AppText.bodyStrong)),
                    RadioMark(Category.values[i] == current),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

/// Ambil foto dari kamera/galeri, atau hapus foto. Mengembalikan kunci foto baru,
/// '' kalau foto dihapus, atau null kalau batal.
Future<String?> pickPhotoSheet(BuildContext context, {String title = 'Tambah foto', bool canRemove = false}) async {
  final choice = await showNgSheet<String>(
    context,
    title: title,
    builder: (ctx) => Column(
      children: [
        ListRow(icon: 'photo_camera', title: 'Ambil dengan kamera', trailing: null, padH: 0, onTap: () => Navigator.pop(ctx, 'camera')),
        const NgDivider(inset: 36, color: AppColors.line),
        ListRow(icon: 'photo_library', title: 'Pilih dari galeri foto', trailing: null, padH: 0, onTap: () => Navigator.pop(ctx, 'gallery')),
        if (canRemove) ...[
          const NgDivider(inset: 36, color: AppColors.line),
          ListRow(icon: 'delete', title: 'Hapus foto', danger: true, trailing: null, padH: 0, onTap: () => Navigator.pop(ctx, 'remove')),
        ],
      ],
    ),
  );
  if (choice == null) return null;
  if (choice == 'remove') return '';
  try {
    return await pickPhoto(choice == 'camera' ? PhotoSource.camera : PhotoSource.gallery);
