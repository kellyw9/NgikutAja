import 'package:flutter/material.dart';

import '../adopt_customize_theme.dart';
import '../models/trip_stop_model.dart';
import '../utils/format_utils.dart';
import '../utils/time_utils.dart';
import '../viewmodels/customize_view_model.dart';
import '../views/customize_dialogs.dart';
import 'ng_widgets.dart';

/// Halaman "Tambah aktivitas" / "Edit aktivitas" (desain), dibuka layar penuh
/// dari halaman Customize.
///
/// Isian waktu: jam mulai + durasi, jam selesai dihitung otomatis.
/// Form hanya mengubah DRAFT di CustomizeViewModel. Data baru tersimpan
/// saat pengguna menekan "Simpan perubahan" di halaman Customize.
/// Menutup dengan `true` jika draft berubah (tambah, edit, atau hapus).
class StopFormPage extends StatefulWidget {
  const StopFormPage({
    super.key,
    required this.vm,
    required this.dayId,
    this.stop,
  });

  final CustomizeViewModel vm;
  final String dayId;

  /// Null berarti tambah aktivitas baru.
  final TripStopModel? stop;

  @override
  State<StopFormPage> createState() => _StopFormPageState();
}

class _StopFormPageState extends State<StopFormPage> {
  static const String _other = '__other__';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _customCategoryCtrl;
  String? _categoryKey; // kunci kStopCategories, _other, atau null
  String? _startTime;
  int? _duration;

  /// Perubahan foto ditampung dan baru diterapkan saat Simpan.
  final List<String> _newPhotoPaths = [];
  final Set<String> _removedPhotoIds = {};

  bool get _isEdit => widget.stop != null;

  @override
  void initState() {
    super.initState();
    final s = widget.stop;
    _nameCtrl = TextEditingController(text: s?.placeName ?? '');
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _costCtrl = TextEditingController(text: ThousandsFormatter.format(s?.cost));
    _noteCtrl = TextEditingController(text: s?.note ?? '');
    _customCategoryCtrl = TextEditingController();
    final category = s?.category?.trim();
    if (category == null || category.isEmpty) {
      _categoryKey = null;
    } else if (kStopCategories.containsKey(category)) {
      _categoryKey = category;
    } else {
      _categoryKey = _other;
      _customCategoryCtrl.text = category;
    }
    _startTime = s?.startTime;
    _duration = s?.durationMinutes;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _costCtrl.dispose();
    _noteCtrl.dispose();
    _customCategoryCtrl.dispose();
    super.dispose();
  }

  // ----------------------------------------------------- HITUNG OTOMATIS

  String? get _endTime => computeEndTime(_startTime, _duration);

  String? get _timeError {
    final start = parseHHmm(_startTime);
    final d = _duration;
    if (start != null && d != null && start + d > kLastMinuteOfDay) {
      return 'Jadwal tidak boleh melewati pukul 23.59';
    }
    return null;
  }

  /// "Hari 1, Sabtu 12 Des"
  String get _daySubtitle {
    final detail = widget.vm.detail;
    if (detail == null) return '';
    for (final d in detail.days) {
      if (d.id == widget.dayId) {
        return 'Hari ${d.dayNumber}, ${dayDateLabel(d.date, comma: false)}';
      }
    }
    return '';
  }

  String? get _categoryValue {
    if (_categoryKey == _other) {
      final text = _customCategoryCtrl.text.trim();
      return text.isEmpty ? null : text;
    }
    return _categoryKey;
  }

  // ------------------------------------------------------------- AKSI

