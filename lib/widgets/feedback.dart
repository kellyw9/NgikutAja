import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/icons.dart';
import '../core/text.dart';
import 'basics.dart';

enum BannerKind { warning, error, info, offline, success }

class NgBanner extends StatelessWidget {
  const NgBanner({super.key, this.kind = BannerKind.warning, this.title, this.text, this.action, this.onAction, this.icon});
  final BannerKind kind;
  final String? title;
  final String? text;
  final String? action;
  final VoidCallback? onAction;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, ic) = switch (kind) {
      BannerKind.warning => (AppColors.yellowPale, AppColors.ink, 'warning'),
