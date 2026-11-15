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
