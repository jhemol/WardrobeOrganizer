import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'wardrobe_models.dart';
import 'wardrobe_store.dart';

const _ink = Color(0xFF28362E);
const _muted = Color(0xFF818980);
const _paper = Color(0xFFF4F5F0);
const _fern = Color(0xFF58735D);

void main() => runApp(const ThreadWardrobeApp());

class ThreadWardrobeApp extends StatelessWidget {
  const ThreadWardrobeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'thread. wardrobe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: _paper,
          colorScheme: ColorScheme.fromSeed(seedColor: _fern, brightness: Brightness.light),
          textTheme: ThemeData.light().textTheme.apply(bodyColor: _ink, displayColor: _ink),
          appBarTheme: const AppBarTheme(backgroundColor: _paper, foregroundColor: _ink, elevation: 0),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white.withValues(alpha: .8),
            indicatorColor: const Color(0xFFE4EBE2),
            labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFFF8F9F5),
            elevation: 3,
            shadowColor: const Color(0x18323E34),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: EdgeInsets.zero,
          ),
        ),
        home: const WardrobeHome(),
      );
}

class WardrobeHome extends StatefulWidget {
  const WardrobeHome({super.key});

  @override
  State<WardrobeHome> createState() => _WardrobeHomeState();
}

class _WardrobeHomeState extends State<WardrobeHome> {
  final _store = WardrobeStore();
  WardrobeData _data = WardrobeData();
  int _tab = 0;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());
  bool _loading = true;

  static final _sampleItems = <ClothingItem>[
    const ClothingItem(id: 'linen-shirt', name: 'Linen overshirt', category: 'Top', color: 'cream', colorHex: '#D9CDB8', image: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=700&q=85'),
    const ClothingItem(id: 'knit-tee', name: 'Ribbed knit tee', category: 'Top', color: 'olive', colorHex: '#77795A', image: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=700&q=85'),
    const ClothingItem(id: 'straight-denim', name: 'Relaxed straight denim', category: 'Bottom', color: 'denim', colorHex: '#617C91', image: 'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=700&q=85'),
    const ClothingItem(id: 'slip-dress', name: 'Sunday slip dress', category: 'Dress', color: 'burgundy', colorHex: '#794B54', image: 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?auto=format&fit=crop&w=700&q=85'),
    const ClothingItem(id: 'wool-cardigan', name: 'Soft wool cardigan', category: 'Layer', color: 'navy', colorHex: '#34475B', image: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?auto=format&fit=crop&w=700&q=85'),
    const ClothingItem(id: 'leather-loafers', name: 'Everyday loafers', category: 'Shoes', color: 'brown', colorHex: '#805C47', image: 'https://images.unsplash.com/photo-1531310197839-ccf54634509e?auto=format&fit=crop&w=700&q=85'),
    const ClothingItem(id: 'market-tote', name: 'Market tote', category: 'Accessory', color: 'red', colorHex: '#AC5B4C', image: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=700&q=85'),
    const ClothingItem(id: 'canvas-sneakers', name: 'Canvas sneakers', category: 'Shoes', color: 'white', colorHex: '#E4E1D8', image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=700&q=85'),
  ];

  static const _approaches = [
    ('Ease into the week', 'Reach for a familiar favorite and let it set the tone.'),
    ('Stay in one color family', 'Try nearby shades for a quiet, considered palette.'),
    ('Make one small contrast', 'Let one unexpected color do the talking.'),
    ('Dress by texture', 'Pair smooth, soft, and structured pieces.'),
    ('Take a favorite further', 'Rework a piece you already love in a new way.'),
    ('Add a playful detail', 'Choose one accessory that feels a little unlike you.'),
    ('Choose room to breathe', 'Keep it simple, comfortable, and your own.'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await _store.load();
    if (loaded.items.isEmpty) loaded.items.addAll(_sampleItems);
    if (loaded.looks.isEmpty) {
      loaded.looks[_dateKey(_selectedDay)] = const PlannedLook(title: 'Easy layers', items: ['linen-shirt', 'straight-denim', 'wool-cardigan', 'leather-loafers'], note: 'A little texture, a lot of ease.');
    }
    if (!mounted) return;
    setState(() {
      _data = loaded;
      _loading = false;
    });
    await _store.save(loaded);
  }

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  PlannedLook? get _todayLook => _data.looks[_dateKey(_selectedDay)];
  List<ClothingItem> _piecesFor(PlannedLook? look) => (look?.items ?? []).map(_itemById).whereType<ClothingItem>().toList();

  ClothingItem? _itemById(String id) {
    for (final item in _data.items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> _persist() async {
    setState(() {});
    await _store.save(_data);
  }

  Future<void> _editLook([PlannedLook? initial]) async {
    final result = await showModalBottomSheet<PlannedLook>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OutfitComposer(items: _data.items, initial: initial),
    );
    if (result == null) return;
    _data.looks[_dateKey(_selectedDay)] = result;
    await _persist();
  }

  Future<void> _addItem() async {
    final item = await showModalBottomSheet<ClothingItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddClothingSheet(),
    );
    if (item == null) return;
    _data.items.insert(0, item);
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 22,
        title: const Text('thread.', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: -.6)),
        actions: [
          if (!_loading) Padding(padding: const EdgeInsets.only(right: 12), child: Center(child: Text('${_data.items.length} pieces', style: const TextStyle(color: _muted, fontSize: 12)))),
          IconButton(onPressed: () => _showSettings(), icon: const Icon(Icons.tune_rounded), tooltip: 'Calendar settings'),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: IndexedStack(
                index: _tab,
                children: [
                  _calendarView(),
                  _closetView(),
                  _ideasView(),
                  _colorsView(),
                ],
              ),
            ),
      floatingActionButton: _loading || _tab == 2 || _tab == 3
          ? null
          : FloatingActionButton.extended(
              onPressed: _tab == 0 ? () => _editLook() : _addItem,
              backgroundColor: _fern,
              foregroundColor: Colors.white,
              icon: Icon(_tab == 0 ? Icons.add_rounded : Icons.add_a_photo_outlined),
              label: Text(_tab == 0 ? 'Plan a look' : 'Add a piece'),
            ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (index) => setState(() => _tab = index),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
              NavigationDestination(icon: Icon(Icons.checkroom_outlined), selectedIcon: Icon(Icons.checkroom_rounded), label: 'Closet'),
              NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Style ideas'),
              NavigationDestination(icon: Icon(Icons.palette_outlined), selectedIcon: Icon(Icons.palette_rounded), label: 'Colors'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calendarView() {
    final look = _todayLook;
    final pieces = _piecesFor(look);
    final todayApproach = _approaches[_selectedDay.weekday % 7];
    final first = DateTime(_month.year, _month.month, 1);
    final offset = first.weekday % 7;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final cellCount = ((offset + days + 6) ~/ 7) * 7;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 104),
      children: [
        _eyebrow('YOUR WEEK, YOUR WAY'),
        Text(DateFormat('EEEE, MMMM d').format(_selectedDay), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -.6)),
        const SizedBox(height: 16),
        _clayCard(
          child: Column(children: [
            Row(children: [
              Expanded(child: Text(DateFormat('MMMM yyyy').format(_month), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)), icon: const Icon(Icons.chevron_left_rounded)),
              IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)), icon: const Icon(Icons.chevron_right_rounded)),
            ]),
            Row(children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => Expanded(child: Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(day, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600))))).toList()),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cellCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 3, crossAxisSpacing: 3, childAspectRatio: 1),
              itemBuilder: (context, index) {
                final number = index - offset + 1;
                if (number < 1 || number > days) return const SizedBox.shrink();
                final date = DateTime(_month.year, _month.month, number);
                final key = _dateKey(date);
                final chosen = _dateKey(_selectedDay) == key;
                final planned = _data.looks[key] != null;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => _selectedDay = date),
                  child: Container(
                    decoration: BoxDecoration(color: chosen ? _fern : planned ? const Color(0xFFE7EDE5) : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                    child: Stack(alignment: Alignment.center, children: [
                      Text('$number', style: TextStyle(color: chosen ? Colors.white : _ink, fontSize: 13, fontWeight: chosen || planned ? FontWeight.w700 : FontWeight.w400)),
                      if (planned) Positioned(bottom: 5, child: Container(width: 4, height: 4, decoration: BoxDecoration(color: chosen ? Colors.white : _fern, shape: BoxShape.circle))),
                    ]),
                  ),
                );
              },
            ),
          ]),
        ),
        const SizedBox(height: 15),
        _clayCard(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 38, height: 38, decoration: const BoxDecoration(color: Color(0xFFE2EADF), shape: BoxShape.circle), child: const Icon(Icons.auto_awesome_rounded, color: _fern, size: 19)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _eyebrow('TODAY’S INTENTION'),
              Text(todayApproach.$1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(todayApproach.$2, style: const TextStyle(color: _muted, height: 1.4, fontSize: 12)),
            ])),
          ]),
        ),
        const SizedBox(height: 15),
        if (look == null || pieces.isEmpty)
          _clayCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.checkroom_rounded, color: _fern, size: 28), const SizedBox(height: 10), const Text('A day with possibility.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 4), const Text('Pick a few pieces and give this day a look of its own.', style: TextStyle(color: _muted)), const SizedBox(height: 12), OutlinedButton.icon(onPressed: () => _editLook(), icon: const Icon(Icons.add), label: const Text('Build an outfit'))]))
        else
          _clayCard(
            padding: EdgeInsets.zero,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _heroLookImage(pieces),
              Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _eyebrow('LOOK OF THE DAY'),
                Text(look.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                if (look.note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 5), child: Text('“${look.note}”', style: const TextStyle(color: _muted, fontStyle: FontStyle.italic))),
                const SizedBox(height: 14),
                _colorStory(pieces),
                const SizedBox(height: 12),
                SizedBox(height: 108, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: pieces.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, index) => _itemThumb(pieces[index], width: 76))),
                Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => _editLook(look), icon: const Icon(Icons.edit_outlined, size: 17), label: const Text('Edit look'))),
              ])),
            ]),
          ),
      ],
    );
  }

  Widget _closetView() {
    return ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 104), children: [
      _eyebrow('EVERYTHING YOU LOVE TO WEAR'),
      Text('Your closet', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -.6)),
      Text('${_data.items.length} pieces, all in one thoughtful place.', style: const TextStyle(color: _muted)),
      const SizedBox(height: 18),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _data.items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 14, childAspectRatio: .68),
        itemBuilder: (context, index) {
          final item = _data.items[index];
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Stack(children: [
              Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(18), child: _image(item.image, fit: BoxFit.cover, colorHex: item.colorHex))),
              Positioned(left: 9, top: 9, child: _glassPill(item.category)),
              Positioned(right: 5, top: 5, child: IconButton.filledTonal(onPressed: () async { _data.items.removeAt(index); for (final entry in _data.looks.entries.toList()) { final value = entry.value; _data.looks[entry.key] = PlannedLook(title: value.title, note: value.note, items: value.items.where((id) => id != item.id).toList()); } await _persist(); }, icon: const Icon(Icons.close_rounded, size: 16), visualDensity: VisualDensity.compact)),
            ])),
            const SizedBox(height: 7),
            Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text('${item.category} · ${item.color}', style: const TextStyle(color: _muted, fontSize: 11)),
          ]);
        },
      ),
    ]);
  }

  Widget _ideasView() {
    final tops = _data.items.where((item) => item.category == 'Top').toList();
    final bottoms = _data.items.where((item) => item.category == 'Bottom').toList();
    final dresses = _data.items.where((item) => item.category == 'Dress').toList();
    final shoes = _data.items.where((item) => item.category == 'Shoes').toList();
    final suggestions = <List<ClothingItem>>[];
    for (var index = 0; index < dresses.length; index++) {
      suggestions.add([dresses[index], if (shoes.isNotEmpty) shoes[index % shoes.length]]);
    }
    for (var index = 0; index < tops.length && bottoms.isNotEmpty; index++) {
      suggestions.add([tops[index], bottoms[index % bottoms.length], ..._data.items.where((item) => item.category == 'Layer').take(1), ...shoes.take(1)]);
    }
    return ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 104), children: [
      _eyebrow('THOUGHTFUL PAIRINGS FROM YOUR CLOSET'),
      const Text('Style ideas', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -.6)),
      const SizedBox(height: 5),
      const Text('Try a fresh combination from pieces you already own.', style: TextStyle(color: _muted)),
      const SizedBox(height: 16),
      for (var index = 0; index < suggestions.length; index++) _ideaCard(suggestions[index], index),
      if (suggestions.isEmpty) _clayCard(child: const Text('Add tops, bottoms, or dresses to see outfit ideas.')),
    ]);
  }

  Widget _ideaCard(List<ClothingItem> pieces, int index) {
    final lookName = pieces.any((item) => item.category == 'Dress') ? 'One piece, already a whole look' : ['A familiar favorite, remixed', 'Considered, not complicated', 'An easy day uniform'][index % 3];
    return Padding(padding: const EdgeInsets.only(bottom: 13), child: _clayCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 128, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: pieces.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, itemIndex) => _itemThumb(pieces[itemIndex], width: 94))),
      const SizedBox(height: 13),
      _eyebrow('IDEA ${index + 1} · EVERYDAY'),
      Text(lookName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      const SizedBox(height: 4),
      Text(pieces.map((item) => item.color).join(' · '), style: const TextStyle(color: _muted, fontSize: 12)),
      Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () async { final key = _dateKey(DateTime.now()); _selectedDay = DateUtils.dateOnly(DateTime.now()); _data.looks[key] = PlannedLook(title: lookName, note: 'A ${pieces.map((piece) => piece.color).join(' and ')} pairing from your closet.', items: pieces.map((piece) => piece.id).toList()); await _persist(); setState(() => _tab = 0); }, icon: const Icon(Icons.check_circle_outline_rounded), label: const Text('Wear this today'))),
    ])));
  }

  Widget _colorsView() {
    final grouped = <String, List<ClothingItem>>{};
    for (final item in _data.items) { grouped.putIfAbsent(item.color, () => []).add(item); }
    return ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 104), children: [
      _eyebrow('NOTICE THE LITTLE PATTERNS'),
      const Text('Color notes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -.6)),
      const SizedBox(height: 14),
      _clayCard(child: Row(children: [const Icon(Icons.palette_rounded, color: _fern, size: 31), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Getting dressed in color.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text('${_data.looks.length} looks planned · ${_data.items.length} pieces in your palette', style: const TextStyle(color: _muted, fontSize: 12))]))])),
      const SizedBox(height: 14),
      for (final entry in grouped.entries) _clayCard(child: Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: _colorFromHex(entry.value.first.colorHex), shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6), BoxShadow(color: Color(0x22343C34), offset: Offset(3, 3), blurRadius: 6)])), const SizedBox(width: 12), Expanded(child: Text(entry.key[0].toUpperCase() + entry.key.substring(1), style: const TextStyle(fontWeight: FontWeight.w700))), Text('${entry.value.length} piece${entry.value.length == 1 ? '' : 's'}', style: const TextStyle(color: _muted, fontSize: 12))])),
      const SizedBox(height: 6),
      const Text('Try tonal layers, one bright accent, or a crisp contrast. Your closet is the color wheel.', style: TextStyle(color: _muted, height: 1.5)),
    ]);
  }

  Future<void> _showSettings() async {
    await showModalBottomSheet<void>(context: context, backgroundColor: Colors.transparent, builder: (context) => SafeArea(child: Container(padding: const EdgeInsets.all(22), decoration: const BoxDecoration(color: _paper, borderRadius: BorderRadius.vertical(top: Radius.circular(28))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Calendar settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 18),
      SwitchListTile(value: _data.settings['showLookNames'] as bool? ?? true, title: const Text('Show look names'), onChanged: (value) async { _data.settings['showLookNames'] = value; await _persist(); if (context.mounted) Navigator.pop(context); }),
      ListTile(title: const Text('Week begins on'), trailing: SegmentedButton<int>(segments: const [ButtonSegment(value: 0, label: Text('Sun')), ButtonSegment(value: 1, label: Text('Mon'))], selected: {_data.settings['weekStarts'] as int? ?? 0}, onSelectionChanged: (value) async { _data.settings['weekStarts'] = value.first; await _persist(); if (context.mounted) Navigator.pop(context); })),
    ]))));
  }

  Widget _heroLookImage(List<ClothingItem> items) {
    final hero = items.firstWhere((item) => item.category == 'Dress' || item.category == 'Top', orElse: () => items.first);
    return SizedBox(height: 185, width: double.infinity, child: Stack(fit: StackFit.expand, children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: _image(hero.image, fit: BoxFit.cover, colorHex: hero.colorHex)), DecoratedBox(decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x99000000)]))), Positioned(left: 17, bottom: 15, child: Text(_todayLook?.title ?? '', style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)))]));
  }

  Widget _colorStory(List<ClothingItem> pieces) {
    final score = pieces.length < 2 ? 0 : (100 - pieces.map((piece) => _colorDistance(piece.colorHex, pieces.first.colorHex)).reduce((a, b) => a + b) ~/ pieces.length).clamp(0, 100);
    return Row(children: [const Expanded(child: Text('Color story', style: TextStyle(fontWeight: FontWeight.w700))), Text('$score% together', style: const TextStyle(color: _fern, fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(width: 6), ...pieces.take(4).map((item) => Padding(padding: const EdgeInsets.only(left: 4), child: Container(width: 14, height: 14, decoration: BoxDecoration(color: _colorFromHex(item.colorHex), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)) ))]);
  }

  int _colorDistance(String left, String right) {
    final a = _colorFromHex(left), b = _colorFromHex(right);
    return ((a.red - b.red).abs() + (a.green - b.green).abs() + (a.blue - b.blue).abs()) ~/ 3 ~/ 3;
  }

  Widget _itemThumb(ClothingItem item, {double width = 84}) => SizedBox(width: width, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(width: width, child: _image(item.image, fit: BoxFit.cover, colorHex: item.colorHex)))), const SizedBox(height: 4), Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))]));

  Widget _image(String url, {BoxFit fit = BoxFit.cover, String colorHex = '#E5E9E1'}) {
    final fallback = Container(color: _colorFromHex(colorHex), child: const Center(child: Icon(Icons.checkroom_rounded, color: Colors.white70, size: 31)));
    if (url.isEmpty) return fallback;
    return Image.network(url, fit: fit, errorBuilder: (_, __, ___) => fallback, loadingBuilder: (context, child, progress) => progress == null ? child : fallback);
  }

  Widget _clayCard({required Widget child, EdgeInsets padding = const EdgeInsets.all(16)}) => Card(child: Padding(padding: padding, child: child));
  Widget _eyebrow(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)));
  Widget _glassPill(String text) => ClipRRect(borderRadius: BorderRadius.circular(12), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), color: Colors.white.withValues(alpha: .78), child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)))));

  Color _colorFromHex(String hex) {
    final normalized = hex.replaceAll('#', '');
    final value = normalized.length == 6 ? 'FF$normalized' : normalized;
    return Color(int.tryParse(value, radix: 16) ?? 0xFF59745C);
  }
}

