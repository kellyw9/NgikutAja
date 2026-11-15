import 'package:flutter/material.dart';

import '../../widgets/ui.dart';

/// 9.3 Daftar Follower dan 9.4 Daftar Following.
class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key, required this.followers});
  final bool followers;

  @override
  State<PeoplePage> createState() => _PeoplePageState();
