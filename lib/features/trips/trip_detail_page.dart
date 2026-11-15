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
