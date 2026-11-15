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
