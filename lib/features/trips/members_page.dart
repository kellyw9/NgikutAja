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
