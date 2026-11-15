import 'package:flutter/material.dart';
import 'package:path_parsing/path_parsing.dart';

import '../../widgets/ui.dart';
import '../shell/home_shell.dart';
import 'register_page.dart';
import 'reset_password_page.dart';

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String v) {
  if (v.trim().isEmpty) return 'Isi email dulu';
  if (!_emailRe.hasMatch(v.trim())) return 'Format email belum benar';
  return null;
}

/// 1.3 Login. [popOnSuccess]: dibuka dari sheet "Masuk dulu", kembali ke halaman sebelumnya setelah masuk.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.popOnSuccess = false});
  final bool popOnSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool obscure = true;
  bool loading = false;
  bool wrong = false;
  String? emailErr;
  String? passErr;

  Future<void> _submit() async {
    setState(() {
      emailErr = validateEmail(email.text);
      passErr = pass.text.isEmpty ? 'Isi password dulu' : null;
      wrong = false;
    });
    if (emailErr != null || passErr != null) return;
    setState(() => loading = true);
    final ok = await AppScope.read(context).login(email.text, pass.text);
    if (!mounted) return;
    setState(() {
      loading = false;
      wrong = !ok;
      passErr = ok ? null : 'Password tidak cocok dengan email ini';
    });
    if (ok) {
      FocusScope.of(context).unfocus();
      if (widget.popOnSuccess) {
        Navigator.pop(context);
        showNgSnack(context, 'Kamu sudah masuk sebagai ${AppScope.read(context).me.name}.', kind: SnackKind.success);
      } else {
        resetTo(context, const HomeShell());
      }
    }
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: kDarkIcons,
      child: Scaffold(
        backgroundColor: AppColors.ground,
        appBar: widget.popOnSuccess ? const NgAppBar(back: 'close') : null,
        body: SafeArea(
          top: !widget.popOnSuccess,
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(kMargin, 24, kMargin, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight - 48),
                child: IntrinsicHeight(
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(alignment: Alignment.centerLeft, child: Wordmark(large: false)),
                        const SizedBox(height: 24),
                        Text('Masuk ke akunmu', style: AppText.h1),
                        const SizedBox(height: 8),
                        Text('Lanjutkan trip yang sudah kamu adopsi.', style: AppText.body.muted),
                        if (wrong) ...[
                          const SizedBox(height: 24),
                          const NgBanner(
                            kind: BannerKind.error,
                            title: 'Email atau password salah',
                            text: 'Periksa lagi, atau atur ulang password lewat Lupa password.',
                          ),
                        ],
                        const SizedBox(height: 24),
                        NgField(
                          label: 'Email',
                          icon: 'mail',
                          controller: email,
                          hint: 'nama@email.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          error: emailErr,
                        ),
                        const SizedBox(height: 16),
                        NgField(
                          label: 'Password',
                          icon: 'lock',
                          controller: pass,
                          obscure: obscure,
                          hint: 'Minimal 8 karakter',
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onSubmitted: (_) => _submit(),
                          trailing: ObscureToggle(obscured: obscure, onTap: () => setState(() => obscure = !obscure)),
                          error: passErr,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextLink(
                            'Lupa password?',
                            color: AppColors.ink,
                            onTap: () => push(context, ResetPasswordPage(email: email.text)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        NgButton('Masuk', expand: true, loading: loading, onPressed: _submit),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Container(height: 1, color: AppColors.line)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('atau', style: AppText.small.muted),
                            ),
                            Expanded(child: Container(height: 1, color: AppColors.line)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        GoogleButton(
                          label: 'Masuk dengan Google',
                          onTap: () => showNgSnack(context, 'Masuk dengan Google belum tersedia. Pakai email dan password dulu.'),
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text('Belum punya akun? ', style: AppText.body.muted),
                              TextLink(
                                'Daftar',
                                color: AppColors.ink,
                                onTap: () => widget.popOnSuccess
                                    ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterPage(popOnSuccess: true)))
                                    : push(context, const RegisterPage()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        side: const BorderSide(color: AppColors.control),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        focusColor: AppColors.teal.withValues(alpha: .2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox.square(dimension: 20, child: CustomPaint(painter: _GooglePainter())),
            const SizedBox(width: 10),
            Text(label, style: AppText.button),
          ],
        ),
      ),
    ),
  );
}

class _GooglePainter extends CustomPainter {
