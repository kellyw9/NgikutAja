// Tes asap: setiap halaman dirender di HP kecil (360x740) dan sedang (390x844).
// Gagal kalau ada error layout (misalnya teks meluber) atau exception saat build.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngikutaja/app.dart';
import 'package:ngikutaja/data/app_state.dart';
import 'package:ngikutaja/data/models.dart';
import 'package:ngikutaja/features/auth/login_page.dart';
import 'package:ngikutaja/features/auth/onboarding_page.dart';
import 'package:ngikutaja/features/auth/register_page.dart';
