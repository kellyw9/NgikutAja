/// Format angka gaya Indonesia: Rp25.000, 1.240, 4,8.
String thousands(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
