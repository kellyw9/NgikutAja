import 'package:flutter/material.dart';
import '../models/travel_model.dart';
import 'dummy_travel_data.dart';
import 'progress_header.dart';
import 'stop_card.dart';
import 'stop_detail_page.dart';
import 'travel_style.dart';
import 'check_in_service.dart';
import 'check_in_history_page.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class TravelModePage extends StatefulWidget {
  const TravelModePage({super.key});

  @override
  State<TravelModePage> createState() => _TravelModePageState();
}

class _TravelModePageState extends State<TravelModePage> {
  // TODO: ganti dengan data asli (Firestore / offline storage)
  final TripModel trip = DummyTravelData.trip;
  final List<DayModel> days = DummyTravelData.days;
  final List<StopModel> allStops = DummyTravelData.stops;


  @override
  void initState() {
    super.initState();
    CheckInStore.checkIns.addListener(_refresh);
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    await NotificationService.instance.init();
    await NotificationService.instance
        .scheduleAllForTrip(trip, days, allStops);
  }

  @override
  void dispose() {
    CheckInStore.checkIns.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});    
  int selectedDay = 0;

  List<StopModel> get dayStops => allStops
      .where((s) => s.dayId == days[selectedDay].id)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  StopModel? get nextStop {
    for (final s in dayStops) {
      if (!CheckInStore.isCheckedIn(s.id)) return s;
    }
    return null;
  }

  StopStatus statusOf(StopModel s) {
    if (CheckInStore.isCheckedIn(s.id)) return StopStatus.done;
    if (nextStop?.id == s.id) return StopStatus.next;
    return StopStatus.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final stops = dayStops;
    final doneToday = stops.where((s) => CheckInStore.isCheckedIn(s.id)).length;

    return Scaffold(
      backgroundColor: TravelColors.background,
      appBar: AppBar(
        backgroundColor: TravelColors.background,
        elevation: 0,
        title: const Text('Travel Mode',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat check-in',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CheckInHistoryPage(stops: allStops),
              ),
            ),
          ),
          if (kDebugMode)
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Tes notifikasi (10 detik)',
            onPressed: () async {
              await NotificationService.instance.scheduleTest();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notifikasi tes muncul 10 detik lagi')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ProgressHeader(
            title: trip.title,
            subtitle: 'Hari ${days[selectedDay].dayNumber} • ${trip.destination}',
            done: doneToday,
            total: stops.length,
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ChoiceChip(
                label: Text('Hari ${days[i].dayNumber}'),
                selected: selectedDay == i,
                selectedColor: TravelColors.primary,
                labelStyle: TextStyle(
                  color: selectedDay == i ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => setState(() => selectedDay = i),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: stops.isEmpty
                ? const Center(child: Text('Belum ada stop di hari ini'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: stops.length,
                    itemBuilder: (_, i) => StopCard(
                      stop: stops[i],
                      status: statusOf(stops[i]),
                      // TODO: ganti dengan navigasi ke Detail Stop
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StopDetailPage(stop: stops[i]),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}