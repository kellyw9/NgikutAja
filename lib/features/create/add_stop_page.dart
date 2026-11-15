import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../trips/trip_forms.dart';

export '../trips/trip_forms.dart' show StopEditResult;

/// Langkah 3: Tambah Stop.
class AddStopPage extends StatefulWidget {
  const AddStopPage({super.key, this.stop, required this.city, this.defaultStart = '08.00'});
  final Stop? stop;
  final String city;
  final String defaultStart;

  @override
  State<AddStopPage> createState() => _AddStopPageState();
}

class _AddStopPageState extends State<AddStopPage> {
  late final s = widget.stop;
  late final name = TextEditingController(text: s?.name ?? '');
  late final cost = TextEditingController(text: s == null || s!.cost == 0 ? '' : thousands(s!.cost));
  late final note = TextEditingController(text: s?.note ?? '');
  late Category cat = s?.cat ?? Category.makan;
  late String start = s?.start ?? widget.defaultStart;
  late String end = s?.end ?? fromMinutes(toMinutes(widget.defaultStart) + 60);
  late String? photo = s?.photo;
  late String? address = s?.address;
  bool tried = false;

  String? get timeErr => toMinutes(end) <= toMinutes(start) ? 'Jam selesai harus setelah jam mulai' : null;

  void _save() {
    setState(() => tried = true);
    if (name.text.trim().isEmpty || timeErr != null) return;
    final out = (s ?? Stop(start: start, end: end, name: '', cat: cat))
      ..name = name.text.trim()
      ..cat = cat
      ..start = start
      ..end = end
      ..cost = parseRupiah(cost.text)
      ..note = note.text.trim().isEmpty ? null : note.text.trim()
      ..photo = photo
      ..address = address;
    Navigator.pop(context, StopEditResult(stop: out));
  }

  Future<void> _pickPoint() async {
    final r = await push<String>(context, PickLocationPage(query: name.text.trim(), city: widget.city, photo: photo), fullscreen: true);
    if (r != null) setState(() => address = r);
  }

  @override
  void dispose() {
    name.dispose();
    cost.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = s != null;
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(title: editing ? 'Ubah stop' : 'Tambah stop', back: 'close'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
        children: [
          Gap(
            16,
            children: [
              NgField(
                label: 'Nama tempat',
                icon: 'storefront',
                controller: name,
                hint: 'Misal: Soto Kesawan',
                error: tried && name.text.trim().isEmpty ? 'Nama tempat wajib diisi' : null,
                onChanged: (_) => setState(() {}),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategori', style: AppText.bodyStrong),
                  const SizedBox(height: 8),
