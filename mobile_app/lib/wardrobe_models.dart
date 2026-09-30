import 'dart:convert';

class ClothingItem {
  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.colorHex,
    required this.image,
    this.season = 'All season',
  });

  final String id;
  final String name;
  final String category;
  final String color;
  final String colorHex;
  final String image;
  final String season;

  factory ClothingItem.fromJson(Map<String, dynamic> json) => ClothingItem(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Untitled piece',
        category: json['category'] as String? ?? 'Top',
        color: json['color'] as String? ?? 'custom',
        colorHex: json['colorHex'] as String? ?? '#59745C',
        image: json['image'] as String? ?? '',
        season: json['season'] as String? ?? 'All season',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'color': color,
        'colorHex': colorHex,
        'image': image,
        'season': season,
      };
}

class PlannedLook {
  const PlannedLook({required this.title, required this.items, this.note = ''});

  final String title;
  final List<String> items;
  final String note;

  factory PlannedLook.fromJson(Map<String, dynamic> json) => PlannedLook(
        title: json['title'] as String? ?? 'A new look',
        items: (json['items'] as List<dynamic>? ?? const []).cast<String>(),
        note: json['note'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'title': title, 'items': items, 'note': note};
}

class WardrobeData {
  WardrobeData({
    List<ClothingItem>? items,
    Map<String, PlannedLook>? looks,
    Map<String, dynamic>? settings,
  })  : items = items ?? [],
        looks = looks ?? {},
        settings = settings ?? {'weekStarts': 0, 'showLookNames': true, 'accent': 'forest'};

  final List<ClothingItem> items;
  final Map<String, PlannedLook> looks;
  final Map<String, dynamic> settings;

  factory WardrobeData.fromJson(Map<String, dynamic> json) => WardrobeData(
        items: (json['items'] as List<dynamic>? ?? const [])
            .map((item) => ClothingItem.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList(),
        looks: (json['looks'] as Map<String, dynamic>? ?? const {}).map(
          (key, value) => MapEntry(key, PlannedLook.fromJson(Map<String, dynamic>.from(value as Map))),
        ),
        settings: Map<String, dynamic>.from(json['settings'] as Map? ?? const {}),
      );

  Map<String, dynamic> toJson() => {
        'items': items.map((item) => item.toJson()).toList(),
        'looks': looks.map((key, look) => MapEntry(key, look.toJson())),
        'settings': settings,
      };

  String encode() => jsonEncode(toJson());

  factory WardrobeData.decode(String value) => WardrobeData.fromJson(jsonDecode(value) as Map<String, dynamic>);
}
