import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItems => items.fold(0, (s, i) => s + i.quantity);
  double get totalPrice => items.fold(0.0, (s, i) => s + i.price * i.quantity);

  int getQuantity(String id) {
    try {
      return items.firstWhere((i) => i.id == id).quantity;
    } catch (_) {
      return 0;
    }
  }
}

class CartNotifier extends StateNotifier<CartState> {
  static const _boxName = 'cart';
  late Box _box;

  CartNotifier() : super(const CartState());

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _load();
  }

  void _load() {
    final items = _box.values
        .map((v) => CartItem.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList();
    state = CartState(items: items);
  }

  void _save(List<CartItem> items) {
    _box.clear();
    for (final item in items) {
      _box.put(item.id, item.toMap());
    }
  }

  void addItem(Product p) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((e) => e.id == p.id);
    if (idx >= 0) {
      final old = items[idx];
      items[idx] = CartItem(
        id: old.id, name: old.name, unit: old.unit,
        price: old.price, category: old.category,
        quantity: old.quantity + p.minOrder,
      );
    } else {
      items.add(CartItem(
        id: p.id, name: p.name, unit: p.unit,
        price: p.price, category: p.category,
        quantity: p.minOrder,
      ));
    }
    state = CartState(items: items);
    _save(items);
  }

  void removeItem(String id) {
    final items = state.items.where((e) => e.id != id).toList();
    state = CartState(items: items);
    _save(items);
  }

  void updateQuantity(String id, int qty) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    if (qty <= 0) {
      items.removeAt(idx);
    } else {
      final old = items[idx];
      items[idx] = CartItem(
        id: old.id, name: old.name, unit: old.unit,
        price: old.price, category: old.category, quantity: qty,
      );
    }
    state = CartState(items: items);
    _save(items);
  }

  void clear() {
    _box.clear();
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
