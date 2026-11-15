import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 9.2 Edit Profil (+ dialog perubahan belum disimpan).
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final me = AppScope.read(context).me;
  late final name = TextEditingController(text: me.name);
  late final user = TextEditingController(text: me.handle.replaceFirst('@', ''));
  late final bio = TextEditingController(text: me.bio);
  late String? photo = me.photo;

  bool get dirty => name.text.trim() != me.name || '@${user.text.trim()}' != me.handle || bio.text.trim() != me.bio || photo != me.photo;

  String? get userErr {
    final u = user.text.trim();
