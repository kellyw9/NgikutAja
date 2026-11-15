import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../explore/itinerary_detail_page.dart';
import '../trips/adopt_page.dart';

String txDate(DateTime d) => '${d.day} ${monthsShort[d.month - 1]} ${d.year}, ${fromMinutes(d.hour * 60 + d.minute)}';

const _simNote = NgBanner(kind: BannerKind.info, icon: 'info', text: 'Mode simulasi: tidak ada uang sungguhan yang ditarik.');
