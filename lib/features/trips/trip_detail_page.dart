import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../explore/itinerary_detail_page.dart';
import '../extras/journal_page.dart';
import '../extras/memory_pages.dart';
import '../extras/packing_page.dart';
import '../extras/recap_page.dart';
import '../extras/split_budget_page.dart';
import '../extras/tips_page.dart';
import '../travel/offline_page.dart';
import '../travel/travel_mode_page.dart';
import 'customize_page.dart';
import 'members_page.dart';

/// 5.3 Detail Trip.
class TripDetailPage extends StatefulWidget {
  const TripDetailPage({super.key, required this.trip});
  final Trip trip;

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  int? _day;

  void _menu() => showNgSheet<void>(
    context,
    title: widget.trip.title,
    builder: (ctx) => Column(
      children: [
        ListRow(
          icon: 'edit',
          title: 'Edit informasi trip',
          padH: 0,
          onTap: () {
            Navigator.pop(ctx);
            push(context, EditTripInfoPage(trip: widget.trip), fullscreen: true);
          },
        ),
        const NgDivider(inset: 36, color: AppColors.line),
        ListRow(
          icon: 'download_for_offline',
          title: 'Data offline',
          padH: 0,
          onTap: () {
            Navigator.pop(ctx);
            push(context, const OfflinePage());
          },
        ),
        const NgDivider(inset: 36, color: AppColors.line),
        ListRow(
          icon: 'share',
          title: 'Bagikan trip',
          padH: 0,
          trailing: null,
          onTap: () {
            Navigator.pop(ctx);
            shareText('Trip "${widget.trip.title}" ${widget.trip.dates ?? ''} di ${widget.trip.city}. Dibuat dengan NgikutAja.');
          },
        ),
      ],
    ),
  );

