class Product {
  final String id;
  final String name;
  final String unit;
  final String category;
  final String emoji;
  final double price;
  final int minOrder;

  const Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.category,
    required this.emoji,
    required this.price,
    required this.minOrder,
  });
}
