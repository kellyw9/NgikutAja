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

  @override
  State<CreateItineraryPage> createState() => _CreateItineraryPageState();
}

class _CreateItineraryPageState extends State<CreateItineraryPage> {
  late final Itinerary d = widget.draft ?? AppScope.read(context).newDraft();
  late final title = TextEditingController(text: d.title);
  late final desc = TextEditingController(text: d.desc);
  late final city = TextEditingController(text: d.region);
  late bool paid = d.price > 0;
  bool tried = false;
  bool touched = false;

  bool get titleOk => title.text.trim().isNotEmpty;

  void _apply() {
    d
      ..title = title.text.trim()
      ..desc = desc.text.trim()
      ..region = city.text.trim()
      ..city = city.text.split(',').first.trim();
    if (!paid) d.price = 0;
    if (paid && d.price == 0) d.price = 25000;
  }

  void _setDays(int n) {
    setState(() {
      touched = true;
      d.days = n;
      while (d.plan.length < n) {
        d.plan.add([]);
