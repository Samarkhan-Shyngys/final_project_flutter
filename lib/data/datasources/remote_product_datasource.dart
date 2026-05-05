import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/product.dart';

/// Маппинг title → эмодзи для известных продуктов
const _emojiMap = {
  'potato': '🥔', 'carrot': '🥕', 'cabbage': '🥦', 'onion': '🧅',
  'beet': '🟣', 'cucumber': '🥒', 'apple': '🍎', 'banana': '🍌',
  'orange': '🍊', 'pear': '🍐', 'corn': '🌽', 'broccoli': '🥦',
  'spinach': '🥬', 'tomato': '🍅', 'mushroom': '🍄',
};

class RemoteProductDataSource {
  static const _baseUrl = 'https://dummyjson.com';

  final http.Client _client;
  RemoteProductDataSource({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<Product>> fetchGroceries() async {
    final uri = Uri.parse('$_baseUrl/products/category/groceries?limit=15');
    final response = await _client.get(uri).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Превышено время ожидания'),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка сервера: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['products'] as List<dynamic>;

    return items.asMap().entries.map((entry) {
      final i = entry.key;
      final json = entry.value as Map<String, dynamic>;
      final title = (json['title'] as String).toLowerCase();
      final emoji = _emojiMap.entries
          .firstWhere(
            (e) => title.contains(e.key),
            orElse: () => const MapEntry('', '🛒'),
          )
          .value;

      return Product(
        id: 'api_${json['id']}',
        name: json['title'] as String,
        unit: 'шт',
        category: i < 5 ? 'vegetables' : i < 10 ? 'fruits' : 'supplies',
        emoji: emoji,
        price: (json['price'] as num).toDouble() * 5,
        minOrder: 1,
      );
    }).toList();
  }
}
