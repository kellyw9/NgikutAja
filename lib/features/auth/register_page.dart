import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../shell/home_shell.dart';
import 'login_page.dart';

/// 1.4 Register.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.popOnSuccess = false});
  final bool popOnSuccess;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();
  bool ob1 = true, ob2 = true, loading = false, tried = false;

  (double, String, Color) get strength {
    final p = pass.text;
    if (p.isEmpty) return (0, 'Minimal 8 karakter', AppColors.sunk);
    if (p.length < 8) return (.33, 'Terlalu pendek, minimal 8 karakter', AppColors.negative);
    final mixed = RegExp(r'[A-Za-z]').hasMatch(p) && RegExp(r'\d').hasMatch(p);
    return mixed && p.length >= 10 ? (1, 'Kuat', AppColors.positive) : (.66, 'Cukup kuat, minimal 8 karakter', AppColors.positive);
  }

  String? get emailErr {
    final e = validateEmail(email.text);
    // Format baru ditegur setelah pengguna pindah ke kolom password, bukan saat masih mengetik.
    if (e != null) return email.text.isNotEmpty && (tried || pass.text.isNotEmpty) ? e : null;
    if (AppScope.read(context).emailRegistered(email.text)) return 'Email ini sudah terdaftar. Masuk saja.';
    return null;
  }

  String? get confirmErr => confirm.text.isNotEmpty && confirm.text != pass.text ? 'Password belum sama' : null;

  bool get valid =>
      name.text.trim().isNotEmpty && validateEmail(email.text) == null && emailErr == null && pass.text.length >= 8 && confirm.text == pass.text;

  Future<void> _submit() async {
    setState(() => tried = true);
    if (!valid) return;
    setState(() => loading = true);
    await AppScope.read(context).register(name.text, email.text, pass.text);
    if (!mounted) return;
    if (widget.popOnSuccess) {
      Navigator.pop(context);
      showNgSnack(context, 'Akun dibuat. Selamat datang, ${name.text.trim()}.', kind: SnackKind.success);
    } else {
      resetTo(context, const HomeShell());
    }
  }

  @override
  void dispose() {
    for (final c in [name, email, pass, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (sv, st, sc) = strength;
    void refresh(_) => setState(() {});
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const NgAppBar(),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 24),
              child: IntrinsicHeight(
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Buat akun baru', style: AppText.h1),
                      const SizedBox(height: 8),
                      Text('Satu akun untuk membuat, mengadopsi, dan menjalankan trip.', style: AppText.body.muted),
                      const SizedBox(height: 20),
                      NgField(
                        label: 'Nama',
                        icon: 'person',
                        controller: name,
                        hint: 'Nama lengkap',
                        onChanged: refresh,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        error: tried && name.text.trim().isEmpty ? 'Isi nama dulu' : null,
                      ),
                      const SizedBox(height: 14),
                      NgField(
                        label: 'Email',
                        icon: 'mail',
                        controller: email,
                        hint: 'nama@email.com',
                        onChanged: refresh,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        error: emailErr,
                      ),
                      const SizedBox(height: 14),
                      NgField(
                        label: 'Password',
                        icon: 'lock',
                        controller: pass,
                        obscure: ob1,
                        onChanged: refresh,
                        hint: 'Minimal 8 karakter',
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        trailing: ObscureToggle(obscured: ob1, onTap: () => setState(() => ob1 = !ob1)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Progress(sv, width: 120, fill: sc),
                          const SizedBox(width: 8),
                          Expanded(child: Text(st, style: AppText.small.muted)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      NgField(
                        label: 'Konfirmasi password',
                        icon: 'lock',
                        controller: confirm,
                        obscure: ob2,
                        onChanged: refresh,
                        hint: 'Ketik ulang password',
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        trailing: ObscureToggle(obscured: ob2, onTap: () => setState(() => ob2 = !ob2)),
                        error: confirmErr,
                      ),
                      const Spacer(),
                      const SizedBox(height: 20),
                      NgButton('Buat akun', expand: true, loading: loading, onPressed: valid ? _submit : null),
                      const SizedBox(height: 12),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('Sudah punya akun? ', style: AppText.body.muted),
                            TextLink(
                              'Masuk',
                              color: AppColors.ink,
                              onTap: () =>
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage(popOnSuccess: widget.popOnSuccess))),
                            ),
                          ],
                        ),
