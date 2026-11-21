/// Pemeriksa status pembayaran (modul Anggota 6).
///
/// TODO(PAYMENT): implementasi asli harus membaca status dari data backend
/// (misalnya dokumen pembelian di Firestore), bukan dari state aplikasi.
/// Spec modul §4.3-B: status pembayaran harus diverifikasi dari backend.
abstract class PaymentChecker {
  /// True jika [userId] sudah membayar dengan status berhasil.
  Future<bool> hasPaid({required String userId, required String itineraryId});
}
