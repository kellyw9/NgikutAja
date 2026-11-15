import 'package:flutter/material.dart';

import '../../widgets/ui.dart';
import '../explore/itinerary_detail_page.dart';

class SearchRequest {
  SearchRequest(this.query);
  final String query;
}

/// Permintaan pencarian dari halaman lain (misalnya kartu kota di Explore).
final searchRequest = ValueNotifier<SearchRequest?>(null);

const _maxBudget = 5000000.0;
const _durations = ['1 hari', '2–3 hari', '4–5 hari', '> 5 hari'];
const _ratings = ['3+', '4+', '4,5+'];
const _sorts = ['Relevan', 'Rating tertinggi', 'Paling banyak diadopsi', 'Harga terendah'];

class SearchFilter {
  String? duration;
  RangeValues budget = const RangeValues(0, _maxBudget);
  String? rating;
  String price = 'Semua';

  bool get budgetOn => budget.start > 0 || budget.end < _maxBudget;
  int get count => [duration != null, budgetOn, rating != null, price != 'Semua'].where((x) => x).length;

  SearchFilter copy() => SearchFilter()
    ..duration = duration
    ..budget = budget
    ..rating = rating
    ..price = price;

  bool match(Itinerary it) {
    final d = it.days;
    if (duration == '1 hari' && d != 1) return false;
    if (duration == '2–3 hari' && (d < 2 || d > 3)) return false;
    if (duration == '4–5 hari' && (d < 4 || d > 5)) return false;
    if (duration == '> 5 hari' && d <= 5) return false;
    if (budgetOn) {
      final e = it.estimate;
      if (e == null || e < budget.start || e > budget.end) return false;
    }
    final min = switch (rating) {
      '3+' => 3.0,
      '4+' => 4.0,
      '4,5+' => 4.5,
      _ => null,
    };
    if (min != null && (it.rating ?? 0) < min) return false;
    if (price == 'Gratis' && it.isPaid) return false;
    if (price == 'Berbayar' && !it.isPaid) return false;
    return true;
  }
}