  Future<void> _pickStart() async {
    final minutes = parseHHmm(_startTime) ?? 9 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      helpText: 'Jam mulai',
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _startTime = formatHHmm(picked.hour * 60 + picked.minute));
  }

  Future<void> _pickDuration() async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => _DurationDialog(initialMinutes: _duration ?? 60),
    );
    if (result == null || !mounted) return;
    setState(() => _duration = result <= 0 ? null : result);
  }

  Future<void> _addPhoto() async {
    final path = await pickPhotoFromGallery(context);
    if (path == null || !mounted) return;
    setState(() => _newPhotoPaths.add(path));
  }

  void _removePhoto(String id) {
    setState(() {
      if (id.startsWith('new:')) {
        _newPhotoPaths.removeAt(int.parse(id.substring(4)));
      } else {
        _removedPhotoIds.add(id);
      }
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_timeError != null) {
      setState(() {}); // tampilkan pesan
      return;
    }
    final vm = widget.vm;
    vm.clearMessages();

    final cost = ThousandsFormatter.parse(_costCtrl.text);
    final existing = widget.stop;

    final String? stopId;
    if (existing == null) {
      stopId = vm.addStop(
        dayId: widget.dayId,
        placeName: _nameCtrl.text,
        description: _descCtrl.text,
        category: _categoryValue,
        startTime: _startTime,
        durationMinutes: _duration,
        cost: cost,
        note: _noteCtrl.text,
      );
    } else {
      final ok = vm.updateStop(
        stopId: existing.id,
        placeName: _nameCtrl.text,
        description: _descCtrl.text,
        category: _categoryValue,
        startTime: _startTime,
        durationMinutes: _duration,
        cost: cost,
        note: _noteCtrl.text,
      );
      stopId = ok ? existing.id : null;
    }
    // Jika gagal, halaman tetap terbuka dan pesan error tampil di bawah.
    if (stopId == null) return;

    for (final id in _removedPhotoIds) {
      vm.removePhoto(id);
    }
    for (final path in _newPhotoPaths) {
      vm.addPhoto(source: path, stopId: stopId);
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final stop = widget.stop;
    if (stop == null) return;
    final confirmed = await confirmDeleteStop(context, stop.placeName);
    if (confirmed != true || !mounted) return;
    if (widget.vm.deleteStop(stop.id) && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  // --------------------------------------------------------------- UI

  List<(String, String)> _photoSources() {
    final stop = widget.stop;
    final existing = stop == null
        ? const <(String, String)>[]
        : PhotoStrip.fromPhotos(
            widget.vm.photosOfStop(stop.id),
          ).where((p) => !_removedPhotoIds.contains(p.$1)).toList();
    return [
      ...existing,
      for (var i = 0; i < _newPhotoPaths.length; i++)
        ('new:$i', _newPhotoPaths[i]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const fieldText = TextStyle(fontSize: 15, color: NgColors.teal);
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (context, _) {
        final saving = widget.vm.isSaving;
        final error = widget.vm.errorMessage;
        final timeError = _timeError;
        final endTime = _endTime;

        return Scaffold(
          backgroundColor: NgColors.cream,
          appBar: AppBar(
            backgroundColor: NgColors.cream,
            leading: IconButton(
              tooltip: 'Tutup',
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isEdit ? 'Edit aktivitas' : 'Tambah aktivitas'),
                if (_daySubtitle.isNotEmpty)
                  Text(
                    _daySubtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: NgColors.textMuted,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : _submit,
                child: const Text('Simpan'),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                NgField(
                  label: 'Nama tempat',
                  child: TextFormField(
                    controller: _nameCtrl,
                    style: fieldText,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama tempat wajib diisi'
                        : null,
                  ),
                ),
                NgField(
                  label: 'Kategori',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _categoryKey,
                        hint: const Text('Pilih kategori'),
                        icon: const Icon(
                          Icons.expand_more,
                          color: NgColors.teal,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            categoryIcon(
                              _categoryKey == _other ? null : _categoryKey,
                            ),
                            color: NgColors.teal,
                          ),
                        ),
                        style: fieldText,
                        dropdownColor: Colors.white,
                        items: [
                          for (final e in kStopCategories.entries)
                            DropdownMenuItem(value: e.key, child: Text(e.value)),
                          const DropdownMenuItem(
                            value: _other,
                            child: Text('Lainnya'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _categoryKey = v),
                      ),
                      if (_categoryKey == _other) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _customCategoryCtrl,
                          style: fieldText,
                          maxLength: 30,
                          decoration: const InputDecoration(
                            hintText: 'Tulis kategori sendiri',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: NgField(
                        label: 'Jam mulai',
                        child: NgTapField(
                          icon: Icons.schedule,
                          text: _startTime == null
                              ? 'Pilih'
                              : formatTimeId(_startTime),
                          onTap: _pickStart,
                          trailing: _startTime == null
                              ? null
                              : _ClearButton(
                                  onTap: () =>
                                      setState(() => _startTime = null),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NgField(
                        label: 'Durasi',
                        child: NgTapField(
                          icon: Icons.timer_outlined,
                          text: _duration == null
                              ? 'Pilih'
                              : formatDuration(_duration),
                          onTap: _pickDuration,
                          trailing: _duration == null
                              ? null
                              : _ClearButton(
                                  onTap: () =>
                                      setState(() => _duration = null),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                NgField(
                  label: 'Jam selesai',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NgTapField(
                        muted: true,
                        text: endTime == null ? '-' : formatTimeId(endTime),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timeError ?? 'Otomatis: jam mulai + durasi.',
                        style: TextStyle(
                          fontSize: 13,
                          color: timeError != null
                              ? NgColors.red
                              : NgColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                NgField(
                  label: 'Biaya per orang',
                  child: TextFormField(
                    controller: _costCtrl,
                    style: fieldText,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsFormatter()],
                    decoration: const InputDecoration(
                      prefixText: 'Rp',
                      prefixStyle: fieldText,
                      hintText: '0 jika gratis',
                    ),
                  ),
                ),
                NgField(
                  label: 'Deskripsi',
                  child: TextFormField(
                    controller: _descCtrl,
                    style: fieldText,
                    minLines: 3,
                    maxLines: 6,
                  ),
                ),
                NgField(
                  label: 'Catatan',
                  child: TextFormField(
                    controller: _noteCtrl,
                    style: fieldText,
                    minLines: 3,
                    maxLines: 6,
                  ),
                ),
                NgField(
                  label: 'Foto',
                  child: PhotoStrip(
                    size: 112,
                    sources: _photoSources(),
                    onAdd: saving ? null : _addPhoto,
                    onRemove: saving ? null : _removePhoto,
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      error,
                      style: const TextStyle(color: NgColors.red),
                    ),
                  ),
                FilledButton(
                  onPressed: saving ? null : _submit,
                  child: Text(
                    _isEdit ? 'Simpan perubahan' : 'Tambah aktivitas',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Tersimpan ke trip setelah kamu menekan "Simpan perubahan" '
                    'di halaman Customize.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: NgColors.textMuted),
                  ),
                ),
                if (_isEdit) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: saving ? null : _delete,
                      style: TextButton.styleFrom(
                        foregroundColor: NgColors.red,
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Hapus aktivitas'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: const Padding(
        padding: EdgeInsets.all(2),
        child: Icon(Icons.close, size: 18, color: NgColors.textMuted),
      ),
    );
  }
}

/// Pilih durasi: jam (0–12) dan menit (kelipatan 5).
class _DurationDialog extends StatefulWidget {
  const _DurationDialog({required this.initialMinutes});

  final int initialMinutes;

  @override
  State<_DurationDialog> createState() => _DurationDialogState();
}

class _DurationDialogState extends State<_DurationDialog> {
  late int _hours;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _hours = (widget.initialMinutes ~/ 60).clamp(0, 12);
    _minutes = (widget.initialMinutes % 60) ~/ 5 * 5;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Durasi'),
      content: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _hours,
              decoration: const InputDecoration(suffixText: 'jam'),
              items: [
                for (var h = 0; h <= 12; h++)
                  DropdownMenuItem(value: h, child: Text('$h')),
              ],
              onChanged: (v) => setState(() => _hours = v ?? 0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _minutes,
              decoration: const InputDecoration(suffixText: 'menit'),
              items: [
                for (var m = 0; m < 60; m += 5)
                  DropdownMenuItem(value: m, child: Text('$m')),
              ],
              onChanged: (v) => setState(() => _minutes = v ?? 0),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: () => Navigator.of(context).pop(_hours * 60 + _minutes),
          child: const Text('Pilih'),
        ),
      ],
    );
  }
}