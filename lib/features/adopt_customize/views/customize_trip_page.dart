import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../adopt_customize_theme.dart';
import '../models/trip_day_model.dart';
import '../models/trip_detail.dart';
import '../models/trip_stop_model.dart';
import '../repositories/trip_repository.dart';
import '../services/auth_bridge.dart';
import '../utils/format_utils.dart';
import '../utils/schedule_notes.dart';
import '../utils/trip_dates.dart';
import '../viewmodels/customize_view_model.dart';
import '../widgets/message_view.dart';
import '../widgets/ng_widgets.dart';
import '../widgets/stop_form_sheet.dart';
import 'customize_dialogs.dart';

/// Halaman Customize (desain "Customize trip").
/// Semua perubahan ditampung dulu, lalu disimpan lewat "Simpan" /
/// "Simpan perubahan".
class CustomizeTripPage extends StatelessWidget {
  const CustomizeTripPage({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CustomizeViewModel>(
      create: (ctx) => CustomizeViewModel(
        authBridge: ctx.read<AuthBridge>(),
        tripRepository: ctx.read<TripRepository>(),
      )..load(tripId),
      child: _CustomizeView(tripId: tripId),
    );
  }
}

class _CustomizeView extends StatefulWidget {
  const _CustomizeView({required this.tripId});

  final String tripId;

  @override
  State<_CustomizeView> createState() => _CustomizeViewState();
}

class _CustomizeViewState extends State<_CustomizeView> {
  late final CustomizeViewModel _vm;

  /// True saat form aktivitas terbuka: pesan ditampilkan di dalam form.
  bool _suppressMessages = false;

  /// True selama proses simpan, agar snackbar gagal punya tombol "Coba lagi".
  bool _retryableSave = false;

