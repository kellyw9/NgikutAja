import 'package:flutter/material.dart';

import '../adopt_customize_theme.dart';
import '../models/trip_model.dart';
import '../utils/format_utils.dart';
import 'ng_widgets.dart';
import 'status_badge.dart';

/// Kartu Trip Saya (desain). Bagian bawah mengikuti tab:
/// - Diadopsi: "Berangkat N hari lagi"
/// - Berjalan: "Hari 1 dari 2", progres, tombol "Buka Travel Mode"
/// - Selesai: tombol "Lihat recap" dan "Photo memory"
///
/// Tombol fitur modul lain SELALU tampil. Jika callback-nya belum diisi,
/// tombol menampilkan pesan "belum tersambung".
/// TODO(INTEGRASI): Travel Mode (Anggota 5), Trip Recap, Photo Memory.
class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    this.today,
    this.visitedCount,
    this.onOpenTravelMode,
    this.onOpenRecap,
    this.onOpenPhotoMemory,
  });

  final TripModel trip;
  final VoidCallback onTap;

  /// Tanggal acuan. Default: hari ini.
  final DateTime? today;

  /// Jumlah tempat yang sudah dikunjungi (desain: "2 dari 8 tempat").
  /// Datanya milik Travel Mode. Jika null, tampil "8 tempat" saja.
  /// TODO(INTEGRASI): isi dari Travel Mode (Anggota 5).
  final int? visitedCount;

  final VoidCallback? onOpenTravelMode;
  final VoidCallback? onOpenRecap;
  final VoidCallback? onOpenPhotoMemory;

  @override
  Widget build(BuildContext context) {
    final now = today ?? DateTime.now();
    final phase = trip.phaseOn(now) ?? TripPhase.draft;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NgImage(
                      source: trip.coverUrl,
                      width: 104,
                      height: 104,
                      radius: 16,
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: _info(phase)),
                  ],
                ),
                ..._footer(context, phase, now),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(TripPhase phase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trip.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: NgColors.teal,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 2,
          children: [
            if (trip.destination.isNotEmpty)
              IconLabel(icon: Icons.place_outlined, text: trip.destination),
            IconLabel(
              icon: Icons.schedule,
              text: '${trip.durationDays} hari',
            ),
          ],
        ),
        const SizedBox(height: 2),
        IconLabel(
          icon: Icons.calendar_month_outlined,
          text: formatDateRange(
            trip.startDate,
            trip.endDate,
            trip.durationDays,
          ),
        ),
        const SizedBox(height: 8),
        StatusBadge(phase: phase),
      ],
    );
  }

  List<Widget> _footer(BuildContext context, TripPhase phase, DateTime now) {
    switch (phase) {
      case TripPhase.upcoming:
        final days = trip.daysUntilStart(now) ?? 0;
        return [
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: NgColors.cream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconLabel(
              icon: Icons.event_available_outlined,
              text: departureText(days),
            ),
          ),
        ];

      case TripPhase.ongoing:
        final dayNumber = trip.currentDayNumber(now) ?? 1;
        final total = trip.durationDays < 1 ? 1 : trip.durationDays;
        final visited = visitedCount;
        final places = visited == null
            ? '${trip.stopCount} tempat'
            : '$visited dari ${trip.stopCount} tempat';
        const small = TextStyle(fontSize: 13, color: NgColors.textMuted);
        return [
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text('Hari $dayNumber dari $total', style: small),
              ),
              Text(places, style: small),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: dayNumber / total,
              minHeight: 8,
              color: NgColors.tealMid,
              backgroundColor: NgColors.creamDark,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              onPressed:
                  onOpenTravelMode ??
                  () => showNotConnected(context, 'Travel Mode'),
              icon: const Icon(Icons.near_me_outlined),
              label: const Text('Buka Travel Mode'),
            ),
          ),
        ];

      case TripPhase.done:
        return [
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      onOpenRecap ??
                      () => showNotConnected(context, 'Trip recap'),
                  child: const Text('Lihat recap'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: NgColors.creamDark,
                    foregroundColor: NgColors.teal,
                  ),
                  onPressed:
                      onOpenPhotoMemory ??
                      () => showNotConnected(context, 'Photo memory'),
                  child: const Text('Photo memory'),
                ),
              ),
            ],
          ),
        ];

      case TripPhase.draft:
        return const [];
    }
  }
}

/// "Berangkat 38 hari lagi" / "Berangkat besok" / "Berangkat hari ini".
String departureText(int daysUntil) {
  if (daysUntil <= 0) return 'Berangkat hari ini';
  if (daysUntil == 1) return 'Berangkat besok';
  return 'Berangkat $daysUntil hari lagi';
}