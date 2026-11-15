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
