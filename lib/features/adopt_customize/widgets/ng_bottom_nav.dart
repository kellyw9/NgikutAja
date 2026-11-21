import 'package:flutter/material.dart';

import '../adopt_customize_theme.dart';
import 'ng_widgets.dart';

enum NgNavTab { explore, search, create, myTrips, profile }

/// Bottom navigation aplikasi (desain): Explore, Cari, Create (bulat kuning),
/// Trip Saya, Profil.
///
/// TODO(INTEGRASI): bottom nav ini milik kerangka aplikasi (shell), bukan
/// modul Adopt & Customize. Saat integrasi, pindahkan ke ShellRoute go_router
/// dan isi [onTap] dengan rute modul masing-masing. Selama [onTap] null,
/// tab selain tab aktif hanya menampilkan pesan "belum tersambung".
class NgBottomNav extends StatelessWidget {
  const NgBottomNav({super.key, required this.current, this.onTap});

  final NgNavTab current;
  final void Function(NgNavTab tab)? onTap;

  static const _labels = {
    NgNavTab.explore: 'Explore',
    NgNavTab.search: 'Cari',
    NgNavTab.create: 'Create',
    NgNavTab.myTrips: 'Trip Saya',
    NgNavTab.profile: 'Profil',
  };

  void _handle(BuildContext context, NgNavTab tab) {
    final handler = onTap;
    if (handler != null) {
      handler(tab);
    } else if (tab != current) {
      showNotConnected(context, 'Halaman ${_labels[tab]}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: NgColors.creamDark)),
      ),
      // SafeArea: tombol navigasi HP tidak menutupi bottom nav.
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _item(context, NgNavTab.explore, Icons.explore_outlined),
              _item(context, NgNavTab.search, Icons.search),
              Expanded(child: _createButton(context)),
              _item(context, NgNavTab.myTrips, Icons.luggage_outlined),
              _item(context, NgNavTab.profile, Icons.person_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, NgNavTab tab, IconData icon) {
    final selected = tab == current;
    return Expanded(
      child: InkWell(
        onTap: () => _handle(context, tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? NgColors.cream : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 24, color: NgColors.teal),
            ),
            const SizedBox(height: 4),
            Text(
              _labels[tab]!,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                color: NgColors.teal,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createButton(BuildContext context) {
    return InkWell(
      onTap: () => _handle(context, NgNavTab.create),
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: NgColors.yellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 28, color: NgColors.teal),
          ),
          const SizedBox(height: 2),
          const Text(
            'Create',
            style: TextStyle(fontSize: 12, color: NgColors.teal),
          ),
        ],
      ),
    );
  }
}