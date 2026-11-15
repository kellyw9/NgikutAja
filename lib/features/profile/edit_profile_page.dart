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
    if (u.length < 3) return 'Minimal 3 karakter';
    if (!RegExp(r'^[a-z0-9_.]+$').hasMatch(u)) return 'Pakai huruf kecil, angka, titik, atau garis bawah';
    if (!AppScope.read(context).usernameAvailable(u)) return 'Username sudah dipakai';
    return null;
  }

  void _save() {
    if (name.text.trim().isEmpty || userErr != null) {
      setState(() {});
      return;
    }
    me.photo = photo;
    AppScope.read(context).updateProfile(name: name.text, username: user.text, bio: bio.text);
    Navigator.pop(context);
    showNgSnack(context, 'Profil tersimpan.', kind: SnackKind.success);
  }

  @override
  void dispose() {
    name.dispose();
    user.dispose();
    bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uErr = userErr;
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final r = await showNgDialog(
          context,
          title: 'Buang perubahan?',
          body: 'Perubahan profil yang baru kamu buat belum disimpan.',
          actions: const [
            DialogAction('Lanjut edit', kind: BtnKind.primary, value: false),
            DialogAction('Buang perubahan', kind: BtnKind.dangerText, value: true),
          ],
        );
        if (r == true && context.mounted) {
          name.text = me.name;
          user.text = me.handle.replaceFirst('@', '');
          bio.text = me.bio;
          photo = me.photo;
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.ground,
        appBar: NgAppBar(
          title: 'Edit profil',
