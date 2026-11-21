import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../adopt_customize_routes.dart';
import '../models/trip_detail.dart';
import '../models/trip_model.dart';
import '../models/trip_stop_model.dart';
import '../repositories/trip_repository.dart';
import '../services/auth_bridge.dart';
import '../adopt_customize_theme.dart';
import '../utils/format_utils.dart';
import '../viewmodels/trip_detail_view_model.dart';
import '../widgets/message_view.dart';
import '../widgets/ng_widgets.dart';
import '../widgets/status_badge.dart';
import '../widgets/trip_card.dart' show departureText;
import '../widgets/trip_cover.dart';
import 'customize_dialogs.dart' show stopTimeRange;

/// Halaman Detail Trip (desain).
class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TripDetailViewModel>(
      create: (ctx) => TripDetailViewModel(
        authBridge: ctx.read<AuthBridge>(),
        tripRepository: ctx.read<TripRepository>(),
      )..load(tripId),
      child: _TripDetailView(tripId: tripId),
    );
  }
}

class _TripDetailView extends StatelessWidget {
  const _TripDetailView({required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TripDetailViewModel>(
        builder: (context, vm, _) {
          final detail = vm.detail;
          if (vm.isLoading && detail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (detail == null) {
            return SafeArea(
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: BackButton(),
                  ),
                  Expanded(
                    child: MessageView(
                      icon: Icons.error_outline,
                      text: vm.errorMessage ?? 'Trip tidak tersedia.',
                      actionLabel: 'Coba lagi',
                      onAction: () => vm.load(tripId),
                    ),
                  ),
                ],
              ),
            );
          }

          Future<void> openCustomize() async {
            await context.push(AdoptCustomizeRoutes.customize(tripId));
            // Muat ulang setelah kembali dari Customize.
            if (context.mounted) vm.load(tripId);
          }

          return _DetailBody(
            detail: detail,
            canEdit: vm.canEdit,
            onCustomize: openCustomize,
          );
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.detail,
    required this.canEdit,
    required this.onCustomize,
  });

  final TripDetail detail;
  final bool canEdit;
  final VoidCallback onCustomize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trip = detail.trip;
    final now = DateTime.now();
    final phase = trip.phaseOn(now) ?? TripPhase.draft;

    return ListView(
      // Jarak bawah ekstra agar isi terakhir tidak tertutup tombol navigasi HP.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      children: [
        // ---- Sampul + tombol kembali
        Stack(
          children: [
            TripCover(url: trip.coverUrl, height: 220),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: theme.colorScheme.surface,
                  child: const BackButton(),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusBadge(phase: phase),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _phaseNote(trip, phase, now),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                trip.title,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: NgColors.teal,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  if (trip.destination.isNotEmpty)
                    IconLabel(
                      icon: Icons.place_outlined,
                      text: trip.destination,
                    ),
                  IconLabel(
                    icon: Icons.calendar_month_outlined,
                    text: formatDateRange(
                      trip.startDate,
                      trip.endDate,
                      trip.durationDays,
                    ),
                  ),
                  IconLabel(
                    icon: Icons.schedule,
                    text: '${trip.durationDays} hari',
                  ),
                ],
              ),
              if (trip.isAdopted) ...[
                const SizedBox(height: 8),
                _CreatorLine(trip: trip),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (canEdit) ...[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onCustomize,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Customize'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // TODO(SHARED_TRIP): halaman Anggota trip (desain sudah ada).
                  const Expanded(
                    child: OutlinedButton(
                      onPressed: null,
                      child: Text('Anggota'),
                    ),
                  ),
                ],
              ),
              if (trip.startDate != null &&
                  (phase == TripPhase.upcoming ||
                      phase == TripPhase.ongoing)) ...[
                const SizedBox(height: 12),
                // TODO(INTEGRASI): aturan Travel Mode milik modul lain.
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.navigation_outlined),
                    title: Text(
                      phase == TripPhase.ongoing
                          ? 'Travel Mode aktif.'
                          : 'Travel Mode aktif mulai '
                                '${formatDateId(trip.startDate)}.',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _FeatureLinks(trip: trip),
              const SizedBox(height: 16),
              Text('Jadwal', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        if (detail.days.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Trip ini belum memiliki hari.'),
          )
        else
          _Schedule(detail: detail, canEdit: canEdit, onCustomize: onCustomize),
        const SizedBox(height: 24),
      ],
    );
  }

  static String _phaseNote(TripModel trip, TripPhase phase, DateTime now) {
    switch (phase) {
      case TripPhase.draft:
        return 'Tanggal belum diatur';
      case TripPhase.upcoming:
        return departureText(trip.daysUntilStart(now) ?? 0);
      case TripPhase.ongoing:
        final day = trip.currentDayNumber(now);
        return day == null ? '' : 'Hari $day dari ${trip.durationDays}';
      case TripPhase.done:
        return 'Trip selesai';
    }
  }
}

