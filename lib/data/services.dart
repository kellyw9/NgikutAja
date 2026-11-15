import 'dart:async';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Foto yang diambil pengguna disimpan di memori selama aplikasi berjalan
/// dan dirujuk dengan kunci `mem:<id>` (foto bawaan memakai nama aset, misalnya "holbung").
class PhotoStore {
  PhotoStore._();
  static final Map<String, Uint8List> _mem = {};
  static int _n = 0;

  static String put(Uint8List bytes) {
    final key = 'mem:${_n++}';
    _mem[key] = bytes;
    return key;
  }

  static Uint8List? get(String key) => _mem[key];
}

enum PhotoSource { camera, gallery }

/// Buka kamera atau galeri. Mengembalikan kunci foto, atau null kalau dibatalkan.
Future<String?> pickPhoto(PhotoSource source) async {
  final x = await ImagePicker().pickImage(
    source: source == PhotoSource.camera ? ImageSource.camera : ImageSource.gallery,
    maxWidth: 1600,
    imageQuality: 85,
  );
  if (x == null) return null;
  return PhotoStore.put(await x.readAsBytes());
}

Future<void> shareText(String text, {String? subject}) async {
  await SharePlus.instance.share(ShareParams(text: text, subject: subject));
}

/// Buka Google Maps (aplikasi atau browser) untuk mencari tempat atau rute.
Future<bool> openMaps(String query, {bool directions = false}) {
  final q = Uri.encodeComponent(query);
  final url = directions ? 'https://www.google.com/maps/dir/?api=1&destination=$q' : 'https://www.google.com/maps/search/?api=1&query=$q';
  return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

/// Status koneksi perangkat. Dipakai untuk banner offline dan simpan ke server.
class Network {
