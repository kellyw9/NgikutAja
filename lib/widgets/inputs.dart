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
        maxLines: widget.area ? null : 1,
        minLines: widget.area ? 3 : 1,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        inputFormatters: [...?widget.inputFormatters, if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength)],
        textInputAction: widget.textInputAction,
        autofocus: widget.autofocus,
        autofillHints: widget.autofillHints,
        style: AppText.body,
        cursorColor: AppColors.ink,
        decoration: InputDecoration.collapsed(hintText: widget.hint, hintStyle: AppText.body.muted),
      );
    }
    // Awalan (misalnya "Rp") selalu terlihat, tidak hanya saat field difokus.
    if (widget.prefixText != null) {
      content = Row(
        children: [
          Text(widget.prefixText!, style: AppText.body.muted),
          const SizedBox(width: 4),
          Expanded(child: content),
        ],
      );
    }

    final trailing = widget.trailing;
    final box = Container(
      constraints: BoxConstraints(minHeight: widget.area ? 100 : 48),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: widget.area ? 12 : 0),
      decoration: BoxDecoration(
        color: widget.fill ?? (widget.readOnly && !_select ? AppColors.surfaceSoft : AppColors.surface),
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: borderColor, width: borderW),
      ),
      child: Row(
        crossAxisAlignment: widget.area ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[AppIcon(widget.icon!, size: 20, color: AppColors.muted), const SizedBox(width: 10)],
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: widget.area ? 0 : 14),
              child: content,
            ),
          ),
          if (trailing is String) ...[const SizedBox(width: 10), AppIcon(trailing, size: 20, color: AppColors.muted)],
          if (trailing is Widget) ...[const SizedBox(width: 6), trailing],
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[Text(widget.label!, style: AppText.bodyStrong), const SizedBox(height: 6)],
        if (_select)
          Semantics(
            button: true,
            label: widget.label,
            value: widget.value,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(AppRadius.control),
                focusColor: AppColors.teal.withValues(alpha: .15),
                child: box,
              ),
            ),
          )
        else
          box,
        if (err) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const AppIcon('error', size: 16, color: AppColors.negative),
              const SizedBox(width: 6),
              Expanded(child: Text(widget.error!, style: AppText.small.c(AppColors.negative))),
            ],
          ),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: 6),
          Text(widget.helper!, style: AppText.small.muted),
        ],
      ],
    );
  }
}

/// Tombol mata untuk menampilkan/menyembunyikan password.
class ObscureToggle extends StatelessWidget {
  const ObscureToggle({super.key, required this.obscured, required this.onTap});
  final bool obscured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconBtn(
    obscured ? 'visibility' : 'visibility_off',
    label: obscured ? 'Tampilkan password' : 'Sembunyikan password',
    onTap: onTap,
    size: 40,
    iconSize: 20,
    color: AppColors.muted,
  );
}

/// Toggle 52x32: aktif = isi tinta + bulatan putih 24; nonaktif = sunk bergaris + bulatan 16.
class NgToggle extends StatelessWidget {
  const NgToggle(this.value, {super.key, required this.onChanged, this.label});
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      button: true,
      child: SizedBox(
        width: 56,
        height: 44,
        child: Center(
          child: Material(
            color: value ? AppColors.ink : AppColors.sunk,
            shape: StadiumBorder(side: value ? BorderSide.none : const BorderSide(color: AppColors.control, width: 1.5)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onChanged == null ? null : () => onChanged!(!value),
              focusColor: AppColors.teal.withValues(alpha: .35),
              child: SizedBox(
                width: 52,
                height: 32,
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 160),
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: value ? 4 : 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: value ? 24 : 16,
                      height: value ? 24 : 16,
                      decoration: BoxDecoration(color: value ? AppColors.white : AppColors.control, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RadioMark extends StatelessWidget {
  const RadioMark(this.on, {super.key});
  final bool on;
  @override
  Widget build(BuildContext context) =>
      AppIcon(on ? 'radio_button_checked' : 'radio_button_unchecked', color: on ? AppColors.ink : AppColors.muted, filled: on);
}

class CheckMark extends StatelessWidget {
  const CheckMark(this.on, {super.key});
  final bool on;
  @override
  Widget build(BuildContext context) =>
      AppIcon(on ? 'check_box' : 'check_box_outline_blank', color: on ? AppColors.ink : AppColors.muted, filled: on);
}

/// Baris pilihan (radio) yang bisa diketuk seluruhnya.
class RadioRow extends StatelessWidget {
  const RadioRow({super.key, required this.title, this.sub, required this.selected, required this.onTap, this.enabled = true, this.height = 48});
  final String title;
  final String? sub;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    inMutuallyExclusiveGroup: true,
    checked: selected,
    enabled: enabled,
    child: Opacity(
      opacity: enabled ? 1 : .6,
      child: Tap(
        onTap: enabled ? onTap : null,
        radius: 6,
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: selected || sub != null ? AppText.bodyStrong : AppText.body),
                    if (sub != null) ...[const SizedBox(height: 2), Text(sub!, style: AppText.small.muted)],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              RadioMark(selected),
