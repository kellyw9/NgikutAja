import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

class StopEditResult {
  StopEditResult({this.stop, this.deleted = false});
  final Stop? stop;
  final bool deleted;
}

const _durations = [15, 30, 45, 60, 90, 120, 150, 180, 240, 300];

Future<String?> pickTime(BuildContext context, String current) async {
  final m = toMinutes(current);
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
    helpText: 'Pilih jam',
    cancelText: 'Batal',
    confirmText: 'Pilih',
    builder: (ctx, child) => MediaQuery(data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true), child: child!),
  );
  return t == null ? null : fromMinutes(t.hour * 60 + t.minute);
}

/// 5.5 Tambah / Edit aktivitas pada trip.
class EditStopPage extends StatefulWidget {
  const EditStopPage({super.key, this.stop, required this.dayLabel, this.defaultStart = '09.00'});
  final Stop? stop;
  final String dayLabel;
  final String defaultStart;

  @override
  State<EditStopPage> createState() => _EditStopPageState();
}

class _EditStopPageState extends State<EditStopPage> {
  late final s = widget.stop;
  late final name = TextEditingController(text: s?.name ?? '');
  late final cost = TextEditingController(text: s == null || s!.cost == 0 ? '' : thousands(s!.cost));
  late final desc = TextEditingController(text: s?.desc ?? '');
  late final note = TextEditingController(text: s?.note ?? '');
  late Category cat = s?.cat ?? Category.budaya;
  late String start = s?.start ?? widget.defaultStart;
  late int duration = s?.duration ?? 60;
  late String? photo = s?.photo;
  bool tried = false;

  String get end => fromMinutes(toMinutes(start) + duration);

  void _save() {
    setState(() => tried = true);
    if (name.text.trim().isEmpty) return;
    final out = (s ?? Stop(start: start, end: end, name: '', cat: cat))
      ..name = name.text.trim()
      ..cat = cat
      ..start = start
      ..end = end
      ..cost = parseRupiah(cost.text)
      ..desc = desc.text.trim().isEmpty ? null : desc.text.trim()
      ..note = note.text.trim().isEmpty ? null : note.text.trim()
      ..photo = photo;
    Navigator.pop(context, StopEditResult(stop: out));
  }

  Future<void> _delete() async {
    final r = await showNgDialog(
      context,
      icon: 'delete',
      title: 'Hapus ${s!.name}?',
      body: 'Aktivitas ini dihapus dari ${widget.dayLabel.split(',').first}. Jam aktivitas setelahnya tidak ikut bergeser.',
      actions: const [
        DialogAction('Hapus aktivitas', kind: BtnKind.danger, value: true),
        DialogAction('Batal'),
      ],
    );
    if (r == true && mounted) Navigator.pop(context, StopEditResult(deleted: true));
  }

  @override
  void dispose() {
    for (final c in [name, cost, desc, note]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = s != null;
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(
        title: editing ? 'Edit aktivitas' : 'Tambah aktivitas',
        sub: widget.dayLabel,
        back: 'close',
        actions: [NgButton('Simpan', kind: BtnKind.text, size: BtnSize.md, onPressed: _save)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
        children: [
          Gap(
            16,
            children: [
              NgField(
                label: 'Nama tempat',
                controller: name,
                hint: 'Misal: Istana Maimun',
                error: tried && name.text.trim().isEmpty ? 'Nama tempat wajib diisi' : null,
                onChanged: (_) => setState(() {}),
              ),
              NgField(
                label: 'Kategori',
                icon: cat.icon,
                value: cat.label,
                trailing: 'expand_more',
                onTap: () async {
                  final c = await pickCategory(context, cat);
                  if (c != null) setState(() => cat = c);
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: NgField(
                      label: 'Jam mulai',
                      icon: 'schedule',
                      value: start,
                      onTap: () async {
                        final t = await pickTime(context, start);
                        if (t != null) setState(() => start = t);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NgField(
                      label: 'Durasi',
                      icon: 'timer',
                      value: durationText(duration),
                      onTap: () async {
                        final d = await showNgSheet<int>(
                          context,
                          title: 'Durasi aktivitas',
