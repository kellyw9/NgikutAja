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
            Row(
              children: [
                Avatar(m.name, size: 52, tint: m.tint),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: AppText.h2),
                      const SizedBox(height: 2),
                      Text('${m.handle}${m.joined != null ? ', bergabung ${m.joined}' : ''}', style: AppText.small.muted),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hak akses', style: AppText.bodyStrong),
                const SizedBox(height: 6),
                RadioRow(title: 'Lihat', selected: m.role == MemberRole.viewer, onTap: () => set(() => app.setRole(m, MemberRole.viewer))),
                RadioRow(title: 'Edit', selected: m.role == MemberRole.editor, onTap: () => set(() => app.setRole(m, MemberRole.editor))),
              ],
            ),
            NgButton(
              'Hapus dari trip',
              kind: BtnKind.dangerText,
              icon: 'person_remove',
              expand: true,
              onPressed: () {
                Navigator.pop(ctx);
                _remove(context, m);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _invite(BuildContext context) {
    final app = AppScope.read(context);
    final input = TextEditingController();
    var role = MemberRole.editor;
    String? err;
    showNgSheet<void>(
      context,
      title: 'Undang anggota',
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Gap(
          16,
          children: [
