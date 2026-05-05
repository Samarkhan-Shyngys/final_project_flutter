import '../entities/cart_item.dart';
import '../entities/product.dart';

abstract class CartRepository {
  Future<void> init();
  List<CartItem> getItems();
  void addItem(Product product);
  void removeItem(String id);
  void updateQuantity(String id, int quantity);
  void clear();
}