class OutfitComposer extends StatefulWidget {
  const OutfitComposer({super.key, required this.items, this.initial});
  final List<ClothingItem> items;
  final PlannedLook? initial;

  @override
  State<OutfitComposer> createState() => _OutfitComposerState();
}

class _OutfitComposerState extends State<OutfitComposer> {
  late final TextEditingController _title;
  late final TextEditingController _note;
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _note = TextEditingController(text: widget.initial?.note ?? '');
    _selected = {...?widget.initial?.items};
  }

  @override
  void dispose() { _title.dispose(); _note.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final selectedItems = widget.items.where((item) => _selected.contains(item.id)).toList();
    return Container(
      height: MediaQuery.sizeOf(context).height * .92,
      padding: EdgeInsets.fromLTRB(18, 10, 18, MediaQuery.viewInsetsOf(context).bottom + 12),
      decoration: const BoxDecoration(color: _paper, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(children: [
        Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: const Color(0xFFC7CEC5), borderRadius: BorderRadius.circular(4))),
        Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_eyebrowLocal('LIVE OUTFIT PREVIEW'), Text(_title.text.isEmpty ? 'Build a look' : _title.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))])), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))]),
        TextField(controller: _title, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Look name', hintText: 'e.g. Soft Sunday layers', prefixIcon: Icon(Icons.edit_outlined))),
        const SizedBox(height: 9),
        TextField(controller: _note, decoration: const InputDecoration(labelText: 'A note for later', prefixIcon: Icon(Icons.notes_rounded))),
        const SizedBox(height: 13),
        _preview(selectedItems),
        const SizedBox(height: 8),
        Row(children: [const Expanded(child: Text('Pick your pieces', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))), Text('${_selected.length} selected', style: const TextStyle(color: _muted, fontSize: 12))]),
        const SizedBox(height: 5),
        Expanded(child: Scrollbar(child: ListView.separated(itemCount: widget.items.length, separatorBuilder: (_, __) => const SizedBox(height: 5), itemBuilder: (context, index) {
          final item = widget.items[index];
          final chosen = _selected.contains(item.id);
          return Card(color: chosen ? const Color(0xFFE4EDE3) : Colors.white.withValues(alpha: .76), child: ListTile(
            onTap: () => setState(() => chosen ? _selected.remove(item.id) : _selected.add(item.id)),
            leading: ClipRRect(borderRadius: BorderRadius.circular(9), child: SizedBox(width: 42, height: 48, child: _clothingImage(item))),
            title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text('${item.category} · ${item.color}', style: const TextStyle(fontSize: 11)),
            trailing: Icon(chosen ? Icons.check_circle_rounded : Icons.circle_outlined, color: chosen ? _fern : _muted),
          ));
        }))),
        const SizedBox(height: 9),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, PlannedLook(title: _title.text.trim().isEmpty ? 'A new look' : _title.text.trim(), note: _note.text.trim(), items: _selected.toList())), icon: const Icon(Icons.check_rounded), label: const Text('Save look'))),
      ]),
    );
  }

  Widget _preview(List<ClothingItem> items) {
    if (items.isEmpty) return Container(height: 118, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFE9ECE5), borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 9), BoxShadow(color: Color(0x22353E35), offset: Offset(4, 4), blurRadius: 9)]), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.checkroom_rounded, color: _fern), SizedBox(width: 8), Text('Tap pieces below to preview your look', style: TextStyle(color: _muted, fontSize: 12))]));
    return Container(height: 132, width: double.infinity, padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: const Color(0xFFE9ECE5), borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 9), BoxShadow(color: Color(0x22353E35), offset: Offset(4, 4), blurRadius: 9)]), child: Row(children: [for (final item in items.take(4)) Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Stack(fit: StackFit.expand, children: [_clothingImage(item), Align(alignment: Alignment.bottomCenter, child: ClipRRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Container(width: double.infinity, color: Colors.white.withValues(alpha: .78), padding: const EdgeInsets.symmetric(vertical: 5), child: Text(item.category, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700))))))])))]));
  }

  Widget _clothingImage(ClothingItem item) {
    final fallback = Container(color: _hex(item.colorHex), child: const Center(child: Icon(Icons.checkroom_rounded, color: Colors.white)));
    if (item.image.isEmpty) return fallback;
    return Image.network(item.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback);
  }
}

