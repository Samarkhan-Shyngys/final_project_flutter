class CartItem {
  final String id;
  final String name;
  final String unit;
  final double price;
  final int quantity;
  final String category;

  CartItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.category,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'unit': unit,
    'price': price,
    'quantity': quantity,
    'category': category,
  };

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
    id: m['id'] as String,
    name: m['name'] as String,
    unit: m['unit'] as String,
    price: (m['price'] as num).toDouble(),
    quantity: (m['quantity'] as num).toInt(),
    category: m['category'] as String,
  );
}
