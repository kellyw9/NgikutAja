import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../adopt_customize_routes.dart';
import '../repositories/trip_repository.dart';
import '../services/auth_bridge.dart';
import '../services/payment_checker.dart';
import '../utils/format_utils.dart';
import '../utils/trip_dates.dart';
import '../viewmodels/adopt_view_model.dart';

/// Bottom sheet "Adopt ke Trip Saya". Dibuka dari Detail Itinerary (Anggota 3):
///
///   AdoptBottomSheet.show(context, itineraryId: ..., title: ..., summary: ...,
///       price: ..., sourceDays: ...);
///
/// Parameter opsional (stopCount, creatorName, creatorUsername) dipakai untuk
/// teks dan kartu "Creator asli" di desain. Panggilan lama tetap berjalan.
///
/// Alur (desain): form -> dialog "Adopt itinerary ini?" -> "Menyalin
/// itinerary…" -> "Trip berhasil ditambahkan" atau "Adopt belum berhasil".
///
/// Butuh Provider<AuthBridge>, Provider<TripRepository>, dan
/// Provider<PaymentChecker> di atas widget tree.
class AdoptBottomSheet extends StatelessWidget {
  const AdoptBottomSheet({
    super.key,
    required this.itineraryId,
    required this.title,
    required this.summary,
    required this.price,
    required this.sourceDays,
    this.stopCount,
    this.creatorName,
    this.creatorUsername,
  });

  final String itineraryId;
  final String title;

  /// Ringkasan satu baris, contoh 'Medan · 3 hari · 12 tempat'.
  final String summary;

  /// Harga rupiah. 0 berarti gratis.
  final int price;

  /// Jumlah hari itinerary asli. Tanggal selesai = keberangkatan + sourceDays - 1.
  final int sourceDays;

  /// Jumlah tempat di itinerary (untuk "12 tempat akan disalin…").
  final int? stopCount;

  /// Nama dan username kreator asli (tanpa '@').
  final String? creatorName;
  final String? creatorUsername;

  static Future<void> show(
    BuildContext context, {
    required String itineraryId,
    required String title,
    required String summary,
    required int price,
    required int sourceDays,
    int? stopCount,
    String? creatorName,
    String? creatorUsername,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      builder: (_) => AdoptBottomSheet(
        itineraryId: itineraryId,
        title: title,
        summary: summary,
        price: price,
        sourceDays: sourceDays,
        stopCount: stopCount,
        creatorName: creatorName,
        creatorUsername: creatorUsername,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdoptViewModel>(
      create: (ctx) {
        final vm = AdoptViewModel(
          authBridge: ctx.read<AuthBridge>(),
          tripRepository: ctx.read<TripRepository>(),
          paymentChecker: ctx.read<PaymentChecker>(),
        );
        if (price > 0) vm.checkPayment(itineraryId);
        return vm;
      },
      child: _AdoptSheetBody(sheet: this),
    );
  }
}

class _AdoptSheetBody extends StatefulWidget {
  const _AdoptSheetBody({required this.sheet});

  final AdoptBottomSheet sheet;

  @override
  State<_AdoptSheetBody> createState() => _AdoptSheetBodyState();
}

class _AdoptSheetBodyState extends State<_AdoptSheetBody> {
  late DateTime _startDate;

  AdoptBottomSheet get _s => widget.sheet;

  int get _days => _s.sourceDays < 1 ? 1 : _s.sourceDays;
  DateTime get _endDate => dayDate(_startDate, _days - 1);
  bool get _tooLong => _s.sourceDays > kMaxTripDays;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day + 7);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      helpText: 'Tanggal keberangkatan',
      initialDate: _startDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 730)),
    );
    if (picked == null || !mounted) return;
    setState(() => _startDate = dateOnly(picked));
  }

  Future<void> _confirmAndAdopt() async {
    final count = _s.stopCount;
    final what = count == null ? 'Itinerary ini' : '$count tempat';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.content_copy_outlined),
        title: const Text('Adopt itinerary ini?'),
        content: Text(
          '$what akan disalin ke Trip Saya untuk '
          '${formatDateRange(_startDate, _endDate, _days)}. '
          'Kamu bisa mengubahnya kapan saja.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Adopt'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _adopt();
  }

  Future<void> _adopt() async {
    // Hasil (berhasil/gagal) ditampilkan oleh layar status di build().
    await context.read<AdoptViewModel>().adopt(
      itineraryId: _s.itineraryId,
      startDate: _startDate,
    );
  }

  void _goTo(String path) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(path);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdoptViewModel>();

    final Widget content;
    switch (vm.status) {
      case AdoptStatus.processing:
        content = _CopyingView(stopCount: _s.stopCount);
      case AdoptStatus.success:
        final tripId = vm.newTripId ?? '';
        content = _SuccessView(
          title: _s.title,
          summary: _s.summary,
          dateText: formatDateRange(_startDate, _endDate, _days),
          daysUntil: _daysBetween(DateTime.now(), _startDate),
          onCustomize: () => _goTo(AdoptCustomizeRoutes.customize(tripId)),
          onViewTrip: () => _goTo(AdoptCustomizeRoutes.tripDetail(tripId)),
        );
      case AdoptStatus.failure:
        content = _FailureView(
          message: vm.errorMessage ?? 'Adopt belum berhasil.',
          onBack: vm.reset,
          onRetry: vm.canRetry ? _adopt : null,
        );
      case AdoptStatus.idle:
        content = _buildForm(vm);
    }

    return PopScope(
      canPop: !vm.isProcessing,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: content,
      ),
    );
  }

  Widget _buildForm(AdoptViewModel vm) {
    final theme = Theme.of(context);
    final isPaid = _s.price > 0;
    final paymentOk = !isPaid || vm.hasPaid;
    final canAdopt =
        !vm.isProcessing &&
        !vm.isCheckingPayment &&
        paymentOk &&
        vm.isLoggedIn &&
        !_tooLong;
    final creator = _s.creatorName;
    final username = _s.creatorUsername;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Tutup',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text('Adopt ke Trip Saya', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                // TODO(TAHAP-LANJUT): thumbnail sampul itinerary.
                title: Text(_s.title, style: theme.textTheme.titleSmall),
                subtitle: Text(
                  '${_s.summary} · '
                  '${isPaid ? formatRupiah(_s.price) : 'Gratis'}',
                ),
              ),
            ),
            if (creator != null && creator.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Creator asli', style: theme.textTheme.labelLarge),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text(_initials(creator))),
                title: Text(creator),
                subtitle: Text(
                  [
                    if (username != null && username.isNotEmpty) '@$username',
                    'Kredit tetap tercatat di tripmu walau jadwalnya kamu ubah.',
                  ].join('\n'),
                ),
                isThreeLine: username != null && username.isNotEmpty,
              ),
            ],
            const SizedBox(height: 16),
            Text('Tanggal keberangkatan', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: vm.isProcessing ? null : _pickDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.event),
                  suffixIcon: Icon(Icons.expand_more),
                  border: OutlineInputBorder(),
                ),
                child: Text(formatDateId(_startDate)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _tooLong
                  ? 'Itinerary ini lebih dari $kMaxTripDays hari, jadi belum '
                        'bisa di-Adopt.'
                  : 'Trip selesai ${formatDateId(_endDate)} ($_days hari).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _tooLong ? theme.colorScheme.error : null,
              ),
            ),
            // TODO(KONFIRMASI): desain punya "Pengingat" (sehari sebelum
            // berangkat, sebelum tiap aktivitas 15/30/60 menit) dan "Simpan
            // untuk offline". Belum dibuat: butuh notifikasi lokal dan
            // penyimpanan offline, dan belum jelas modul siapa.
            const SizedBox(height: 16),
            if (!vm.isLoggedIn)
              const _Notice('Silakan login terlebih dahulu untuk Adopt.')
            else if (isPaid && vm.isCheckingPayment)
              const _Notice('Memeriksa status pembayaran…')
            else if (!paymentOk)
              const _Notice(
                'Itinerary ini berbayar. Selesaikan pembayaran agar Adopt aktif.',
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canAdopt ? _confirmAndAdopt : null,
                icon: const Icon(Icons.content_copy_outlined),
                label: const Text('Adopt ke Trip Saya'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase());
    return letters.join();
  }

  static int _daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }
}

