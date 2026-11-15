import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 7.2 Packing List: centang, ubah nama, geser untuk hapus, tambah barang.
class PackingPage extends StatefulWidget {
  const PackingPage({super.key, required this.trip});
  final Trip trip;

  @override
  State<PackingPage> createState() => _PackingPageState();
}

class _PackingPageState extends State<PackingPage> {
  final input = TextEditingController();

  @override
  void dispose() {
