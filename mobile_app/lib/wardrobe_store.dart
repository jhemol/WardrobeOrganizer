import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'wardrobe_models.dart';

class WardrobeStore {
  WardrobeStore({String? apiBaseUrl}) : apiBaseUrl = (apiBaseUrl ?? const String.fromEnvironment('WARDROBE_API_URL')).trim();

  static const _storageKey = 'thread-wardrobe-native-v1';
  final String apiBaseUrl;

  Future<WardrobeData> load() async {
    final preferences = await SharedPreferences.getInstance();
    final cached = preferences.getString(_storageKey);
    WardrobeData? local;
    if (cached != null) {
      try {
        local = WardrobeData.decode(cached);
      } on FormatException {
        await preferences.remove(_storageKey);
      }
    }

    if (apiBaseUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse('$apiBaseUrl/api/state')).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> && decoded['items'] is List && (decoded['items'] as List).isNotEmpty) {
            final data = WardrobeData.fromJson(decoded);
            await preferences.setString(_storageKey, data.encode());
            return data;
          }
        }
      } catch (_) {
        // Keep the native app usable offline or when the API is unreachable.
      }
    }

    return local ?? WardrobeData();
  }

  Future<void> save(WardrobeData data) async {
    final encoded = data.encode();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, encoded);
    if (apiBaseUrl.isEmpty) return;

    try {
      await http
          .put(
            Uri.parse('$apiBaseUrl/api/state'),
            headers: {'content-type': 'application/json'},
            body: encoded,
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Local persistence remains the source of truth while offline.
    }
  }
}
