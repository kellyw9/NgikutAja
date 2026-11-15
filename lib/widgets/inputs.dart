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
    this.maxLength,
    this.autofillHints,
    this.focusNode,
    this.fill,
  });

  final String? label;
  final TextEditingController? controller;
  final String? value;
  final String hint;
  final String? icon;
  final Object? trailing; // String (nama ikon) atau Widget
  final String? helper;
  final String? error;
  final bool area;
  final bool readOnly;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final Color? fill;

  @override
  State<NgField> createState() => _NgFieldState();
}

class _NgFieldState extends State<NgField> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  bool get _select => widget.onTap != null && widget.controller == null;

  @override
  Widget build(BuildContext context) {
    final err = widget.error != null;
    final borderColor = err ? AppColors.negative : (_focused ? AppColors.ink : AppColors.control);
    final borderW = err || _focused ? 2.0 : 1.0;

    Widget content;
    if (_select || widget.controller == null) {
      final v = widget.value ?? '';
      content = Text(
        v.isEmpty ? widget.hint : v,
        style: AppText.body.c(v.isEmpty ? AppColors.muted : AppColors.ink),
        maxLines: widget.area ? 4 : 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      content = TextField(
        controller: widget.controller,
        focusNode: _focus,
        readOnly: widget.readOnly,
        obscureText: widget.obscure,
        obscuringCharacter: '•',
        keyboardType: widget.area ? TextInputType.multiline : widget.keyboardType,
