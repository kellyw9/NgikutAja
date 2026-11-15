import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 7.4 Trip Journal.
class JournalPage extends StatefulWidget {
  const JournalPage({super.key, required this.trip});
  final Trip trip;

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late int day = AppScope.read(context).statusOf(widget.trip) == TripStatus.berjalan ? AppScope.read(context).currentDay(widget.trip) : 0;

  String _dayLabel(int d) {
    final date = widget.trip.dayDate(d);
    return date == null ? 'Hari ${d + 1}' : 'Hari ${d + 1}, ${date.day} ${monthsShort[date.month - 1]}';
  }

  Future<void> _editStory() async {
    final c = TextEditingController(text: widget.trip.story);
    final r = await showNgSheet<String>(
      context,
      title: 'Cerita perjalanan',
      builder: (ctx) => Gap(
        16,
        children: [
          NgField(controller: c, area: true, hint: 'Ceritakan trip ini dalam beberapa kalimat.', autofocus: true),
          NgButton('Simpan', expand: true, onPressed: () => Navigator.pop(ctx, c.text.trim())),
        ],
      ),
    );
    c.dispose();
    if (r == null || !mounted) return;
    widget.trip.story = r;
    AppScope.read(context).touch();
  }

  Future<void> _write() async {
    final e = widget.trip.journal[day];
    final title = TextEditingController(text: e?.title ?? '');
    final text = TextEditingController();
    final r = await showNgSheet<bool>(
      context,
      title: e == null ? 'Tulis catatan ${_dayLabel(day)}' : 'Tulis lanjutan',
      scroll: true,
      builder: (ctx) => Gap(
