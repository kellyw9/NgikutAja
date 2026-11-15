import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import '../core/icons.dart';
import '../core/text.dart';
import 'basics.dart';

/// Input formulir: label di atas, kotak 48 (area 100), radius 8.
/// Fokus = garis tinta 2px, error = garis merah 2px + pesan di bawah.
/// Dengan [onTap] dan tanpa [controller], field berperilaku seperti pilihan (membuka sheet).
class NgField extends StatefulWidget {
  const NgField({
    super.key,
    this.label,
    this.controller,
    this.value,
    this.hint = '',
    this.icon,
    this.trailing,
    this.helper,
    this.error,
    this.area = false,
    this.readOnly = false,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.inputFormatters,
    this.prefixText,
    this.textInputAction,
    this.autofocus = false,
