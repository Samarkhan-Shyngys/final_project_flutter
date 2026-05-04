import 'package:flutter/material.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [
    CartItem(id:'p1',  name:'Картофель',            unit:'кг',  price:45,  quantity:20, category:'vegetables'),
    CartItem(id:'p3',  name:'Капуста белокочанная', unit:'кг',  price:32,  quantity:15, category:'vegetables'),
    CartItem(id:'p7',  name:'Яблоки',               unit:'кг',  price:65,  quantity:10, category:'fruits'),
    CartItem(id:'p11', name:'Мыло хозяйственное',   unit:'шт',  price:25,  quantity:6,  category:'supplies'),
  ];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (s, i) => s + i.quantity);

  double get totalPrice => _items.fold(0.0, (s, i) => s + i.price * i.quantity);

  void addItem(Product p) {
    final idx = _items.indexWhere((e) => e.id == p.id);
    if (idx >= 0) {
      _items[idx].quantity += p.minOrder;
    } else {
      _items.add(CartItem(
        id: p.id,
        name: p.name,
        unit: p.unit,
        price: p.price,
        quantity: p.minOrder,
        category: p.category,
      ));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void updateQuantity(String id, int qty) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      if (qty <= 0) {
        _items.removeAt(idx);
      } else {
        _items[idx].quantity = qty;
      }
    }
    notifyListeners();
  }

  int getQuantity(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    return idx >= 0 ? _items[idx].quantity : 0;
  }

  void clear() {
    _items = [];
    notifyListeners();
  }
}
