import 'package:flutter/material.dart';
import '../../../../models/travel_model.dart'; // sesuaikan path
import 'travel_style.dart';

enum StopStatus { done, next, upcoming }

String timeRange(StopModel s) {
  final start = s.startTime;
  if (start == null) return '-';
  final dur = s.durationMinutes;
  if (dur == null) return start;
  final p = start.split(':');
  final total = int.parse(p[0]) * 60 + int.parse(p[1]) + dur;
  final h = ((total ~/ 60) % 24).toString().padLeft(2, '0');
  final m = (total % 60).toString().padLeft(2, '0');
  return '$start - $h:$m';
}

class StopCard extends StatelessWidget {
  final StopModel stop;
  final StopStatus status;
  final VoidCallback? onTap;

  const StopCard({
    super.key,
    required this.stop,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNext = status == StopStatus.next;
    final isDone = status == StopStatus.done;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isNext ? TravelColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isDone
                  ? Icons.check_circle
                  : isNext
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
              color: isDone
                  ? TravelColors.done
                  : isNext
                      ? TravelColors.primary
                      : TravelColors.muted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNext)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text('Berikutnya',
                          style: TextStyle(
                              color: TravelColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  Text(
                    stop.placeName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${timeRange(stop)} • ${formatRupiah(stop.cost)}',
                    style: const TextStyle(
                        color: TravelColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (stop.category != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TravelColors.categoryColor(stop.category),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(stop.category!,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}