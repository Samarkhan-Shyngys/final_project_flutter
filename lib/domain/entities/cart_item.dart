class CartItem {
  final String id;
  final String name;
  final String unit;
  final double price;
  int quantity;
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
}
