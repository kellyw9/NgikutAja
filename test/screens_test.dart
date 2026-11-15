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
import 'package:ngikutaja/features/auth/reset_password_page.dart';
import 'package:ngikutaja/features/create/add_stop_page.dart';
import 'package:ngikutaja/features/create/create_itinerary_page.dart';
import 'package:ngikutaja/features/create/day_editor_page.dart';
import 'package:ngikutaja/features/create/publish_page.dart';
import 'package:ngikutaja/features/explore/creator_profile_page.dart';
import 'package:ngikutaja/features/explore/itinerary_detail_page.dart';
import 'package:ngikutaja/features/explore/reviews_page.dart';
import 'package:ngikutaja/features/extras/journal_page.dart';
import 'package:ngikutaja/features/extras/memory_pages.dart';
import 'package:ngikutaja/features/extras/packing_page.dart';
import 'package:ngikutaja/features/extras/recap_page.dart';
