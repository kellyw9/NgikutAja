import 'package:flutter/material.dart';

Future<T?> push<T>(BuildContext context, Widget page, {bool fullscreen = false}) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page, fullscreenDialog: fullscreen));

Future<T?> replace<T>(BuildContext context, Widget page) =>
