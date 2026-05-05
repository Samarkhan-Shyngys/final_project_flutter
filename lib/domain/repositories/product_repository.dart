import '../entities/product.dart';

abstract class ProductRepository {
  /// Загружает список продуктов с удалённого API.
  /// Возвращает [List<Product>] или бросает исключение при ошибке сети.
  Future<List<Product>> fetchProducts();
}
