import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/ui.dart';

/// 5.11 Shared Trip: anggota, undang, detail anggota, cabut akses.
class MembersPage extends StatelessWidget {
  const MembersPage({super.key, required this.trip});
  final Trip trip;

  static PillKind _kind(MemberRole r) => switch (r) {
    MemberRole.owner => PillKind.solid,
    MemberRole.editor => PillKind.teal,
    MemberRole.viewer => PillKind.neutral,
  };

  String _link(Trip t) => 'ngikutaja.app/t/${t.id}';

  Future<void> _remove(BuildContext context, Member m) async {
    final app = AppScope.read(context);
    final r = await showNgDialog(
      context,
      icon: 'person_remove',
      title: 'Hapus ${m.first} dari trip?',
      body: '${m.first} tidak bisa lagi membuka "${trip.title}". Pengeluaran yang dia catat tetap tersimpan.',
      actions: const [
        DialogAction('Hapus akses', kind: BtnKind.danger, value: true),
        DialogAction('Batal'),
      ],
    );
    if (r == true) {
      app.removeMember(trip, m);
      if (context.mounted) showNgSnack(context, 'Akses ${m.first} dicabut.');
    }
  }

  void _detail(BuildContext context, Member m) {
    final app = AppScope.read(context);
    showNgSheet<void>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Gap(
          16,
          children: [
