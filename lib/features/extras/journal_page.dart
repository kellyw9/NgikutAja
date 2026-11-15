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
        16,
        children: [
          if (e == null) NgField(label: 'Judul', controller: title, hint: 'Misal: Kapal jam 8, langsung ke Tuktuk'),
          NgField(label: e == null ? 'Catatan' : 'Lanjutan catatan', controller: text, area: true, autofocus: e != null),
          NgButton('Simpan catatan', expand: true, onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    final tt = title.text.trim(), tx = text.text.trim();
    title.dispose();
    text.dispose();
    if (r != true || tx.isEmpty || !mounted) return;
    if (e == null) {
      widget.trip.journal[day] = JournalEntry(title: tt.isEmpty ? _dayLabel(day) : tt, text: tx, photos: []);
    } else {
      e.text = '${e.text}\n\n$tx';
    }
    AppScope.read(context).touch();
  }

  Future<void> _addPhoto() async {
    final p = await pickPhotoSheet(context, title: 'Tambah foto ke catatan');
    if (p == null || p.isEmpty || !mounted) return;
    final t = widget.trip;
    final e = t.journal.putIfAbsent(day, () => JournalEntry(title: _dayLabel(day), text: '', photos: []));
    e.photos = [...e.photos, p];
    final now = DateTime.now();
    AppScope.read(context).addPhoto(t, TripPhoto(src: p, day: day, caption: e.title, time: fromMinutes(now.hour * 60 + now.minute)));
  }

  @override
  Widget build(BuildContext context) {
    AppScope.of(context);
    final t = widget.trip;
    final e = t.journal[day];
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: NgAppBar(
        title: 'Trip journal',
        sub: t.title,
        actions: [IconBtn('edit', label: 'Ubah cerita perjalanan', onTap: _editStory)],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kMargin),
            child: NgCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cerita perjalanan', style: AppText.smallStrong.muted),
                  const SizedBox(height: 4),
                  Text(
                    t.story.isEmpty ? 'Belum ada cerita. Ketuk ikon pensil untuk menulis.' : t.story,
                    style: t.story.isEmpty ? AppText.body.muted : AppText.body,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (t.days <= 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kMargin),
              child: Segmented(
                items: [for (var d = 0; d < t.days; d++) _dayLabel(d)],
                active: _dayLabel(day),
                onChanged: (l) => setState(() => day = [for (var d = 0; d < t.days; d++) _dayLabel(d)].indexOf(l)),
              ),
            )
          else
            DayStrip(days: [for (var d = 0; d < t.days; d++) DayItem('Hari ${d + 1}')], active: day, onTap: (d) => setState(() => day = d)),
          Padding(
            padding: const EdgeInsets.fromLTRB(kMargin, 14, kMargin, 0),
            child: Gap(
              12,
              children: [
                if (e == null)
                  Text('Belum ada catatan untuk ${_dayLabel(day)}.', style: AppText.body.muted)
                else ...[
                  Text(e.title, style: AppText.h2),
                  if (e.text.isNotEmpty) Text(e.text, style: AppText.body),
                  if (e.photos.isNotEmpty)
                    Row(
                      children: [
                        for (var k = 0; k < e.photos.length && k < 2; k++) ...[
                          if (k > 0) const SizedBox(width: 8),
                          Expanded(child: Photo(e.photos[k], height: 120, radius: AppRadius.inner)),
                        ],
