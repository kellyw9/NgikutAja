import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../shell/home_shell.dart';
import 'day_editor_page.dart';

const tagOptions = ['Alam', 'Kuliner', 'Budaya', 'Sejarah', 'Hemat', 'Keluarga', 'Petualangan'];

/// Penanda "Draft" di app bar alur Create.
const draftPill = Pill('Draft', kind: PillKind.warning);

/// Simpan draft lalu tutup alur Create dan buka Trip Saya > Draft.
void saveDraftAndClose(BuildContext context, Itinerary d) {
  AppScope.read(context).saveDraft(d);
  goTab(context, tabTrips, trips: TripStatus.draft);
  showNgSnack(context, 'Draft tersimpan di Trip Saya.', kind: SnackKind.success);
}

/// Langkah 1: Buat Itinerary (+ state validasi error).
class CreateItineraryPage extends StatefulWidget {
  const CreateItineraryPage({super.key, this.draft});
  final Itinerary? draft;
