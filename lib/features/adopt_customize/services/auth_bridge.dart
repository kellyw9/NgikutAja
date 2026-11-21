/// Jembatan ke sistem autentikasi (modul Anggota 1).
///
/// Modul Adopt & Customize TIDAK boleh memanggil Firebase Auth langsung.
/// Semua kebutuhan UID dan status login lewat interface ini.
///
/// TODO(AUTH): setelah Anggota 1 selesai:
/// 1. Buat class baru, misalnya `RealAuthBridge implements AuthBridge`,
///    yang membaca UID dari layanan autentikasi Anggota 1.
/// 2. Ganti `DummyAuthBridge` dengan class itu saat membuat Provider
///    (cari komentar TODO(AUTH) di file yang membuat provider).
/// 3. Pastikan `isLoggedIn` ikut berubah saat pengguna logout.
abstract class AuthBridge {
  /// True jika pengguna sedang login.
  bool get isLoggedIn;

  /// UID pengguna yang sedang login, null jika belum login.
  String? get currentUserId;
}
