class OrderItemEntity {
  final String name;
  final int quantity;
  final String unit;
  final double price;

  const OrderItemEntity({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'price': price,
  };

  factory OrderItemEntity.fromMap(Map<String, dynamic> m) => OrderItemEntity(
    name: m['name'] as String,
    quantity: (m['quantity'] as num).toInt(),
    unit: m['unit'] as String,
    price: (m['price'] as num).toDouble(),
  );
}
