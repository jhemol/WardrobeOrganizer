import 'package:flutter_test/flutter_test.dart';
import 'package:thread_wardrobe/wardrobe_models.dart';

void main() {
  test('wardrobe data round-trips through the API JSON shape', () {
    final original = WardrobeData(
      items: const [
        ClothingItem(
          id: 'top-1',
          name: 'Linen shirt',
          category: 'Top',
          color: 'cream',
          colorHex: '#D9CDB8',
          image: 'https://example.test/shirt.jpg',
        ),
      ],
      looks: {
        '2026-09-30': const PlannedLook(
          title: 'Easy layers',
          items: ['top-1'],
          note: 'Light and easy',
        ),
      },
    );

    final decoded = WardrobeData.decode(original.encode());
    expect(decoded.items.single.name, 'Linen shirt');
    expect(decoded.looks['2026-09-30']?.items, ['top-1']);
    expect(decoded.looks['2026-09-30']?.note, 'Light and easy');
  });
}