// ============================================================ LAYAR STATUS

class _StatusLayout extends StatelessWidget {
  const _StatusLayout({
    required this.icon,
    required this.title,
    required this.message,
    this.extra,
    required this.actions,
  });

  final Widget icon;
  final String title;
  final String message;
  final Widget? extra;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, style: theme.textTheme.bodyMedium),
            if (extra != null) ...[const SizedBox(height: 16), extra!],
            const SizedBox(height: 32),
            for (final a in actions) ...[
              SizedBox(width: double.infinity, child: a),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _CopyingView extends StatelessWidget {
  const _CopyingView({required this.stopCount});

  final int? stopCount;

  @override
  Widget build(BuildContext context) {
    final what = stopCount == null ? 'Tempat' : '$stopCount tempat';
    return _StatusLayout(
      icon: const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
      title: 'Menyalin itinerary…',
      message: '$what, catatan, dan foto sedang disimpan ke Trip Saya.',
      actions: const [FilledButton(onPressed: null, child: Text('Menyalin'))],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.title,
    required this.summary,
    required this.dateText,
    required this.daysUntil,
    required this.onCustomize,
    required this.onViewTrip,
  });

  final String title;
  final String summary;
  final String dateText;
  final int daysUntil;
  final VoidCallback onCustomize;
  final VoidCallback onViewTrip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final depart = daysUntil > 0
        ? 'Berangkat $daysUntil hari lagi.'
        : 'Berangkat hari ini.';
    return _StatusLayout(
      icon: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(Icons.check, color: theme.colorScheme.onPrimaryContainer),
      ),
      title: 'Trip berhasil ditambahkan',
      message: '"$title" sekarang ada di Trip Saya, tab Diadopsi. $depart',
      extra: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          title: Text(title, style: theme.textTheme.titleSmall),
          subtitle: Text('$summary\n$dateText'),
          isThreeLine: true,
          trailing: const Chip(label: Text('Diadopsi')),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: onCustomize,
          child: const Text('Customize jadwal'),
        ),
        FilledButton(onPressed: onViewTrip, child: const Text('Lihat trip')),
      ],
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _StatusLayout(
      icon: Icon(Icons.error_outline, size: 32, color: theme.colorScheme.error),
      title: 'Adopt belum berhasil',
      message: message,
      actions: [
        OutlinedButton(onPressed: onBack, child: const Text('Kembali')),
        if (onRetry != null)
          FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}