/// 3.1 sampai 3.3: Pencarian, mengetik, hasil, kosong. Filter di bottom sheet (3.2).
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final input = TextEditingController();
  final focus = FocusNode();
  String mode = 'Kota';
  String? submitted;
  SearchFilter filter = SearchFilter();
  String sort = 'Relevan';

  @override
  void initState() {
    super.initState();
    focus.addListener(() => setState(() {}));
    searchRequest.addListener(_onRequest);
  }

  void _onRequest() {
    final r = searchRequest.value;
    if (r == null) return;
    searchRequest.value = null;
    if (r.query.isEmpty) {
      setState(() {
        submitted = null;
        input.clear();
      });
    } else {
      _submit(r.query);
    }
  }

  @override
  void dispose() {
    searchRequest.removeListener(_onRequest);
    input.dispose();
    focus.dispose();
    super.dispose();
  }

  void _submit(String q) {
    final v = q.trim();
    if (v.isEmpty) return;
    input.text = v;
    focus.unfocus();
    AppScope.read(context).addRecent(v);
    setState(() => submitted = v);
  }

  bool _matchQuery(Itinerary it, String q) {
    final s = q.toLowerCase();
    final inPlace =
        it.city.toLowerCase().contains(s) || it.region.toLowerCase().contains(s) || (s.contains('toba') && it.title.toLowerCase().contains('toba'));
    final inTitle = it.title.toLowerCase().contains(s) || it.creator.handle.toLowerCase().contains(s);
    return mode == 'Kota' ? inPlace || inTitle : inTitle || inPlace;
  }

  List<Itinerary> results(AppState app, String q, [SearchFilter? f]) {
    final list = app.itineraries.where((x) => !x.isDraft && _matchQuery(x, q) && (f ?? filter).match(x)).toList();
    switch (sort) {
      case 'Rating tertinggi':
        list.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      case 'Paling banyak diadopsi':
        list.sort((a, b) => b.adopted.compareTo(a.adopted));
      case 'Harga terendah':
        list.sort((a, b) => a.price.compareTo(b.price));
      default:
        // relevan: judul yang memuat kata kunci didahulukan, lalu yang paling banyak diadopsi
        int score(Itinerary x) => (x.title.toLowerCase().contains(q.toLowerCase()) ? 10000 : 0) + x.adopted;
        list.sort((a, b) => score(b).compareTo(score(a)));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final typing = focus.hasFocus && input.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TabHeader('Cari'),
        _searchRow(),
        if (submitted == null || typing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kMargin),
            child: Segmented(items: const ['Kota', 'Itinerary'], active: mode, onChanged: (m) => setState(() => mode = m)),
          ),
        Expanded(child: typing ? _suggestions(app) : (submitted == null ? _idle(app) : _results(app, submitted!))),
      ],
    );
  }

  Widget _searchRow() => Padding(
    padding: const EdgeInsets.fromLTRB(kMargin, 6, kMargin, 10),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.only(left: 12, right: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: Border.all(color: focus.hasFocus ? AppColors.ink : AppColors.control, width: focus.hasFocus ? 2 : 1),
            ),
            child: Row(
              children: [
                const AppIcon('search', size: 20, color: AppColors.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: input,
                    focusNode: focus,
                    style: AppText.body,
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: _submit,
                    decoration: InputDecoration.collapsed(hintText: 'Cari kota atau itinerary', hintStyle: AppText.body.muted),
                  ),
                ),
                if (input.text.isNotEmpty)
                  IconBtn(
                    'close',
                    label: 'Hapus kata kunci',
                    size: 40,
                    iconSize: 18,
                    color: AppColors.muted,
                    onTap: () {
                      input.clear();
                      setState(() => submitted = null);
                      focus.requestFocus();
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconBtn(
              'tune',
              label: filter.count > 0 ? 'Filter, ${filter.count} aktif' : 'Filter',
              size: 48,
              bg: AppColors.surface,
              stroke: AppColors.control,
              onTap: _openFilter,
            ),
            if (filter.count > 0)
              Positioned(
                left: 30,
                top: -2,
                child: IgnorePointer(
                  child: Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(4)),
                    child: Text('${filter.count}', style: AppText.smallStrong.white),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _idle(AppState app) => ListView(
    padding: const EdgeInsets.only(top: 16, bottom: 24),
    children: [
      if (app.recentSearches.isNotEmpty) ...[
        SectionHead('Pencarian terakhir', action: 'Hapus', onAction: app.clearRecent),
        const SizedBox(height: 8),
        for (final q in app.recentSearches)
          Tap(
            onTap: () => _submit(q),
            child: SizedBox(
              height: 44,
              child: Padding(
                padding: const EdgeInsets.only(left: kMargin, right: 8),
                child: Row(
                  children: [
                    const AppIcon('history', size: 20, color: AppColors.muted),
                    const SizedBox(width: 12),
                    Expanded(child: Text(q, style: AppText.body)),
                    IconBtn(
                      'close',
                      label: 'Hapus $q dari riwayat',
                      size: 40,
                      iconSize: 18,
                      color: AppColors.muted,
                      onTap: () => app.removeRecent(q),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
      const SectionHead('Kota populer'),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: kMargin),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final c in AppState.cities) NgChip(c.name, icon: 'location_on', onTap: () => _submit(c.name))],
        ),
      ),
    ],
  );

  Widget _suggestions(AppState app) {
    final q = input.text.trim().toLowerCase();
    final cities = AppState.cities.where((c) => c.name.toLowerCase().contains(q)).toList();
    final itins = app.itineraries.where((x) => !x.isDraft && x.title.toLowerCase().contains(q)).take(5).toList();
    final rows = <Widget>[
      if (mode == 'Kota')
        for (final c in cities) _suggest('location_on', c.name, 'Kota, ${app.cityCount(c)} itinerary', () => _submit(c.name)),
      for (final it in itins) _suggest('map', it.title, 'Itinerary oleh ${it.creator.handle}', () => openItinerary(context, it)),
      if (mode == 'Itinerary')
        for (final c in cities) _suggest('location_on', c.name, 'Kota, ${app.cityCount(c)} itinerary', () => _submit(c.name)),
    ];
    if (rows.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(kMargin, 16, kMargin, 0),
        children: [Text('Tekan cari untuk melihat hasil "${input.text.trim()}".', style: AppText.body.muted)],
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: 12),
      children: [
        for (var i = 0; i < rows.length; i++) ...[if (i > 0) const NgDivider(inset: kMargin), rows[i]],
      ],
    );
