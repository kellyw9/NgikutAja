import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/nav.dart';
import '../core/text.dart';
import '../services/auth_service.dart'; // ← baru
import '../widgets/app_buttons.dart';
import '../widgets/text_field.dart';
import '../widgets/auth_part.dart';
import '../widgets/status_banner.dart';
import '../widgets/wordmark.dart';
import 'forgot_password.dart';
import 'home.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _failed = false;

  // ← baru: objek AuthService untuk login Google
  final _authService = AuthService();

  // ← baru: true selama proses login Google berlangsung
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    // TODO: ganti dengan panggilan API/Firebase sungguhan.
    final ok = _email.text.isNotEmpty && _password.text == 'password123';
    if (ok) {
      resetTo(context, const HomeScreen());
    } else {
      setState(() => _failed = true);
    }
  }

  // ← baru: dijalankan ketika tombol "Masuk dengan Google" ditekan
  Future<void> _handleGoogleLogin() async {
    // Mengaktifkan status loading dan memperbarui UI
    setState(() => _isGoogleLoading = true);

    // Menjalankan proses login Google melalui AuthService
    final user = await _authService.loginWithGoogle();

    // Memastikan halaman masih aktif sebelum mengubah state
    if (!mounted) return;

    // Proses login selesai, loading dimatikan
    setState(() => _isGoogleLoading = false);

    // Jika user tidak null, berarti login berhasil
    if (user != null) {
      resetTo(context, const HomeScreen());
    } else {
      // Menampilkan pesan jika login gagal atau dibatalkan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal atau dibatalkan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(kMargin, 24, kMargin, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wordmark(size: 22),
              const SizedBox(height: 20),
              const AuthHeader(
                title: 'Masuk ke akunmu',
                subtitle: 'Lanjutkan trip yang sudah kamu adopsi.',
              ),
              if (_failed) ...[
                const StatusBanner(
                  title: 'Email atau password salah',
                  message: 'Periksa lagi, atau ubah ulang password lewat Lupa password.',
                ),
                const SizedBox(height: 14),
              ],
              AppTextField(
                label: 'Email',
                icon: 'mail',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                hint: 'nama@email.com',
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Password',
                icon: 'lock',
                controller: _password,
                isPassword: true,
                errorText: _failed ? 'Password tidak cocok dengan email ini' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => push(context, const ForgotPasswordScreen()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryStrong,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Lupa password?', style: AppText.smallStrong.c(AppColors.primaryStrong)),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(label: 'Masuk', onPressed: _submit),
              const OrDivider(),
              // ← diubah: tombol dinonaktifkan selama loading
              GoogleButton(
                onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
              ),
              const SizedBox(height: 40),
              BottomLink(
                text: 'Belum punya akun?',
                action: 'Daftar',
                onTap: () => push(context, const RegisterScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}