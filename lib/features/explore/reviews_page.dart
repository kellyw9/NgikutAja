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

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final it = widget.it;
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(title: 'Ulasan dan komentar', sub: it.title, rule: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(kMargin, 12, kMargin, 0),
            child: Segmented(items: const ['Review', 'Komentar'], active: tab, onChanged: (t) => setState(() => tab = t)),
          ),
          Expanded(child: tab == 'Review' ? _reviews(app, it) : _comments(app, it)),
        ],
      ),
      bottomNavigationBar: tab == 'Komentar' ? _composer(app) : null,
    );
  }

  Widget _reviews(AppState app, Itinerary it) {
    final list = app.reviewsOf(it);
    final dist = app.ratingDistOf(it);
    final maxN = dist?.values.fold<int>(0, (a, b) => a > b ? a : b) ?? 1;
    return ListView(
      padding: const EdgeInsets.fromLTRB(kMargin, 16, kMargin, 24),
      children: [
        if (it.rating == null)
          const EmptyState(
            icon: 'rate_review',
            title: 'Belum ada ulasan',
            text: 'Ulasan muncul setelah pengguna menyelesaikan trip dari itinerary ini.',
          )
        else ...[
          NgCard(
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  child: Column(
                    children: [
                      Text(decimal(it.rating!), style: AppText.display),
                      const SizedBox(height: 4),
                      Stars(it.rating!.round(), size: 14),
                      const SizedBox(height: 4),
                      Text('${it.reviews ?? 0} ulasan', style: AppText.small.muted),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
