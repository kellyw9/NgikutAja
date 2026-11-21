// SEMENTARA: HAPUS SETELAH SELESAI DICOBA
// Pengganti halaman Explore (Anggota 3).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../adopt_customize_routes.dart';
import 'dummy_data.dart';

class DummyHomePage extends StatefulWidget {
  const DummyHomePage({super.key});

  @override
  State<DummyHomePage> createState() => _DummyHomePageState();
}

class _DummyHomePageState extends State<DummyHomePage> {
  @override
  Widget build(BuildContext context) {
    final auth = context.read<DummyAuthBridge>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore (dummy)'),
        actions: [
          IconButton(
            tooltip: 'Trip Saya',
            icon: const Icon(Icons.luggage_outlined),
            onPressed: () => context.push(AdoptCustomizeRoutes.myTrips),
          ),
          const Center(child: Text('Login')),
          Switch(
            value: auth.isLoggedIn,
            onChanged: (value) {
              // TODO(AUTH): simulasi saja. Hapus saat Anggota 1 selesai.
              auth.setUser(value ? kDummyUserId : null);
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Kuliner Jogja'),
              subtitle: const Text('2 hari · Gratis'),
              onTap: () => context.push('/itinerary/$kDummyFreeItineraryId'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Bali Hemat'),
              subtitle: const Text('1 hari · Rp29.000'),
              onTap: () => context.push('/itinerary/$kDummyPaidItineraryId'),
            ),
          ),
        ],
      ),
    );
  }
}
