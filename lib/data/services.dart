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
