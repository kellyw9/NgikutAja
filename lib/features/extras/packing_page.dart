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
    input.dispose();
    super.dispose();
  }

  void _add() {
    final v = input.text.trim();
    if (v.isEmpty) return;
    final t = widget.trip;
    var g = t.packing.where((g) => g.name == 'Lainnya').firstOrNull;
    if (g == null) {
      g = PackGroup('Lainnya', []);
      t.packing.add(g);
    }
    g.items.add(PackItem(v));
    input.clear();
    AppScope.read(context).touch();
  }

  Future<void> _edit(PackGroup g, PackItem it) async {
    final c = TextEditingController(text: it.name);
    final r = await showNgSheet<String>(
      context,
      title: 'Ubah barang',
      builder: (ctx) => Gap(
        16,
        children: [
          NgField(label: 'Nama barang', controller: c, autofocus: true),
          NgButton('Simpan', expand: true, onPressed: () => Navigator.pop(ctx, c.text.trim())),
          NgButton('Hapus barang', kind: BtnKind.dangerText, icon: 'delete', expand: true, onPressed: () => Navigator.pop(ctx, '')),
        ],
      ),
    );
    c.dispose();
    if (r == null || !mounted) return;
    if (r.isEmpty) {
      _remove(g, it);
    } else {
      it.name = r;
      AppScope.read(context).touch();
    }
  }
