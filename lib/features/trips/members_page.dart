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
            NgField(label: 'Username atau email', icon: 'person_add', controller: input, hint: '@username', error: err, autofocus: true),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hak akses', style: AppText.bodyStrong),
                const SizedBox(height: 6),
                RadioRow(
                  title: 'Lihat',
                  sub: 'Bisa membuka jadwal dan catatan',
                  selected: role == MemberRole.viewer,
                  onTap: () => set(() => role = MemberRole.viewer),
                ),
                RadioRow(
                  title: 'Edit',
                  sub: 'Bisa mengubah jadwal dan pengeluaran',
                  selected: role == MemberRole.editor,
                  onTap: () => set(() => role = MemberRole.editor),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 2, 2, 2),
              decoration: BoxDecoration(color: AppColors.ground, borderRadius: BorderRadius.circular(AppRadius.inner)),
              child: Row(
                children: [
                  const AppIcon('link', size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_link(trip), style: AppText.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  NgButton(
                    'Salin link',
                    kind: BtnKind.text,
                    size: BtnSize.md,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: 'https://${_link(trip)}'));
                      if (ctx.mounted) showNgSnack(ctx, 'Link undangan disalin.');
                    },
                  ),
                ],
              ),
            ),
            NgButton(
              'Kirim undangan',
              expand: true,
              onPressed: () {
                final v = input.text.trim();
                if (v.length < 3) {
                  set(() => err = 'Isi username atau email anggota');
                  return;
                }
                if (trip.members.any((m) => m.handle.toLowerCase() == (v.startsWith('@') ? v : '@$v').toLowerCase())) {
                  set(() => err = 'Orang ini sudah ada di trip');
                  return;
                }
                app.inviteMember(trip, v.contains('@') && !v.startsWith('@') ? '@${v.split('@').first}' : v, role);
                Navigator.pop(ctx);
                showNgSnack(context, 'Undangan terkirim ke $v.', kind: SnackKind.success);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final ownerIsMe = trip.members.isNotEmpty && trip.members.first.handle == app.me.handle;
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(title: 'Anggota trip', sub: trip.title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 16),
        children: [
          BoxList(
            inset: 56,
            children: [
              for (var i = 0; i < trip.members.length; i++)
                Tap(
                  onTap: i == 0 || !ownerIsMe ? null : () => _detail(context, trip.members[i]),
                  child: SizedBox(
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 12),
                      child: Row(
                        children: [
                          Avatar(trip.members[i].name, size: 36, tint: trip.members[i].tint),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  i == 0 && ownerIsMe ? '${trip.members[i].name} (kamu)' : trip.members[i].name,
                                  style: AppText.bodyStrong,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(trip.members[i].handle, style: AppText.small.muted),
                              ],
                            ),
                          ),
                          Pill(trip.members[i].role.label, kind: _kind(trip.members[i].role)),
                          const SizedBox(width: 8),
                          i > 0 && ownerIsMe ? const AppIcon('chevron_right', size: 20, color: AppColors.muted) : const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Anggota "Bisa edit" boleh mengubah jadwal dan menambah pengeluaran. "Hanya lihat" hanya bisa melihat trip.',
            style: AppText.small.muted,
          ),
        ],
      ),
      bottomNavigationBar: ownerIsMe
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 16),
                child: NgButton('Undang anggota', icon: 'person_add', expand: true, onPressed: () => _invite(context)),
              ),
            )
          : null,
