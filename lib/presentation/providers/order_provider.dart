import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/entities/order_status.dart';

class OrderProvider extends ChangeNotifier {
  static const _boxName = 'orders';
  late Box _box;
  List<OrderEntity> _orders = [];

  List<OrderEntity> get orders => List.unmodifiable(_orders);

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    if (_box.isEmpty) _seed();
    _load();
  }

  void _load() {
    _orders = _box.values
        .map((v) => OrderEntity.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  OrderEntity? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<String> createOrder({
    required String kindergartenName,
    required String address,
    required String phone,
    required String managerName,
    required List<OrderItemEntity> items,
  }) async {
    final id = const Uuid().v4().substring(0, 4).toUpperCase();
    final now = DateTime.now();
    final date = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
    final order = OrderEntity(
      id: id,
      status: OrderStatus.inProgress,
      date: date,
      kindergartenName: kindergartenName,
      address: address,
      phone: phone,
      managerName: managerName,
      items: items,
    );
    await _box.put(id, order.toMap());
    _load();
    return id;
  }

  Future<void> updateStatus(String id, OrderStatus status) async {
    final existing = getById(id);
    if (existing == null) return;
    await _box.put(id, existing.copyWith(status: status).toMap());
    _load();
  }

  Future<void> deleteOrder(String id) async {
    await _box.delete(id);
    _load();
  }

  void _seed() {
    final seedOrders = [
      const OrderEntity(
        id: '2847', status: OrderStatus.inDelivery, date: '14.03.2024',
        kindergartenName: 'ДС №45 «Ромашка»', address: 'ул. Ленина 12',
        phone: '+7 727 123-45-67', managerName: 'Алина Иванова',
        items: [
          OrderItemEntity(name: 'Картофель', quantity: 20, unit: 'кг', price: 45),
          OrderItemEntity(name: 'Морковь', quantity: 10, unit: 'кг', price: 38),
          OrderItemEntity(name: 'Яблоки', quantity: 15, unit: 'кг', price: 65),
          OrderItemEntity(name: 'Мыло хозяйственное', quantity: 6, unit: 'шт', price: 25),
        ],
      ),
      const OrderEntity(
        id: '2846', status: OrderStatus.inProgress, date: '14.03.2024',
        kindergartenName: 'ДС №12 «Берёзка»', address: 'ул. Ленина 45',
        phone: '+7 777 123-45-67', managerName: 'Алина Иванова',
        items: [
          OrderItemEntity(name: 'Капуста белокочанная', quantity: 30, unit: 'кг', price: 32),
          OrderItemEntity(name: 'Свёкла', quantity: 20, unit: 'кг', price: 35),
          OrderItemEntity(name: 'Бананы', quantity: 25, unit: 'кг', price: 72),
        ],
      ),
      const OrderEntity(
        id: '2845', status: OrderStatus.delivered, date: '13.03.2024',
        kindergartenName: 'ДС №7 «Солнышко»', address: 'ул. Пушкина 12',
        phone: '+7 777 234-56-78', managerName: 'Алина Иванова',
        items: [
          OrderItemEntity(name: 'Лук репчатый', quantity: 12, unit: 'кг', price: 29),
          OrderItemEntity(name: 'Апельсины', quantity: 20, unit: 'кг', price: 95),
        ],
      ),
      const OrderEntity(
        id: '2831', status: OrderStatus.delivered, date: '12.03.2024',
        kindergartenName: 'ДС №45 «Ромашка»', address: 'ул. Ленина 12',
        phone: '+7 727 123-45-67', managerName: 'Алина Иванова',
        items: [
          OrderItemEntity(name: 'Капуста белокочанная', quantity: 15, unit: 'кг', price: 32),
          OrderItemEntity(name: 'Лук репчатый', quantity: 8, unit: 'кг', price: 29),
          OrderItemEntity(name: 'Бананы', quantity: 12, unit: 'кг', price: 72),
        ],
      ),
      const OrderEntity(
        id: '2818', status: OrderStatus.inProgress, date: '10.03.2024',
        kindergartenName: 'ДС №45 «Ромашка»', address: 'ул. Ленина 12',
        phone: '+7 727 123-45-67', managerName: 'Алина Иванова',
        items: [
          OrderItemEntity(name: 'Картофель', quantity: 25, unit: 'кг', price: 45),
          OrderItemEntity(name: 'Свёкла', quantity: 10, unit: 'кг', price: 35),
          OrderItemEntity(name: 'Огурцы тепличные', quantity: 8, unit: 'кг', price: 85),
          OrderItemEntity(name: 'Средство для посуды', quantity: 3, unit: 'л', price: 120),
          OrderItemEntity(name: 'Перчатки латексные', quantity: 10, unit: 'пара', price: 45),
        ],
      ),
      const OrderEntity(
        id: '2805', status: OrderStatus.delivered, date: '07.03.2024',
        kindergartenName: 'ДС №23 «Радуга»', address: 'ул. Гагарина 78',
        phone: '+7 777 345-67-89', managerName: 'Алина Иванова',
        items: [
          OrderItemEntity(name: 'Яблоки', quantity: 20, unit: 'кг', price: 65),
          OrderItemEntity(name: 'Груши', quantity: 15, unit: 'кг', price: 89),
          OrderItemEntity(name: 'Мыло хозяйственное', quantity: 10, unit: 'шт', price: 25),
        ],
      ),
    ];
    for (final o in seedOrders) {
      _box.put(o.id, o.toMap());
    }
  }
}
