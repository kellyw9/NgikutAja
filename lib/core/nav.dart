import 'package:flutter/material.dart';

Future<T?> push<T>(BuildContext context, Widget page, {bool fullscreen = false}) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page, fullscreenDialog: fullscreen));

Future<T?> replace<T>(BuildContext context, Widget page) =>
    Navigator.of(context).pushReplacement<T, Object?>(MaterialPageRoute(builder: (_) => page));

/// Ganti seluruh tumpukan halaman (setelah login, logout, onboarding).
void resetTo(BuildContext context, Widget page) => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => page), (_) => false);
