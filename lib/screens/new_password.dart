import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/text.dart';
import '../widgets/app_buttons.dart';
import '../widgets/text_field.dart';
import '../widgets/auth_part.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key, this.email = 'dinda.saragi@gmail.com'});

  /// Email akun yang sedang direset (isi dari layar sebelumnya / deep link).
  final String email;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _validFormat =>
      _password.text.length >= 8 &&
      RegExp(r'[A-Za-z]').hasMatch(_password.text) &&
      RegExp(r'\d').hasMatch(_password.text);

  bool get _mismatch => _confirm.text.isNotEmpty && _confirm.text != _password.text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kMargin, 8, kMargin, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthBackButton(icon: 'close'),
              const SizedBox(height: 4),
              AuthHeader(
                title: 'Buat password baru',
                subtitle: 'Untuk akun ${widget.email}',
              ),
              AppTextField(
                label: 'Password baru',
                icon: 'lock',
                controller: _password,
                isPassword: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              Text('Minimal 8 karakter, campur huruf dan angka.', style: AppText.small.muted),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Konfirmasi password baru',
                icon: 'lock',
                controller: _confirm,
                isPassword: true,
                errorText: _mismatch ? 'Password belum sama' : null,
                onChanged: (_) => setState(() {}),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Simpan password',
                onPressed: (_validFormat && _confirm.text == _password.text)
                    ? () {
                        // TODO: kirim password baru ke backend.
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}