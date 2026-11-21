// SEMENTARA: HAPUS SETELAH SELESAI DICOBA
// Pengganti halaman Detail Itinerary (Anggota 3). Memanggil repository
// langsung HANYA karena ini stand-in. UI asli memakai ViewModel.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/itinerary_source_repository.dart';
import '../services/auth_bridge.dart';
import '../services/payment_checker.dart';
import '../utils/format_utils.dart';
import '../views/adopt_bottom_sheet.dart';
import 'dummy_data.dart';

class DummyItineraryDetailPage extends StatefulWidget {
  const DummyItineraryDetailPage({super.key, required this.itineraryId});

  final String itineraryId;

  @override
  State<DummyItineraryDetailPage> createState() =>
      _DummyItineraryDetailPageState();
}

class _DummyItineraryDetailPageState extends State<DummyItineraryDetailPage> {
  SourceItinerary? _source;
  bool _loading = true;
  bool _paid = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Dependensi dibaca sebelum await.
    final sourceRepo = context.read<ItinerarySourceRepository>();
    final auth = context.read<AuthBridge>();
    final payment = context.read<PaymentChecker>();
    try {
      final source = await sourceRepo.getItinerary(widget.itineraryId);
      var paid = false;
      final userId = auth.currentUserId;
      if (source != null && source.price > 0 && userId != null) {
        paid = await payment.hasPaid(userId: userId, itineraryId: source.id);
      }
      if (!mounted) return;
      setState(() {
        _source = source;
        _paid = paid;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat itinerary';
        _loading = false;
      });
    }
  }

  void _pay(SourceItinerary source) {
    final userId = context.read<AuthBridge>().currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }
    // TODO(PAYMENT): alur pembayaran asli milik Anggota 6.
    context.read<DummyPaymentChecker>().markPaid(
      userId: userId,
      itineraryId: source.id,
    );
    setState(() => _paid = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembayaran simulasi berhasil')),
    );
  }

  int _intOf(Object? value) => (value as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Itinerary (dummy)')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final source = _source;
    if (_error != null || source == null) {
      return Center(child: Text(_error ?? 'Itinerary tidak tersedia'));
    }

    final theme = Theme.of(context);
    final days = [...source.days]
      ..sort(
        (a, b) =>
            _intOf(a.data['dayNumber']).compareTo(_intOf(b.data['dayNumber'])),
      );
    final isPaidItinerary = source.price > 0;
    final stopCount = days.fold<int>(0, (sum, d) => sum + d.stops.length);
    final title = (source.data['title'] as String?) ?? '';
    final destination = (source.data['destination'] as String?) ?? '';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              Text('oleh ${source.data['creatorName'] ?? '-'}'),
              const SizedBox(height: 8),
              Text((source.data['description'] as String?) ?? ''),
              const SizedBox(height: 4),
              Text(
                '${days.length} hari · $stopCount stop · '
                '${isPaidItinerary ? formatRupiah(source.price) : 'Gratis'}',
              ),
              const SizedBox(height: 16),
              for (final day in days) ...[
                Text(
                  'Hari ${_intOf(day.data['dayNumber'])}',
                  style: theme.textTheme.titleSmall,
                ),
                for (final stop
                    in ([...day.stops]..sort(
                      (a, b) => _intOf(
                        a.data['order'],
                      ).compareTo(_intOf(b.data['order'])),
                    )))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${stop.data['placeName'] ?? ''}'),
                    subtitle: Text(
                      formatTimeId(stop.data['startTime'] as String?),
                    ),
                  ),
                const Divider(),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPaidItinerary && !_paid)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () => _pay(source),
                      child: Text(
                        'Bayar ${formatRupiah(source.price)} (simulasi)',
                      ),
                    ),
                  ),
                if (isPaidItinerary && _paid)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Chip(label: Text('Sudah dibeli')),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    // Itinerary berbayar: aktif setelah pembelian berhasil.
                    onPressed: (isPaidItinerary && !_paid)
                        ? null
                        : () => AdoptBottomSheet.show(
                            context,
                            itineraryId: source.id,
                            title: title,
                            summary: [
                              if (destination.isNotEmpty) destination,
                              '${days.length} hari',
                              '$stopCount tempat',
                            ].join(' · '),
                            price: source.price,
                            sourceDays: days.length,
                            stopCount: stopCount,
                            creatorName: source.data['creatorName'] as String?,
                            creatorUsername:
                                source.data['creatorUsername'] as String?,
                          ),
                    child: const Text('Adopt ke Trip Saya'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}