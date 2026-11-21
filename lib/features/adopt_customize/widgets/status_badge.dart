import 'package:flutter/material.dart';

import '../adopt_customize_theme.dart';
import '../models/trip_model.dart';
import '../utils/format_utils.dart';

/// Label tab trip (Draft / Diadopsi / Berjalan / Selesai). Hanya tampilan,
/// TIDAK bisa diklik. Warna mengikuti desain.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.phase});

  final TripPhase phase;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (phase) {
      TripPhase.draft => (NgColors.yellowSoft, const Color(0xFF7A5A00)),
      TripPhase.upcoming => (NgColors.tealSoft, NgColors.teal),
      TripPhase.ongoing => (NgColors.teal, Colors.white),
      TripPhase.done => (const Color(0xFFD9F5E3), const Color(0xFF1E7A46)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tripPhaseLabel(phase),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}