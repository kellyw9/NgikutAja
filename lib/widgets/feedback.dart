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
      BannerKind.error => (AppColors.negativePale, AppColors.negativeInk, 'error'),
      BannerKind.info => (AppColors.tealPale, AppColors.ink, 'info'),
      BannerKind.offline => (AppColors.ink, AppColors.white, 'cloud_off'),
      BannerKind.success => (AppColors.positivePale, AppColors.positiveInk, 'check_circle'),
    };
    final offline = kind == BannerKind.offline;
    return Semantics(
      liveRegion: kind == BannerKind.error,
      container: true,
      child: Container(
        width: double.infinity,
        padding: offline ? const EdgeInsets.symmetric(horizontal: kMargin, vertical: 10) : const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: offline ? null : BorderRadius.circular(AppRadius.card)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcon(icon ?? ic, size: 20, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) Text(title!, style: AppText.bodyStrong.c(fg)),
                  if (title != null && text != null) const SizedBox(height: 2),
                  if (text != null) Text(text!, style: (offline ? AppText.small : AppText.body).c(fg)),
                ],
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 10),
              Semantics(
                button: true,
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(action!, style: AppText.bodyStrong.c(fg)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum SnackKind { neutral, success, error }

void showNgSnack(BuildContext context, String text, {SnackKind kind = SnackKind.neutral, String? action, VoidCallback? onAction}) {
  final (bg, ic) = switch (kind) {
    SnackKind.neutral => (AppColors.ink, null),
    SnackKind.success => (AppColors.positive, 'check_circle'),
    SnackKind.error => (AppColors.negative, 'error'),
  };
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: bg,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(kMargin, 0, kMargin, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      duration: Duration(seconds: action != null ? 6 : 3),
      content: Row(
        children: [
          if (ic != null) ...[AppIcon(ic, size: 20, color: AppColors.white, filled: true), const SizedBox(width: 12)],
          Expanded(child: Text(text, style: AppText.body.white)),
          if (action != null) ...[
            const SizedBox(width: 12),
            Semantics(
              button: true,
              child: InkWell(
                onTap: () {
                  m.hideCurrentSnackBar();
                  onAction?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(action, style: AppText.bodyStrong.c(kind == SnackKind.neutral ? AppColors.yellow : AppColors.white)),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Bottom sheet: pegangan, judul kiri + tombol tutup, isi dengan jarak 16.
Future<T?> showNgSheet<T>(BuildContext context, {String? title, String? sub, required WidgetBuilder builder, bool scroll = false}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    elevation: 0,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
