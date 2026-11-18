import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/icons.dart';
import '../core/text.dart';

/// Field dengan label di atas. [icon] adalah nama ikon untuk [AppIcon]
/// (mis. 'mail', 'lock', 'person').
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.hint,
    this.isPassword = false,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final String icon;
  final TextEditingController? controller;
  final String? hint;
  final bool isPassword;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: c, width: w),
      );

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppText.smallStrong),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword && _obscure,
          style: AppText.body,
          cursorColor: AppColors.ink,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.surface,
            hintText: widget.hint,
            hintStyle: AppText.body.c(AppColors.control),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: AppIcon(widget.icon, size: 20, color: AppColors.control),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: widget.isPassword
                ? IconButton(
                    tooltip: _obscure ? 'Tampilkan password' : 'Sembunyikan password',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: AppIcon(
                      _obscure ? 'visibility' : 'visibility_off',
                      size: 20,
                      color: AppColors.muted,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            enabledBorder: _border(hasError ? AppColors.negative : AppColors.control),
            focusedBorder: _border(hasError ? AppColors.negative : AppColors.ink, 2),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: AppIcon('error', size: 14, color: AppColors.negative),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(widget.errorText!, style: AppText.small.c(AppColors.negative)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}