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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final c in Category.values) ...[
                          NgChip(c.label, selected: c == cat, icon: c.icon, onTap: () => setState(() => cat = c)),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            if (t == null) return;
                            setState(() {
                              final dur = toMinutes(end) - toMinutes(start);
                              start = t;
                              if (dur > 0) end = fromMinutes(toMinutes(t) + dur);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NgField(
                          label: 'Jam selesai',
                          icon: 'schedule',
                          value: end,
                          error: timeErr == null ? null : '',
                          onTap: () async {
                            final t = await pickTime(context, end);
                            if (t != null) setState(() => end = t);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (timeErr != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const AppIcon('error', size: 16, color: AppColors.negative),
                        const SizedBox(width: 6),
                        Text(timeErr!, style: AppText.small.c(AppColors.negative)),
                      ],
                    ),
                  ],
                ],
              ),
              NgField(
                label: 'Biaya',
                controller: cost,
                prefixText: 'Rp',
                hint: '0 kalau gratis',
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
              ),
              NgField(
                label: 'Catatan / local tip',
                icon: 'notes',
                controller: note,
                area: true,
                hint: 'Misal: datang lebih pagi agar dapat tempat duduk.',
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Foto referensi', style: AppText.bodyStrong),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, c) {
                      final w = (c.maxWidth - 12) / 2;
                      return Row(
                        children: [
                          if (photo != null) ...[
                            SizedBox(
                              width: w,
                              height: 94,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Photo(photo, radius: AppRadius.card, semantic: 'Foto referensi'),
                                  Positioned(
                                    left: 8,
                                    bottom: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.tag)),
                                      child: Text('Terpasang', style: AppText.smallStrong),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: IconBtn(
                                      'close',
                                      label: 'Hapus foto',
                                      size: 28,
                                      iconSize: 16,
                                      bg: AppColors.surface,
                                      onTap: () => setState(() => photo = null),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Tap(
                            onTap: () async {
                              final p = await pickPhotoSheet(context, title: 'Foto referensi');
                              if (p != null && p.isNotEmpty) setState(() => photo = p);
                            },
                            radius: AppRadius.card,
                            label: 'Tambah foto',
                            child: DashedBox(
                              radius: AppRadius.card,
                              fill: AppColors.surfaceSoft,
                              child: SizedBox(
                                width: w,
                                height: 94,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const AppIcon('add_a_photo', size: 22),
                                    const SizedBox(height: 6),
                                    Text(photo == null ? 'Tambah foto' : 'Ganti foto', style: AppText.smallStrong),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              NgCard(
                padding: const EdgeInsets.all(12),
                onTap: _pickPoint,
                child: Row(
                  children: [
                    const IconTile('location_on', size: 40, iconSize: 22, fill: AppColors.tealPale),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pilih titik di peta', style: AppText.bodyStrong),
                          const SizedBox(height: 2),
                          Text(address ?? 'Belum dipilih', style: AppText.small.muted, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const AppIcon('chevron_right', size: 20, color: AppColors.muted),
                  ],
                ),
              ),
              if (editing)
                NgButton(
                  'Hapus stop',
                  kind: BtnKind.dangerText,
                  icon: 'delete',
                  expand: true,
                  onPressed: () async {
                    final r = await showNgDialog(
                      context,
                      icon: 'delete',
                      title: 'Hapus ${s!.name}?',
                      body: 'Stop ini dihapus dari hari ini. Jam stop lain tidak ikut bergeser.',
                      actions: const [
                        DialogAction('Hapus stop', kind: BtnKind.danger, value: true),
                        DialogAction('Batal'),
                      ],
                    );
                    if (r == true && context.mounted) Navigator.pop(context, StopEditResult(deleted: true));
                  },
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
          child: NgButton('Simpan stop', expand: true, onPressed: _save),
        ),
      ),
    );
  }
}

/// Langkah 4: Pilih Titik di Peta. Peta masih gambar sementara: ketuk peta untuk memindah pin.
class PickLocationPage extends StatefulWidget {
  const PickLocationPage({super.key, required this.query, required this.city, this.photo});
  final String query;
  final String city;
  final String? photo;

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  late final q = TextEditingController(text: widget.query);
  Offset pin = const Offset(.5, .45);

  @override
  void dispose() {
    q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = q.text.trim().isEmpty ? 'Titik terpilih' : q.text.trim();
    return Scaffold(
      backgroundColor: AppColors.mapLand,
      body: Stack(
        children: [
          Positioned.fill(child: MapView(height: null, radius: 0, label: false, onTapPoint: (p) => setState(() => pin = p))),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, c) {
                final x = pin.dx * c.maxWidth, y = pin.dy * c.maxHeight;
                return Stack(
                  children: [
                    Positioned(
                      left: x - 80,
                      top: y - 84,
                      width: 160,
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.chip)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: AppColors.yellow, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(label, style: AppText.smallStrong.white, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: x - 24,
                      top: y - 46,
                      child: const IgnorePointer(child: AppIcon('location_on', size: 48, filled: true)),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(kMargin, 12, kMargin, 0),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.only(left: 4, right: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.control),
                    border: Border.all(color: AppColors.control),
                    boxShadow: kFloatShadow,
                  ),
                  child: Row(
                    children: [
                      IconBtn('arrow_back', label: 'Kembali', size: 40, iconSize: 20, onTap: () => Navigator.pop(context)),
                      const AppIcon('search', size: 20, color: AppColors.muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: q,
                          style: AppText.body,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration.collapsed(hintText: 'Nama tempat', hintStyle: AppText.body.muted),
                        ),
                      ),
                      if (q.text.isNotEmpty)
                        IconBtn('close', label: 'Hapus teks', size: 40, iconSize: 18, color: AppColors.muted, onTap: () => setState(q.clear)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
          boxShadow: kFloatShadow,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.control, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (widget.photo != null) ...[Photo(widget.photo, width: 76, height: 76, radius: AppRadius.card), const SizedBox(width: 12)],
