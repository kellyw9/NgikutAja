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
                Expanded(
                  child: dist == null
                      ? Text('Rincian bintang belum tersedia untuk itinerary ini.', style: AppText.small.muted)
                      : Column(
                          children: [
                            for (final e in dist.entries) ...[
                              Row(
                                children: [
                                  SizedBox(width: 10, child: Text('${e.key}', style: AppText.small.muted)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Progress(maxN == 0 ? 0 : e.value / maxN)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 18,
                                    child: Text('${e.value}', style: AppText.small.muted, textAlign: TextAlign.right),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            Text('Belum ada ulasan tertulis.', style: AppText.body.muted)
          else
            for (final r in list) ...[
              NgCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Avatar(r.name, size: 36, tint: r.tint),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.name, style: AppText.bodyStrong),
                              const SizedBox(height: 2),
                              Text('Trip ${r.date}', style: AppText.small.muted),
                            ],
                          ),
                        ),
                        Stars(r.stars, size: 14),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(r.text, style: AppText.body),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
        ],
      ],
    );
  }

  Widget _comments(AppState app, Itinerary it) {
    final list = app.commentsOf(it);
    if (list.isEmpty) {
      return const EmptyState(icon: 'chat_bubble', title: 'Belum ada komentar', text: 'Tanyakan jam buka, rute, atau tips ke creator di sini.');
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final c in list)
          Padding(
            padding: EdgeInsets.fromLTRB(c.replyTo != null ? kMargin + 36 : kMargin, 12, kMargin, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Avatar(c.name, size: 36, tint: c.tint),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(c.name, style: AppText.bodyStrong),
                          if (c.creator) const Pill('Creator', kind: PillKind.teal),
                          Text(c.time, style: AppText.small.muted),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(c.text, style: AppText.body),
                      TextLink(
                        'Balas',
                        style: AppText.smallStrong,
                        onTap: () {
                          if (!requireLogin(context)) return;
                          setState(() => replyTo = c.name);
                          focus.requestFocus();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _composer(AppState app) => Material(
    color: AppColors.surface,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
