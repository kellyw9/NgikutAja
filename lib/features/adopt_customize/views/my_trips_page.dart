import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../adopt_customize_routes.dart';
import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';
import '../services/auth_bridge.dart';
import '../adopt_customize_theme.dart';
import '../utils/format_utils.dart';
import '../viewmodels/my_trips_view_model.dart';
import '../widgets/message_view.dart';
import '../widgets/ng_bottom_nav.dart';
import '../widgets/trip_card.dart';

/// Halaman Trip Saya (desain): tab Draft / Diadopsi / Berjalan / Selesai.
/// TODO(INTEGRASI): bottom navigation (Explore, Cari, Create, Trip Saya,
/// Profil) milik shell aplikasi, bukan halaman ini.
class MyTripsPage extends StatelessWidget {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyTripsViewModel>(
      create: (ctx) => MyTripsViewModel(
        authBridge: ctx.read<AuthBridge>(),
        tripRepository: ctx.read<TripRepository>(),
      )..load(),
      child: const _MyTripsView(),
    );
  }
}

class _MyTripsView extends StatelessWidget {
  const _MyTripsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyTripsViewModel>();

    final Widget body;
    if (vm.isLoading && vm.trips.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.requiresLogin) {
      body = const MessageView(
        icon: Icons.lock_outline,
        text: 'Silakan login untuk melihat Trip Saya.',
      );
    } else if (vm.errorMessage != null) {
      body = MessageView(
        icon: Icons.wifi_off,
        text: vm.errorMessage!,
        actionLabel: 'Coba lagi',
        onAction: vm.load,
      );
    } else if (vm.isEmpty) {
      body = const MessageView(
        icon: Icons.luggage_outlined,
        text: 'Belum ada trip. Cari itinerary di Explore lalu Adopt.',
      );
    } else {
      body = DefaultTabController(
        length: MyTripsViewModel.tabOrder.length,
        initialIndex: vm.initialTabIndex,
        child: Column(
          children: [
            TabBar(
              labelColor: NgColors.teal,
              unselectedLabelColor: NgColors.textMuted,
              indicatorColor: NgColors.tealMid,
              indicatorWeight: 3,
              dividerColor: NgColors.creamDark,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 15),
              tabs: [
                for (final phase in MyTripsViewModel.tabOrder)
                  Tab(text: tripPhaseLabel(phase)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  for (final phase in MyTripsViewModel.tabOrder)
                    _TripList(vm: vm, phase: phase),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: NgColors.cream,
      appBar: AppBar(
        backgroundColor: NgColors.cream,
        titleSpacing: 20,
        title: const Text(
          'Trip Saya',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: NgColors.teal,
          ),
        ),
      ),
      body: body,
      // TODO(INTEGRASI): bottom nav milik shell aplikasi; lihat NgBottomNav.
      bottomNavigationBar: const NgBottomNav(current: NgNavTab.myTrips),
    );
  }
}

class _TripList extends StatelessWidget {
  const _TripList({required this.vm, required this.phase});

  final MyTripsViewModel vm;
  final TripPhase phase;

  static String _emptyText(TripPhase phase) {
    switch (phase) {
      case TripPhase.draft:
        return 'Tidak ada draft.';
      case TripPhase.upcoming:
        return 'Belum ada trip yang akan berangkat.';
      case TripPhase.ongoing:
        return 'Tidak ada trip yang sedang berjalan.';
      case TripPhase.done:
        return 'Belum ada trip yang selesai.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final trips = vm.tripsOf(phase);
    return RefreshIndicator(
      onRefresh: vm.load,
      child: trips.isEmpty
          ? ListView(
              // ListView agar tarik-untuk-muat-ulang tetap bisa.
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text(_emptyText(phase))),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return TripCard(
                  trip: trip,
                  today: vm.today,
                  // TODO(INTEGRASI): isi callback Travel Mode / Recap /
                  // Photo Memory setelah rute modul lain tersedia.
                  onTap: () async {
                    await context.push(
                      AdoptCustomizeRoutes.tripDetail(trip.id),
                    );
                    // Muat ulang setelah kembali dari detail.
                    if (context.mounted) vm.load();
                  },
                );
              },
            ),
    );
  }
}