class AddClothingSheet extends StatefulWidget {
  const AddClothingSheet({super.key});
  @override
  State<AddClothingSheet> createState() => _AddClothingSheetState();
}

class _AddClothingSheetState extends State<AddClothingSheet> {
  final _name = TextEditingController();
  final _image = TextEditingController();
  String _category = 'Top';
  String _color = 'sage';
  String _hex = '#789078';
  static const colors = {'sage': '#789078', 'cream': '#D9CDB8', 'denim': '#617C91', 'rose': '#C18484', 'navy': '#34475B', 'red': '#AC5B4C'};
  @override
  void dispose() { _name.dispose(); _image.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Container(height: MediaQuery.sizeOf(context).height * .78, padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.viewInsetsOf(context).bottom + 18), decoration: const BoxDecoration(color: _paper, borderRadius: BorderRadius.vertical(top: Radius.circular(28))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFC7CEC5), borderRadius: BorderRadius.circular(4)))),
    const SizedBox(height: 17), const Text('Add a piece', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)), const SizedBox(height: 15),
    Expanded(child: ListView(children: [
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Piece name', hintText: 'e.g. Cropped denim jacket')),
      const SizedBox(height: 12), DropdownButtonFormField<String>(value: _category, decoration: const InputDecoration(labelText: 'Category'), items: ['Top', 'Bottom', 'Dress', 'Layer', 'Shoes', 'Accessory'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => setState(() => _category = value ?? 'Top')),
      const SizedBox(height: 12), DropdownButtonFormField<String>(value: _color, decoration: const InputDecoration(labelText: 'Color'), items: colors.keys.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => setState(() { _color = value ?? 'sage'; _hex = colors[_color]!; })),
      const SizedBox(height: 12), TextField(controller: _image, decoration: const InputDecoration(labelText: 'Photo URL (optional)', hintText: 'https://…')),
    ])),
    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { if (_name.text.trim().isEmpty) return; Navigator.pop(context, ClothingItem(id: 'item-${DateTime.now().microsecondsSinceEpoch}', name: _name.text.trim(), category: _category, color: _color, colorHex: _hex, image: _image.text.trim())); }, icon: const Icon(Icons.add_rounded), label: const Text('Add to closet'))),
  ]));
}

Widget _eyebrowLocal(String text) => Text(text, style: const TextStyle(color: _muted, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1.1));
Color _hex(String value) { final hex = value.replaceAll('#', ''); return Color(int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16) ?? 0xFF58735D); }
