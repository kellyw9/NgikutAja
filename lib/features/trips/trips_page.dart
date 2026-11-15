import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../create/create_itinerary_page.dart';
import '../extras/memory_pages.dart';
import '../extras/recap_page.dart';
import '../shell/home_shell.dart';
import '../travel/travel_mode_page.dart';
import 'trip_detail_page.dart';

/// 5.1 Daftar Trip: Draft, Diadopsi, Berjalan, Selesai.
class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ValueListenableBuilder<TripStatus>(
      valueListenable: tripsTab,
      builder: (context, tab, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TabHeader('Trip Saya'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kMargin),
            child: Segmented(
              items: [for (final s in TripStatus.values) s.label],
              active: tab.label,
              onChanged: (l) => tripsTab.value = TripStatus.values.firstWhere((s) => s.label == l),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(kMargin, 16, kMargin, 24),
              children: switch (tab) {
                TripStatus.draft => _drafts(context, app),
                _ => _trips(context, app, tab),
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _drafts(BuildContext context, AppState app) {
    if (app.drafts.isEmpty) {
      return [
        EmptyState(
          icon: 'edit_note',
          title: 'Belum ada draft',
          text: 'Itinerary yang kamu simpan sebagai draft muncul di sini sampai diterbitkan.',
          action: NgButton(
            'Buat itinerary',
            kind: BtnKind.secondary,
            size: BtnSize.md,
            onPressed: () => push(context, const CreateItineraryPage(), fullscreen: true),
          ),
        ),
      ];
    }
    return [
      for (final d in app.drafts) ...[
        TripCard(
          status: TripStatus.draft,
          title: d.title,
          city: d.city,
          days: d.days,
          cover: d.cover,
          onTap: () => push(context, CreateItineraryPage(draft: d), fullscreen: true),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  List<Widget> _trips(BuildContext context, AppState app, TripStatus tab) {
    final list = app.tripsWith(tab);
    if (list.isEmpty) {
