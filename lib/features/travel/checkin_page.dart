import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 6.4 Check-in. Lokasi masih simulasi (belum memakai GPS): aktivitas berikutnya dianggap
/// dalam radius 100 m, aktivitas lain dianggap masih jauh. Teks banner menyebut "simulasi".
class CheckinPage extends StatefulWidget {
  const CheckinPage({super.key, required this.trip, required this.day, required this.i});
  final Trip trip;
  final int day;
  final int i;

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> {
  bool done = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = widget.trip;
    final st = t.plan[widget.day][widget.i];
    final near = app.nextIndex(t, widget.day) == widget.i;
    final stops = t.plan[widget.day];
    final nextAfter = app.nextIndex(t, widget.day);
    final history = [
      for (var k = 0; k < stops.length; k++)
        if (t.isChecked(widget.day, k)) k,
    ];

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(title: 'Check-in', sub: st.name),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
        children: [
          Gap(
            14,
            children: [
              MapView(
                height: 210,
                kind: MapKind.lake,
                ring: const (Offset(.495, .5), 56),
                pins: [MapPin(.495, .5, n: widget.i + 1, state: done ? MarkerState.done : MarkerState.next)],
                me: near || done ? const Offset(.57, .64) : const Offset(.8, .78),
              ),
              if (done)
                NgBanner(
                  kind: BannerKind.success,
                  icon: 'task_alt',
                  title: 'Check-in berhasil pukul ${t.checkins['${widget.day}-${widget.i}']}',
                  text: nextAfter == null
                      ? '${st.name} tercatat. Semua aktivitas hari ini sudah selesai.'
                      : '${st.name} tercatat. Berikutnya ${stops[nextAfter].name} pukul ${stops[nextAfter].start}.',
                )
              else if (near)
                NgBanner(
                  kind: BannerKind.success,
                  title: 'Kamu sudah di lokasi',
                  text: 'Posisimu (simulasi) 40 m dari titik ${st.name}. Batas check-in 100 m.',
                )
              else
                const NgBanner(
                  kind: BannerKind.warning,
                  title: 'Masih jauh dari lokasi',
                  text:
                      'Posisimu (simulasi) 1,2 km dari titik tempat. Check-in terbuka saat kamu berada dalam 100 m. Selesaikan aktivitas sebelumnya dulu.',
                ),
              if (done)
