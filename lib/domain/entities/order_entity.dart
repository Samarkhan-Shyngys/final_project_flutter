import 'order_status.dart';
import 'order_item_entity.dart';

class OrderEntity {
  final String id;
  final OrderStatus status;
  final String date;
  final String kindergartenName;
  final String address;
  final String phone;
  final String managerName;
  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    required this.status,
    required this.date,
    required this.kindergartenName,
    required this.address,
    required this.phone,
    required this.managerName,
    required this.items,
  });

  double get total => items.fold(0.0, (s, i) => s + i.total);
  int get itemCount => items.length;

  OrderEntity copyWith({OrderStatus? status}) => OrderEntity(
    id: id,
    status: status ?? this.status,
    date: date,
    kindergartenName: kindergartenName,
    address: address,
    phone: phone,
    managerName: managerName,
    items: items,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'status': status.name,
    'date': date,
    'kindergartenName': kindergartenName,
    'address': address,
    'phone': phone,
    'managerName': managerName,
    'items': items.map((i) => i.toMap()).toList(),
  };

  factory OrderEntity.fromMap(Map<String, dynamic> m) => OrderEntity(
    id: m['id'] as String,
    status: OrderStatus.values.firstWhere((s) => s.name == m['status'], orElse: () => OrderStatus.draft),
    date: m['date'] as String,
    kindergartenName: m['kindergartenName'] as String,
    address: m['address'] as String,
    phone: m['phone'] as String,
    managerName: m['managerName'] as String,
    items: (m['items'] as List)
        .map((i) => OrderItemEntity.fromMap(Map<String, dynamic>.from(i as Map)))
        .toList(),
  );
}