/// "RS  Diadopsi dari itinerary @jalanjalanmedan"
class _CreatorLine extends StatelessWidget {
  const _CreatorLine({required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = trip.creatorName?.trim() ?? '';
    final username = trip.creatorUsername?.trim() ?? '';
    final who = username.isNotEmpty
        ? '@$username'
        : (name.isNotEmpty ? name : 'kreator asli');
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          child: Text(
            _initials(name.isNotEmpty ? name : username),
            style: theme.textTheme.labelSmall,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Diadopsi dari itinerary $who',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }
}

/// Menu fitur trip (desain). Semuanya milik modul lain.
/// TODO(INTEGRASI): ganti `onTap: null` dengan rute modul terkait
/// (Split budget, Packing list, Local tips, Trip journal, Photo memory, Recap).
class _FeatureLinks extends StatelessWidget {
  const _FeatureLinks({required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    final end = trip.endDate;
    final items = <(IconData, String, String?)>[
      (Icons.call_split, 'Split budget', null),
      (Icons.backpack_outlined, 'Packing list', null),
      (Icons.place_outlined, 'Local tips', null),
      (Icons.menu_book_outlined, 'Trip journal', 'Ditulis saat trip berjalan'),
      (Icons.photo_library_outlined, 'Photo memory', null),
      (
        Icons.flag_outlined,
        'Trip recap',
        end == null
            ? null
            : 'Tersedia setelah ${formatDateId(end, withWeekday: false)}',
      ),
    ];
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (icon, title, subtitle) in items)
            ListTile(
              dense: true,
              enabled: false,
              leading: Icon(icon),
              title: Text(title),
              subtitle: subtitle == null ? null : Text(subtitle),
              trailing: const Icon(Icons.chevron_right),
            ),
        ],
      ),
    );
  }
}

/// Tab hari + daftar aktivitas hari terpilih.
class _Schedule extends StatelessWidget {
  const _Schedule({
    required this.detail,
    required this.canEdit,
    required this.onCustomize,
  });

  final TripDetail detail;
  final bool canEdit;
  final VoidCallback onCustomize;

  @override
  Widget build(BuildContext context) {
    final days = detail.days;
    return DefaultTabController(
      // Key berubah jika jumlah hari berubah (misal setelah Customize).
      key: ValueKey<int>(days.length),
      length: days.length,
      child: Builder(
        builder: (context) {
          final controller = DefaultTabController.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (final d in days)
                    Tab(
                      text: d.date == null
                          ? 'Hari ${d.dayNumber}'
                          : _shortDate(d.date!),
                    ),
                ],
              ),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  final day = days[controller.index];
                  final stops = detail.stopsOfDay(day.id);
                  if (stops.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Belum ada aktivitas di hari ini.'),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        for (final stop in stops)
                          _StopItem(
                            stop: stop,
                            photoUrl: _firstPhotoUrl(stop.id),
                            onTap: () => _showStopDetail(context, stop),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String? _firstPhotoUrl(String stopId) {
    final photos = detail.photosOfStop(stopId);
    return photos.isEmpty ? null : photos.first.photoUrl;
  }

  /// "Sab, 12 Des"
  static String _shortDate(DateTime d) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }

  /// Bottom sheet detail aktivitas (desain).
  void _showStopDetail(BuildContext context, TripStopModel stop) {
    final photoUrl = _firstPhotoUrl(stop.id);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final range = stopTimeRange(stop);
        final meta = [
          if (categoryLabel(stop.category).isNotEmpty)
            categoryLabel(stop.category),
          if (range.isNotEmpty) range,
          if (formatCost(stop.cost).isNotEmpty) formatCost(stop.cost),
        ].join(' · ');
        final note = stop.note?.trim() ?? '';
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photoUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: TripCover(url: photoUrl, height: 180),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(stop.placeName, style: theme.textTheme.titleMedium),
                if (meta.isNotEmpty)
                  Text(meta, style: theme.textTheme.bodySmall),
                if (stop.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(stop.description),
                ],
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(note)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (canEdit) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            onCustomize();
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // TODO(KONFIRMASI): butuh paket url_launcher (belum ada
                    // di pubspec) untuk membuka Google Maps dari lokasi stop.
                    // FilledButton.icon adalah factory, jadi tidak boleh const.
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Buka di peta'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Satu baris jadwal: nomor, jam, nama, kategori dan biaya, foto kecil.
class _StopItem extends StatelessWidget {
  const _StopItem({
    required this.stop,
    required this.photoUrl,
    required this.onTap,
  });

  final TripStopModel stop;
  final String? photoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final range = stopTimeRange(stop);
    final meta = [
      if (categoryLabel(stop.category).isNotEmpty) categoryLabel(stop.category),
      if (formatCost(stop.cost).isNotEmpty) formatCost(stop.cost),
    ].join(' · ');
    final url = photoUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 13,
              child: Text('${stop.order}', style: theme.textTheme.labelSmall),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (range.isNotEmpty)
                    Text(range, style: theme.textTheme.labelSmall),
                  Text(stop.placeName, style: theme.textTheme.titleSmall),
                  if (meta.isNotEmpty)
                    Text(meta, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (url != null) ...[
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: TripCover(url: url, height: 56),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}