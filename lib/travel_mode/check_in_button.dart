import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/travel_model.dart';
import 'check_in_service.dart';
import 'travel_style.dart';

class CheckInButton extends StatefulWidget {
  final StopModel stop;

  const CheckInButton({super.key, required this.stop});

  @override
  State<CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<CheckInButton> {
  bool _loading = false;

  Future<void> _doCheckIn({bool simulate = false}) async {
    setState(() => _loading = true);
    final outcome = await CheckInService.checkIn(
      widget.stop,
      bypassDistance: simulate,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    _showMessage(outcome);
  }

  void _showMessage(CheckInOutcome o) {
    String text;
    SnackBarAction? action;

    switch (o.result) {
      case CheckInResult.success:
        text = 'Check-in berhasil di ${widget.stop.placeName}';
        break;
      case CheckInResult.tooFar:
        text = 'Kamu masih ${o.distanceMeters!.round()} m dari lokasi '
            '(maks ${CheckInService.radiusMeters.round()} m)';
        break;
      case CheckInResult.permissionDenied:
        text = 'Izin lokasi ditolak';
        break;
      case CheckInResult.permissionDeniedForever:
        text = 'Izin lokasi ditolak permanen. Aktifkan lewat Pengaturan.';
        action = SnackBarAction(
          label: 'Buka',
          onPressed: Geolocator.openAppSettings,
        );
        break;
      case CheckInResult.serviceDisabled:
        text = 'GPS belum aktif. Nyalakan lokasi lalu coba lagi.';
        break;
      case CheckInResult.noLocation:
        text = 'Stop ini belum punya koordinat lokasi';
        break;
      case CheckInResult.error:
        text = 'Gagal mengambil lokasi. Coba lagi.';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), action: action),
    );
  }

  String _hhmm(DateTime? t) {
    if (t == null) return '';
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, CheckInModel>>(
      valueListenable: CheckInStore.checkIns,
      builder: (_, __, ___) {
        final done = CheckInStore.of(widget.stop.id);

        if (done != null) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFDDF1E6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: TravelColors.done),
                const SizedBox(width: 10),
                Text('Sudah check-in pukul ${_hhmm(done.checkedAt)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : () => _doCheckIn(),
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_loading ? 'Memeriksa lokasi...' : 'Check-in di lokasi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TravelColors.primary,
                  side: const BorderSide(color: TravelColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
            if (kDebugMode)
              TextButton(
                onPressed: _loading ? null : () => _doCheckIn(simulate: true),
                child: const Text('Simulasi check-in (debug saja)'),
              ),
          ],
        );
      },
    );
  }
}