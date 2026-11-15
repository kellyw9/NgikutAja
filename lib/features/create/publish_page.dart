import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../explore/itinerary_detail_page.dart';
import '../trips/schedule_logic.dart';
import 'create_itinerary_page.dart';

/// Langkah 5: Publish Itinerary.
class PublishPage extends StatefulWidget {
  const PublishPage({super.key, required this.d});
  final Itinerary d;

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  late final d = widget.d;
  late bool paid = d.price > 0;
  late final price = TextEditingController(text: thousands(d.price > 0 ? d.price : 25000));

  @override
  void dispose() {
    price.dispose();
    super.dispose();
  }

  void _apply() => d.price = paid ? parseRupiah(price.text) : 0;
