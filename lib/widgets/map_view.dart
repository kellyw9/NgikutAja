import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/text.dart';
import 'basics.dart';

enum MapKind { city, lake }

class MapPin {
  const MapPin(this.x, this.y, {this.n = 1, this.state = MarkerState.todo});
  final double x;
  final double y;
  final int n;
  final MarkerState state;
}

/// Peta sementara (gambar, bukan peta asli). Diberi label "Peta sementara" supaya tidak
/// disangka peta sungguhan. Ganti dengan widget peta asli saat integrasi peta dikerjakan.
class MapView extends StatelessWidget {
  const MapView({
    super.key,
    this.height = 200,
    this.kind = MapKind.city,
    this.pins = const [],
    this.me,
    this.radius = AppRadius.card,
    this.route = true,
    this.ring,
    this.onTapPoint,
    this.label = true,
    this.overlay = const [],
