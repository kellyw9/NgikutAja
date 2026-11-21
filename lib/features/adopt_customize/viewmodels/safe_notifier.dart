import 'package:flutter/foundation.dart';

/// Mixin untuk ChangeNotifier: abaikan notifyListeners setelah dispose.
mixin SafeNotifier on ChangeNotifier {
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }
}
