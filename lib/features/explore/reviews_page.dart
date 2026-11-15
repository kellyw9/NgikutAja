import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 2.3 Review & Komentar.
class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key, required this.it, this.comments = false});
  final Itinerary it;
  final bool comments;

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late String tab = widget.comments ? 'Komentar' : 'Review';
  final input = TextEditingController();
  final focus = FocusNode();
  String? replyTo;

  @override
  void dispose() {
    input.dispose();
    focus.dispose();
    super.dispose();
  }

  void _send() {
    if (!requireLogin(context)) return;
    if (input.text.trim().isEmpty) return;
    AppScope.read(context).addComment(widget.it, input.text, replyTo: replyTo);
    input.clear();
    setState(() => replyTo = null);
    focus.unfocus();
  }