  void _stopSheet(Trip t, int day, int i) {
    final st = t.plan[day][i];
    showNgSheet<void>(
      context,
      scroll: true,
      builder: (ctx) => Gap(
        16,
        children: [
          if (st.photo != null) Photo(st.photo, height: 180, radius: AppRadius.card, semantic: st.name),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(st.name, style: AppText.h2),
              const SizedBox(height: 4),
              MetaRow([(st.cat.icon, st.cat.label), ('schedule', '${st.start}–${st.end}'), ('payments', st.cost > 0 ? rp(st.cost) : 'Gratis')]),
            ],
          ),
          if (st.desc != null) Text(st.desc!, style: AppText.body),
          if (st.note != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.yellowPale, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Row(
                children: [
                  const AppIcon('lightbulb', size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(st.note!, style: AppText.body)),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: NgButton(
                  'Edit',
                  kind: BtnKind.secondary,
                  icon: 'edit',
                  expand: true,
                  onPressed: () {
                    Navigator.pop(ctx);
                    push(context, CustomizePage(trip: t, initialDay: day));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NgButton(
                  'Buka di peta',
                  icon: 'map',
                  expand: true,
                  onPressed: () {
                    openMaps('${st.name}, ${st.address ?? t.region}');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = widget.trip;
    final status = app.statusOf(t);
    final day = (_day ?? (status == TripStatus.berjalan ? app.currentDay(t) : 0)).clamp(0, t.days - 1);
    final stops = t.plan[day];
    final it = t.from;
    final tips = app.seed.tips[t.city] ?? const [];
    final next = status == TripStatus.berjalan ? app.nextIndex(t, day) : null;

    String toolSub(String key) => switch (key) {
      'split' => t.expenses.isEmpty ? 'Belum ada pengeluaran' : '${t.expenses.length} pengeluaran, ${rp(t.expenseTotal)}',
      'pack' =>
        t.packing.isEmpty
            ? 'Belum ada barang'
            : '${t.packing.fold(0, (a, g) => a + g.items.where((x) => x.done).length)} dari ${t.packing.fold(0, (a, g) => a + g.items.length)} barang siap',
      'tips' => tips.isEmpty ? 'Belum ada tips untuk ${t.city}' : '${tips.length} tips untuk ${t.city}',
      'journal' => t.journal.isEmpty ? 'Ditulis saat trip berjalan' : '${t.journal.length} catatan harian',
      'photo' => t.photos.isEmpty ? 'Belum ada foto' : '${t.photos.length} foto',
      _ =>
        status == TripStatus.selesai ? 'Ringkasan trip sudah siap' : 'Tersedia setelah ${t.end != null ? dateRange(t.end!, t.end!) : 'trip selesai'}',
    };

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          HeroPhoto(
            t.cover,
            height: 220,
            semantic: 'Foto sampul ${t.title}',
            right: [IconBtn('more_vert', label: 'Menu trip', bg: AppColors.surface, size: 40, onTap: _menu)],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(kMargin, 16, kMargin, 0),
            child: Gap(
              14,
              children: [
                Row(
                  children: [
                    Pill(status.label, kind: tripPill(status)),
                    const SizedBox(width: 8),
                    if (app.countdown(t) != null) Text(app.countdown(t)!, style: AppText.small.muted),
                    if (status == TripStatus.berjalan) Text('Hari ${app.currentDay(t) + 1} dari ${t.days}', style: AppText.small.muted),
                  ],
                ),
                Text(t.title, style: AppText.h1),
                MetaRow([('location_on', t.city), ('calendar_month', t.dates ?? 'Tanggal belum diatur'), ('schedule', '${t.days} hari')]),
                if (it != null)
                  Tap(
                    onTap: () => openItinerary(context, it),
                    radius: 4,
                    child: Row(
                      children: [
                        Avatar(it.creator.name, size: 20, tint: it.creator.tint),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: AppText.small,
                              children: [
                                TextSpan(text: 'Diadopsi dari itinerary ', style: AppText.small.muted),
                                TextSpan(text: it.creator.handle, style: AppText.smallStrong),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: NgButton(
                        'Customize',
                        icon: 'edit',
                        expand: true,
                        onPressed: status == TripStatus.selesai ? null : () => push(context, CustomizePage(trip: t, initialDay: day)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NgButton(
                        'Anggota',
                        kind: BtnKind.secondary,
                        icon: 'group',
                        expand: true,
                        onPressed: () => push(context, MembersPage(trip: t)),
                      ),
                    ),
                  ],
                ),
                if (status == TripStatus.berjalan)
                  NgButton(
                    'Buka Travel Mode',
                    kind: BtnKind.secondary,
                    icon: 'near_me',
                    expand: true,
                    onPressed: () => push(context, TravelModePage(trip: t), fullscreen: true),
                  )
                else if (status == TripStatus.diadopsi && t.start != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        const AppIcon('near_me', size: 18, color: AppColors.muted),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Travel Mode aktif mulai ${dateLong(t.start!)}.', style: AppText.small.muted)),
                      ],
                    ),
                  ),
                const NgDivider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fitur perjalanan', style: AppText.h2),
                    const SizedBox(height: 2),
                    for (final (i, (icon, title, key)) in const [
                      ('call_split', 'Split budget', 'split'),
                      ('backpack', 'Packing list', 'pack'),
                      ('lightbulb', 'Local tips', 'tips'),
                      ('menu_book', 'Trip journal', 'journal'),
                      ('photo_library', 'Photo memory', 'photo'),
                      ('flag', 'Trip recap', 'recap'),
                    ].indexed) ...[
                      if (i > 0) const NgDivider(inset: 36),
                      ListRow(
                        icon: icon,
                        title: title,
                        sub: toolSub(key),
                        padH: 0,
                        onTap: () => switch (key) {
                          'split' => push(context, SplitBudgetPage(trip: t)),
                          'pack' => push(context, PackingPage(trip: t)),
                          'tips' => push(context, TipsPage(trip: t)),
                          'journal' => push(context, JournalPage(trip: t)),
                          'photo' => push(context, PhotoMemoryPage(trip: t)),
                          _ =>
                            status == TripStatus.selesai
                                ? push(context, RecapPage(trip: t))
                                : Future.sync(() => showNgSnack(context, 'Trip recap tersedia setelah trip selesai.')),
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHead('Jadwal harian'),
          const SizedBox(height: 8),
          DayStrip(
            days: [
              for (var d = 0; d < t.days; d++)
                DayItem('Hari ${d + 1}', date: t.dayDate(d) == null ? null : dateShort(t.dayDate(d)!), sub: '${t.plan[d].length} tempat'),
            ],
            active: day,
            today: status == TripStatus.berjalan ? app.currentDay(t) : null,
            onTap: (d) => setState(() => _day = d),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(kMargin, 12, kMargin, 24),
            child: stops.isEmpty
                ? Text('Belum ada aktivitas di Hari ${day + 1}. Tambahkan lewat Customize.', style: AppText.body.muted)
