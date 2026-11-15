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
