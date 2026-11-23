import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../models/travel_model.dart';
import 'travel_style.dart';

class OfflineAwareMap extends StatefulWidget {
  final StopModel stop;
  final Widget map;

  const OfflineAwareMap({super.key, required this.stop, required this.map});

  @override
  State<OfflineAwareMap> createState() => _OfflineAwareMapState();
}

class _OfflineAwareMapState extends State<OfflineAwareMap> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then(_update);
    _sub = Connectivity().onConnectivityChanged.listen(_update);
  }

  void _update(List<ConnectivityResult> results) {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (mounted && offline != _offline) setState(() => _offline = offline);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_offline) return widget.map;

    final s = widget.stop;
    final hasCoord = s.latitude != null && s.longitude != null;

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 40, color: TravelColors.muted),
          const SizedBox(height: 8),
          const Text('Peta butuh internet',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(s.placeName, textAlign: TextAlign.center),
          if (hasCoord)
            Text(
              '${s.latitude!.toStringAsFixed(5)}, '
              '${s.longitude!.toStringAsFixed(5)}',
              style: const TextStyle(color: TravelColors.muted, fontSize: 12),
            ),
          const SizedBox(height: 8),
          const Text(
            'Tip: unduh peta area ini di Google Maps (Peta offline) '
            'sebelum berangkat.',
            textAlign: TextAlign.center,
            style: TextStyle(color: TravelColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}