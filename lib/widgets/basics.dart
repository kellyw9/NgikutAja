import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/icons.dart';
import '../core/text.dart';
import '../data/services.dart';

// ---------------------------------------------------------------- tombol

enum BtnKind { primary, secondary, accent, danger, dangerText, text, ghost }

enum BtnSize { lg, md }

/// Tombol NgikutAja: radius 8, tinggi 48 (lg) atau 40 (md).
class NgButton extends StatelessWidget {
  const NgButton(
    this.label, {
    super.key,
    this.onPressed,
    this.kind = BtnKind.primary,
    this.size = BtnSize.lg,
    this.icon,
    this.trailingIcon,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final BtnKind kind;
  final BtnSize size;
  final String? icon;
  final String? trailingIcon;
  final bool expand;
