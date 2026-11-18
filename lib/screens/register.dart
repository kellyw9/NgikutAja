import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/nav.dart';
import '../core/text.dart';
import '../widgets/app_buttons.dart';
import '../widgets/text_field.dart';
import '../widgets/auth_part.dart';
import 'home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// 0 = kosong, 1 = lemah, 2 = cukup, 3 = kuat
  int get _strength {
    final p = _password.text;
    if (p.isEmpty) return 0;
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Za-z]').hasMatch(p) && RegExp(r'\d').hasMatch(p)) s++;
    if (p.length >= 12 || RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s == 0 ? 1 : s;
  }

  bool get _mismatch => _confirm.text.isNotEmpty && _confirm.text != _password.text;

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _email.text.contains('@') &&
      _password.text.length >= 8 &&
      _confirm.text == _password.text;

  static const _strengthLabels = ['', 'Lemah, minimal 8 karakter', 'Cukup kuat, minimal 8 karakter', 'Kuat'];

  @override
  Widget build(BuildContext context) {
    final barColor = _strength == 1 ? AppColors.negative : AppColors.positive;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthBackButton(),
              const SizedBox(height: 4),
              const AuthHeader(
                title: 'Buat akun baru',
                subtitle: 'Siapkan akun untuk membuat, mengadopsi, dan menjalankan trip.',
              ),
              AppTextField(
                label: 'Nama',
                icon: 'person',
                controller: _name,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Email',
                icon: 'mail',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Password',
                icon: 'lock',
                controller: _password,
                isPassword: true,
                onChanged: (_) => setState(() {}),
              ),
              if (_password.text.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: List.generate(3, (i) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(right: i == 2 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: i < _strength ? barColor : AppColors.rule,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(_strengthLabels[_strength], style: AppText.small.muted),
              ],
              const SizedBox(height: 14),
              AppTextField(
                label: 'Konfirmasi password',
                icon: 'lock',
                controller: _confirm,
                isPassword: true,
                errorText: _mismatch ? 'Password belum sama' : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Buat akun',
                onPressed: _valid ? () => resetTo(context, const HomeScreen()) : null,
              ),
              const SizedBox(height: 14),
              BottomLink(
                text: 'Sudah punya akun?',
                action: 'Masuk',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}