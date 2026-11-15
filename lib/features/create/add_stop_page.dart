import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../trips/trip_forms.dart';

export '../trips/trip_forms.dart' show StopEditResult;

/// Langkah 3: Tambah Stop.
class AddStopPage extends StatefulWidget {
  const AddStopPage({super.key, this.stop, required this.city, this.defaultStart = '08.00'});
  final Stop? stop;
  final String city;
  final String defaultStart;

  @override
  State<AddStopPage> createState() => _AddStopPageState();
}

class _AddStopPageState extends State<AddStopPage> {
  late final s = widget.stop;
  late final name = TextEditingController(text: s?.name ?? '');
  late final cost = TextEditingController(text: s == null || s!.cost == 0 ? '' : thousands(s!.cost));
  late final note = TextEditingController(text: s?.note ?? '');
