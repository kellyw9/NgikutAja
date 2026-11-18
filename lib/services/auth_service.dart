import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Instance Firebase Authentication untuk proses login/logout
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance Google Sign-In untuk autentikasi akun Google
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Fungsi login menggunakan akun Google
  Future<User?> loginWithGoogle() async {
    try {
      // Menyiapkan Google Sign-In sebelum digunakan
      await _googleSignIn.initialize();

      // Membuka proses login/pemilihan akun Google
      final googleAccount = await _googleSignIn.authenticate();

      // Mengambil data autentikasi dari akun Google
      final googleAuth = await googleAccount.authentication;

      // Membuat credential Firebase dari token Google
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Login ke Firebase menggunakan credential Google
      final userCredential = await _auth.signInWithCredential(credential);

      // Mengembalikan data user jika login berhasil
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Menangani error yang berasal dari Firebase Authentication
      print('Firebase Auth Error: ${e.message}');
      return null;
    } catch (e) {
      // Menangani error lain atau login yang dibatalkan
      print('Login dibatalkan atau terjadi kesalahan: $e');
      return null;
    }
  }

  // Fungsi untuk logout dari Google dan Firebase
  Future<void> logout() async {
    await _googleSignIn.disconnect();
    await _auth.signOut();
  }
}