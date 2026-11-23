import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/travel_model.dart';
import 'stop_card.dart'; // timeRange()
import 'travel_style.dart';
import 'check_in_button.dart';
import 'offline_map.dart';

class StopDetailPage extends StatelessWidget {
  final StopModel stop;

  const StopDetailPage({super.key, required this.stop});

  bool get hasLocation => stop.latitude != null && stop.longitude != null;

  Future<void> _openGoogleMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${stop.latitude},${stop.longitude}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TravelColors.background,
      appBar: AppBar(
        backgroundColor: TravelColors.background,
        elevation: 0,
        title: Text(stop.placeName,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          OfflineAwareMap(stop: stop, map: _buildMap()),
          const SizedBox(height: 16),
          _buildInfoCard(),
          if ((stop.description).isNotEmpty) ...[
            const SizedBox(height: 12),
            _section('Deskripsi', stop.description),
          ],
          if (stop.note != null && stop.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _section('Catatan / local tip', stop.note!),
          ],
          const SizedBox(height: 20),
          CheckInButton(stop: stop),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: hasLocation ? () => _openGoogleMaps(context) : null,
              icon: const Icon(Icons.navigation),
              label: const Text('Buka di Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TravelColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (!hasLocation) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('Lokasi belum diatur'),
      );
    }

    final point = LatLng(stop.latitude!, stop.longitude!);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          options: MapOptions(initialCenter: point, initialZoom: 16),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.ngikutaja',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on,
                      color: TravelColors.primary, size: 40),
                ),
              ],
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(
                      Uri.parse('https://www.openstreetmap.org/copyright')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.placeName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.schedule,
                      size: 16, color: TravelColors.muted),
                  const SizedBox(width: 6),
                  Text(timeRange(stop)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.payments_outlined,
                      size: 16, color: TravelColors.muted),
                  const SizedBox(width: 6),
                  Text(formatRupiah(stop.cost)),
                ]),
              ],
            ),
          ),
          if (stop.category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: TravelColors.categoryColor(stop.category),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(stop.category!,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _section(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: TravelColors.primary)),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}