  /// Tab yang dibuka saat jumlah hari berubah (setelah tambah hari).
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _vm = context.read<CustomizeViewModel>();
    _vm.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _vm.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_suppressMessages) return;
    _flushMessages();
  }

  /// Snackbar hijau (berhasil) atau merah (gagal), seperti di desain.
  void _flushMessages() {
    if (!mounted) return;
    final error = _vm.errorMessage;
    final success = _vm.successMessage;
    if (error == null && success == null) return;
    final retry = error != null && _retryableSave;
    _retryableSave = false;
    _vm.clearMessages();

    final bg = error != null ? NgColors.red : const Color(0xFF2E7D4F);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(
                error != null ? Icons.error_outline : Icons.check_circle,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error ?? success ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          action: retry
              ? SnackBarAction(
                  label: 'Coba lagi',
                  textColor: Colors.white,
                  onPressed: _save,
                )
              : null,
        ),
      );
  }

  // ------------------------------------------------------------- AKSI

  Future<void> _save() async {
    _retryableSave = true;
    await _vm.save();
    _retryableSave = false;
  }

  /// Tombol X / tombol kembali. Minta konfirmasi jika ada perubahan.
  Future<void> _close() async {
    if (_vm.isSaving) return;
    if (_vm.hasUnsavedChanges) {
      final discard = await confirmDiscardChanges(context);
      if (discard != true || !mounted) return;
      _vm.discardChanges();
    }
    if (mounted) context.pop();
  }

  Future<void> _openStopForm({
    required String dayId,
    TripStopModel? stop,
  }) async {
    _suppressMessages = true;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => StopFormPage(vm: _vm, dayId: dayId, stop: stop),
      ),
    );
    _suppressMessages = false;
    if (mounted) _vm.clearMessages();
  }

  Future<void> _confirmDelete(TripStopModel stop) async {
    final ok = await confirmDeleteStop(context, stop.placeName);
    if (ok != true || !mounted) return;
    _vm.deleteStop(stop.id);
  }

  Future<void> _move(TripStopModel stop) async {
    final detail = _vm.detail;
    if (detail == null) return;
    final targetDayId = await askMoveTarget(
      context,
      detail: detail,
      stop: stop,
      previewStartTime: (dayId) =>
          _vm.previewMoveStartTime(stopId: stop.id, targetDayId: dayId),
    );
    if (targetDayId == null || !mounted) return;

    final fromDay = detail.days.firstWhere((d) => d.id == stop.dayId);
    final toDay = detail.days.firstWhere((d) => d.id == targetDayId);
    final ok = await confirmMove(
      context,
      stop: stop,
      fromDay: fromDay,
      toDay: toDay,
      newStartTime: _vm.previewMoveStartTime(
        stopId: stop.id,
        targetDayId: targetDayId,
      ),
    );
    if (ok != true || !mounted) return;
    _vm.moveStop(stopId: stop.id, targetDayId: targetDayId);
  }

  Future<void> _addDay() async {
    final detail = _vm.detail;
    if (detail == null) return;
    final count = detail.days.length;
    final start = detail.trip.startDate;
    final ok = await confirmAddDay(
      context,
      currentDays: count,
      newDate: start == null ? null : dayDate(start, count),
    );
    if (ok != true || !mounted) return;
    if (_vm.addDay()) setState(() => _tabIndex = count); // buka hari baru
  }

  Future<void> _editTripInfo() async {
    final detail = _vm.detail;
    if (detail == null) return;
    final result = await askTripInfo(context, trip: detail.trip);
    if (result == null || !mounted) return;
    _vm.updateTripInfo(
      title: result.title,
      destination: result.destination,
      description: result.description,
      startDate: result.startDate,
      coverSource: result.coverSource,
    );
  }

  Future<void> _openNotes() async {
    final suggestion = await showScheduleNotes(
      context,
      report: _vm.scheduleReport,
    );
    if (suggestion == null || !mounted) return;
    _vm.applySuggestion(suggestion);
  }

  Future<void> _addTripPhoto() async {
    final path = await pickPhotoFromGallery(context);
    if (path == null || !mounted) return;
    _vm.addPhoto(source: path);
  }

  // --------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomizeViewModel>();
    final detail = vm.detail;
    final editable = detail != null && vm.canEdit;

    return PopScope(
      canPop: !vm.hasUnsavedChanges && !vm.isSaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: NgColors.cream,
        appBar: AppBar(
          backgroundColor: NgColors.cream,
          leading: IconButton(
            tooltip: 'Tutup',
            icon: const Icon(Icons.close),
            onPressed: _close,
          ),
          titleSpacing: 0,
          title: const Text('Customize trip'),
          actions: [
            if (editable)
              TextButton(
                onPressed: vm.hasUnsavedChanges && !vm.isSaving ? _save : null,
                child: const Text('Simpan'),
              ),
          ],
        ),
        body: _buildBody(vm, detail),
        bottomNavigationBar: editable ? _SaveBar(vm: vm, onSave: _save) : null,
      ),
    );
  }

  Widget _buildBody(CustomizeViewModel vm, TripDetail? detail) {
    if (vm.isLoading && detail == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (detail == null) {
      return MessageView(
        icon: Icons.error_outline,
        text: vm.loadErrorMessage ?? 'Trip tidak tersedia.',
        actionLabel: 'Coba lagi',
        onAction: () => vm.load(widget.tripId),
      );
    }
    if (!vm.canEdit) {
      return const MessageView(
        icon: Icons.lock_outline,
        text: 'Tidak memiliki izin untuk mengedit trip ini.',
      );
    }
    if (detail.days.isEmpty) {
      return const MessageView(
        icon: Icons.event_busy,
        text: 'Trip ini belum memiliki hari.',
      );
    }

    final enabled = !vm.isSaving;
    final dayCount = detail.days.length;

    return Column(
      children: [
        _TripHeader(detail: detail, onEdit: enabled ? _editTripInfo : null),
        Expanded(
          // Key berubah saat jumlah hari berubah agar TabController dibuat
          // ulang dengan panjang yang benar.
          child: DefaultTabController(
            key: ValueKey<int>(dayCount),
            length: dayCount,
            initialIndex: _tabIndex.clamp(0, dayCount - 1),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        isScrollable: dayCount > 3,
                        tabAlignment: dayCount > 3
                            ? TabAlignment.start
                            : TabAlignment.fill,
                        labelColor: NgColors.teal,
                        unselectedLabelColor: NgColors.textMuted,
                        indicatorColor: NgColors.tealMid,
                        indicatorWeight: 3,
                        dividerColor: NgColors.creamDark,
                        labelStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: [
                          for (final d in detail.days)
                            Tab(text: 'Hari ${d.dayNumber}'),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: (!enabled || dayCount >= kMaxTripDays)
                          ? null
                          : _addDay,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Hari'),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      for (final d in detail.days)
                        _DayEditor(
                          detail: detail,
                          day: d,
                          vm: vm,
                          onAdd: () => _openStopForm(dayId: d.id),
                          onEdit: (s) => _openStopForm(dayId: d.id, stop: s),
                          onMove: _move,
                          onDelete: _confirmDelete,
                          onSeeSuggestions: _openNotes,
                          onAddTripPhoto: _addTripPhoto,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================ WIDGET

class _TripHeader extends StatelessWidget {
  const _TripHeader({required this.detail, required this.onEdit});

  final TripDetail detail;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final trip = detail.trip;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            NgImage(
              source: trip.coverUrl,
              width: 64,
              height: 64,
              radius: 12,
              showPlaceholderText: false,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: NgColors.teal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDateRange(
                      trip.startDate,
                      trip.endDate,
                      detail.days.length,
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: NgColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit informasi trip',
              icon: const Icon(Icons.edit_outlined, color: NgColors.teal),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol "Simpan perubahan" di area putih bawah (desain).
class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.vm, required this.onSave});

  final CustomizeViewModel vm;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: vm.hasUnsavedChanges && !vm.isSaving ? onSave : null,
              child: vm.isSaving
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: NgColors.teal,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Menyimpan…'),
                      ],
                    )
                  : const Text('Simpan perubahan'),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayEditor extends StatelessWidget {
  const _DayEditor({
    required this.detail,
    required this.day,
    required this.vm,
    required this.onAdd,
    required this.onEdit,
    required this.onMove,
    required this.onDelete,
    required this.onSeeSuggestions,
    required this.onAddTripPhoto,
  });

  final TripDetail detail;
  final TripDayModel day;
  final CustomizeViewModel vm;
  final VoidCallback onAdd;
  final void Function(TripStopModel) onEdit;
  final void Function(TripStopModel) onMove;
  final void Function(TripStopModel) onDelete;
  final VoidCallback onSeeSuggestions;
  final VoidCallback onAddTripPhoto;

  @override
  Widget build(BuildContext context) {
    final stops = detail.stopsOfDay(day.id);
    final enabled = !vm.isSaving;
    final notes = vm.notesOfDay(day.id);

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      buildDefaultDragHandles: false,
      itemCount: stops.length,
      proxyDecorator: (child, index, animation) => Material(
        color: NgColors.cream,
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
      onReorder: (oldIndex, newIndex) {
        if (!enabled) return;
        if (newIndex > oldIndex) newIndex -= 1;
        if (newIndex == oldIndex) return;
        vm.reorderStop(stops[oldIndex].id, newIndex);
      },
      header: Column(
        children: [
          for (final note in notes) ...[
            ScheduleNoteBox(
              note: note,
              footer: note.kind == ScheduleNoteKind.conflict
                  ? CustomizeViewModel.scheduleWarningFooter
                  : null,
              onSeeSuggestions: onSeeSuggestions,
            ),
            const SizedBox(height: 16),
          ],
          if (stops.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Belum ada aktivitas di hari ini.',
                style: TextStyle(color: NgColors.textMuted),
              ),
            ),
        ],
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashedBox(
            width: double.infinity,
            height: 56,
            onTap: enabled ? onAdd : null,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: NgColors.teal),
                SizedBox(width: 8),
                Text(
                  'Tambah aktivitas',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: NgColors.teal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Foto trip',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: NgColors.teal,
            ),
          ),
          const SizedBox(height: 12),
          PhotoStrip(
            sources: PhotoStrip.fromPhotos(vm.tripPhotos),
            onAdd: enabled ? onAddTripPhoto : null,
            onRemove: enabled ? (id) => vm.removePhoto(id) : null,
            emptyText: 'Belum ada foto untuk trip ini.',
          ),
        ],
      ),
      itemBuilder: (context, index) {
        final stop = stops[index];
        return _TimelineRow(
          key: ValueKey<String>(stop.id),
          index: index,
          stop: stop,
          isFirst: index == 0,
          isLast: index == stops.length - 1,
          enabled: enabled,
          hasConflict: vm.hasConflict(stop.id),
          canMove: detail.days.length > 1,
          onEdit: () => onEdit(stop),
          onMove: () => onMove(stop),
          onDelete: () => onDelete(stop),
        );
      },
    );
  }
}

/// Satu baris timeline (desain): lingkaran nomor + garis penghubung, jam
/// (merah + ikon peringatan jika bentrok), nama, kategori dan biaya,
/// Edit / Pindahkan / Hapus, dan pegangan geser ⠿ di kanan.
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    super.key,
    required this.index,
    required this.stop,
    required this.isFirst,
    required this.isLast,
    required this.enabled,
    required this.hasConflict,
    required this.canMove,
    required this.onEdit,
    required this.onMove,
    required this.onDelete,
  });

  final int index;
  final TripStopModel stop;
  final bool isFirst;
  final bool isLast;
  final bool enabled;
  final bool hasConflict;
  final bool canMove;
  final VoidCallback onEdit;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final range = stopTimeRange(stop);
    final category = categoryLabel(stop.category);
    final cost = formatCost(stop.cost);
    const lineColor = NgColors.tealMid;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Lingkaran nomor + garis timeline
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 2,
                  color: isFirst ? Colors.transparent : lineColor,
                ),
                NumberBadge(stop.order),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : lineColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // ---- Isi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (range.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          range,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasConflict
                                ? NgColors.red
                                : NgColors.textMuted,
                          ),
                        ),
                        if (hasConflict) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: NgColors.red,
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 2),
                  Text(
                    stop.placeName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: NgColors.teal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Row (bukan Wrap) agar aman di dalam IntrinsicHeight.
                  Row(
                    children: [
                      if (category.isNotEmpty) ...[
                        _IconText(
                          icon: categoryIcon(stop.category),
                          text: category,
                        ),
                        const SizedBox(width: 14),
                      ],
                      if (cost.isNotEmpty)
                        _IconText(icon: Icons.payments_outlined, text: cost),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _ActionText(
                        label: 'Edit',
                        onTap: enabled ? onEdit : null,
                      ),
                      if (canMove)
                        _ActionText(
                          label: 'Pindahkan',
                          onTap: enabled ? onMove : null,
                        ),
                      _ActionText(
                        label: 'Hapus',
                        color: NgColors.red,
                        onTap: enabled ? onDelete : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ---- Pegangan geser (drag and drop)
          Align(
            alignment: Alignment.topCenter,
            child: ReorderableDragStartListener(
              index: index,
              enabled: enabled,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8, 12, 0, 8),
                child: Icon(Icons.drag_indicator, color: NgColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: NgColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: NgColors.textMuted),
        ),
      ],
    );
  }
}

class _ActionText extends StatelessWidget {
  const _ActionText({required this.label, required this.onTap, this.color});

  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 6, 18, 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: onTap == null
                ? NgColors.textMuted
                : (color ?? NgColors.teal),
          ),
        ),
      ),
    );
  }
}