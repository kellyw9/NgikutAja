import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/format.dart';
import '../core/icons.dart';
import '../core/text.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import 'basics.dart';

enum CardVariant { feed, row, grid }

/// Rating + jumlah adopsi. Rating hanya tampil kalau datanya ada.
