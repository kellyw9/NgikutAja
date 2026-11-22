import 'package:flutter/material.dart';
import '../models/travel_model.dart';
import 'check_in_service.dart';
import 'travel_style.dart';

class CheckInHistoryPage extends StatelessWidget {
  final List<StopModel> stops;

  const CheckInHistoryPage({super.key, required this.stops});

  String _two(int n) => n.toString().padLeft(2, '0');

  String _formatTime(DateTime? t) {
    if (t == null) return '-';
    return '${_two(t.day)}/${_two(t.month)}/${t.year} '
        '${_two(t.hour)}:${_two(t.minute)}';
  }

  StopModel? _stopOf(String stopId) {
    for (final s in stops) {
      if (s.id == stopId) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TravelColors.background,
      appBar: AppBar(
        backgroundColor: TravelColors.background,
        elevation: 0,
        title: const Text('Riwayat Check-in',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ValueListenableBuilder<Map<String, CheckInModel>>(
        valueListenable: CheckInStore.checkIns,
        builder: (_, map, __) {
          final items = map.values.toList()
            ..sort((a, b) {
              final ta = a.checkedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final tb = b.checkedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return tb.compareTo(ta); // terbaru di atas
            });

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 48, color: TravelColors.muted),
                  SizedBox(height: 8),
                  Text('Belum ada check-in',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Check-in di salah satu stop untuk melihat riwayat.',
                      style: TextStyle(color: TravelColors.muted)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final c = items[i];
              final stop = _stopOf(c.stopId);
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: TravelColors.done),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stop?.placeName ?? 'Stop tidak ditemukan',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(_formatTime(c.checkedAt),
                              style: const TextStyle(
                                  color: TravelColors.muted, fontSize: 12)),
                          if (c.latitude != null && c.longitude != null)
                            Text(
                              '${c.latitude!.toStringAsFixed(5)}, '
                              '${c.longitude!.toStringAsFixed(5)}',
                              style: const TextStyle(
                                  color: TravelColors.muted, fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}