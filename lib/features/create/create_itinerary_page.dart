import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../shell/home_shell.dart';
import 'day_editor_page.dart';

const tagOptions = ['Alam', 'Kuliner', 'Budaya', 'Sejarah', 'Hemat', 'Keluarga', 'Petualangan'];

/// Penanda "Draft" di app bar alur Create.
const draftPill = Pill('Draft', kind: PillKind.warning);

/// Simpan draft lalu tutup alur Create dan buka Trip Saya > Draft.
void saveDraftAndClose(BuildContext context, Itinerary d) {
  AppScope.read(context).saveDraft(d);
  goTab(context, tabTrips, trips: TripStatus.draft);
  showNgSnack(context, 'Draft tersimpan di Trip Saya.', kind: SnackKind.success);
}

/// Langkah 1: Buat Itinerary (+ state validasi error).
class CreateItineraryPage extends StatefulWidget {
  const CreateItineraryPage({super.key, this.draft});
  final Itinerary? draft;

  @override
  State<CreateItineraryPage> createState() => _CreateItineraryPageState();
}

class _CreateItineraryPageState extends State<CreateItineraryPage> {
  late final Itinerary d = widget.draft ?? AppScope.read(context).newDraft();
  late final title = TextEditingController(text: d.title);
  late final desc = TextEditingController(text: d.desc);
  late final city = TextEditingController(text: d.region);
  late bool paid = d.price > 0;
  bool tried = false;
  bool touched = false;

  bool get titleOk => title.text.trim().isNotEmpty;

  void _apply() {
    d
      ..title = title.text.trim()
      ..desc = desc.text.trim()
      ..region = city.text.trim()
      ..city = city.text.split(',').first.trim();
    if (!paid) d.price = 0;
    if (paid && d.price == 0) d.price = 25000;
  }

  void _setDays(int n) {
    setState(() {
      touched = true;
      d.days = n;
      while (d.plan.length < n) {
        d.plan.add([]);
      }
      while (d.dayTitles.length < n) {
        d.dayTitles.add('');
      }
      if (d.plan.length > n) d.plan.removeRange(n, d.plan.length);
      if (d.dayTitles.length > n) d.dayTitles.removeRange(n, d.dayTitles.length);
    });
  }

  void _next() {
    setState(() => tried = true);
    if (!titleOk) return;
    _apply();
    push(context, DayEditorPage(d: d));
  }

  Future<void> _addTag() async {
    final input = TextEditingController();
    final r = await showNgSheet<String>(
      context,
      title: 'Tambah tag',
      sub: 'Maksimal 5 tag per itinerary.',
      builder: (ctx) => Gap(
        16,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final t in tagOptions.where((t) => !d.tags.contains(t))) NgChip(t, onTap: () => Navigator.pop(ctx, t))],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: NgField(label: 'Tag lain', controller: input, hint: 'Misal: Pantai', onSubmitted: (v) => Navigator.pop(ctx, v.trim())),
              ),
              const SizedBox(width: 8),
              IconBtn(
                'check',
                label: 'Tambahkan tag',
                bg: AppColors.ink,
                color: AppColors.white,
                size: 48,
                onTap: () => Navigator.pop(ctx, input.text.trim()),
              ),
            ],
          ),
        ],
      ),
    );
    input.dispose();
    if (r != null && r.isNotEmpty && !d.tags.contains(r)) setState(() => d.tags = [...d.tags, r]);
  }

  Future<bool> _confirmClose() async {
    final dirty = touched || title.text.trim() != d.title || desc.text.trim() != d.desc;
    if (!dirty || widget.draft != null) {
      if (widget.draft != null) _apply();
      return true;
    }
    final r = await showNgDialog(
      context,
      title: 'Simpan sebagai draft?',
      body: 'Itinerary ini belum disimpan. Draft bisa dilanjutkan dari Trip Saya.',
      actions: const [
        DialogAction('Simpan draft', kind: BtnKind.primary, value: 'save'),
        DialogAction('Buang', kind: BtnKind.dangerText, value: 'drop'),
      ],
    );
    if (r == 'save' && mounted) {
      _apply();
      saveDraftAndClose(context, d);
      return false;
    }
    return r == 'drop';
  }

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showErr = tried && !titleOk;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmClose() && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.ground,
        appBar: NgAppBar(title: 'Buat itinerary', onBack: () => Navigator.maybePop(context), trailingTitle: draftPill),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
          children: [
            Gap(
              16,
              children: [
                if (showErr)
                  const NgBanner(
                    kind: BannerKind.error,
                    title: 'Lengkapi data yang wajib diisi.',
                    text: 'Pastikan judul itinerary sudah terisi sebelum melanjutkan.',
                  ),
                _cover(),
                NgField(
                  label: 'Judul itinerary',
                  icon: 'notes',
                  controller: title,
                  hint: 'Misal: Kuliner Jogja 3 Hari',
                  error: showErr ? 'Judul wajib diisi' : null,
                  onChanged: (_) => setState(() => touched = true),
                ),
                NgField(
                  label: 'Deskripsi',
                  controller: desc,
                  area: true,
                  hint: 'Ceritakan rute ini dalam dua atau tiga kalimat.',
                  onChanged: (_) => touched = true,
                ),
                NgField(
                  label: 'Kota / destinasi',
                  icon: 'location_on',
                  controller: city,
                  hint: 'Misal: Medan, Sumatera Utara',
                  onChanged: (_) => touched = true,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NgField(
                      label: 'Durasi',
                      icon: 'schedule',
                      value: '${d.days} hari',
                      trailing: 'expand_more',
                      onTap: () async {
                        final n = await showNgSheet<int>(
                          context,
                          title: 'Durasi itinerary',
                          scroll: true,
                          builder: (ctx) => Column(
                            children: [
                              for (var k = 1; k <= 7; k++) RadioRow(title: '$k hari', selected: k == d.days, onTap: () => Navigator.pop(ctx, k)),
                            ],
                          ),
                        );
                        if (n != null) _setDays(n);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const AppIcon('info', size: 16, color: AppColors.muted),
                        const SizedBox(width: 6),
                        Expanded(child: Text('Budget dihitung otomatis dari biaya tiap stop', style: AppText.small.muted)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
