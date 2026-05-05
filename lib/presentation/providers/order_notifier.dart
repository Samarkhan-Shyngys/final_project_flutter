import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/entities/order_status.dart';

class OrderState {
  final List<OrderEntity> orders;

  const OrderState({this.orders = const []});

  List<OrderEntity> ordersForKindergartens(List<String> ids) {
    if (ids.isEmpty) return [];
    return orders
        .where((o) => o.kindergartenId != null && ids.contains(o.kindergartenId))
        .toList();
  }

  OrderEntity? getById(String id) {
    try {
      return orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  static const _boxName = 'orders';
  late Box _box;

  OrderNotifier() : super(const OrderState());

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);

    if (_box.isNotEmpty) {
      final firstVal = Map<String, dynamic>.from(_box.values.first as Map);
      if (!firstVal.containsKey('kindergartenId')) {
        await _box.clear();
        _seed();
      }
    } else {
      _seed();
    }

    _load();
  }

  void _load() {
    final orders = _box.values
        .map((v) => OrderEntity.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    state = OrderState(orders: orders);
  }

  Future<String> createOrder({
    required String kindergartenId,
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
      id: id, status: OrderStatus.inProgress, date: date,
      kindergartenId: kindergartenId, kindergartenName: kindergartenName,
      address: address, phone: phone, managerName: managerName, items: items,
    );
    await _box.put(id, order.toMap());
    _load();
    return id;
  }

  Future<void> updateStatus(String id, OrderStatus status) async {
    final existing = state.getById(id);
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
      const OrderEntity(id: '2847', status: OrderStatus.inDelivery, date: '14.03.2024',
        kindergartenId: 'kg_1', kindergartenName: 'Детский сад №45 «Ромашка»', address: 'ул. Ленина 12',
        phone: '+7 727 111-11-11', managerName: 'Алина Иванова',
        items: [
          OrderItemEntity(name: 'Картофель', quantity: 20, unit: 'кг', price: 225),
          OrderItemEntity(name: 'Морковь', quantity: 10, unit: 'кг', price: 190),
          OrderItemEntity(name: 'Яблоки', quantity: 15, unit: 'кг', price: 325),
          OrderItemEntity(name: 'Мыло хозяйственное', quantity: 6, unit: 'шт', price: 125),
        ]),
      const OrderEntity(id: '2846', status: OrderStatus.inProgress, date: '14.03.2024',
        kindergartenId: 'kg_3', kindergartenName: 'Детский сад №12 «Берёзка»', address: 'ул. Ленина 45',
        phone: '+7 727 333-33-33', managerName: 'Алина Иванова',
        items: [
          OrderItemEntity(name: 'Капуста белокочанная', quantity: 30, unit: 'кг', price: 160),
          OrderItemEntity(name: 'Свёкла', quantity: 20, unit: 'кг', price: 175),
          OrderItemEntity(name: 'Бананы', quantity: 25, unit: 'кг', price: 360),
        ]),
      const OrderEntity(id: '2845', status: OrderStatus.delivered, date: '13.03.2024',
        kindergartenId: 'kg_2', kindergartenName: 'Детский сад №7 «Солнышко»', address: 'ул. Пушкина 12',
        phone: '+7 727 222-22-22', managerName: 'Алина Иванова',
        items: [
          OrderItemEntity(name: 'Лук репчатый', quantity: 12, unit: 'кг', price: 145),
          OrderItemEntity(name: 'Апельсины', quantity: 20, unit: 'кг', price: 475),
        ]),
      const OrderEntity(id: '2831', status: OrderStatus.delivered, date: '12.03.2024',
        kindergartenId: 'kg_1', kindergartenName: 'Детский сад №45 «Ромашка»', address: 'ул. Ленина 12',
        phone: '+7 727 111-11-11', managerName: 'Алина Иванова',
        items: [
          OrderItemEntity(name: 'Капуста белокочанная', quantity: 15, unit: 'кг', price: 160),
          OrderItemEntity(name: 'Лук репчатый', quantity: 8, unit: 'кг', price: 145),
          OrderItemEntity(name: 'Бананы', quantity: 12, unit: 'кг', price: 360),
        ]),
      const OrderEntity(id: '2818', status: OrderStatus.inProgress, date: '10.03.2024',
        kindergartenId: 'kg_1', kindergartenName: 'Детский сад №45 «Ромашка»', address: 'ул. Ленина 12',
        phone: '+7 727 111-11-11', managerName: 'Алина Иванова',
        items: [
          OrderItemEntity(name: 'Картофель', quantity: 25, unit: 'кг', price: 225),
          OrderItemEntity(name: 'Свёкла', quantity: 10, unit: 'кг', price: 175),
          OrderItemEntity(name: 'Огурцы тепличные', quantity: 8, unit: 'кг', price: 425),
          OrderItemEntity(name: 'Средство для посуды', quantity: 3, unit: 'л', price: 600),
          OrderItemEntity(name: 'Перчатки латексные', quantity: 10, unit: 'пара', price: 225),
        ]),
    ];
    for (final o in seedOrders) {
      _box.put(o.id, o.toMap());
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>(
  (ref) => OrderNotifier(),
);
