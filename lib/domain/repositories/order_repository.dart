import '../entities/order_entity.dart';
import '../entities/order_item_entity.dart';
import '../entities/order_status.dart';

abstract class OrderRepository {
  Future<void> init();
  List<OrderEntity> getAll();
  OrderEntity? getById(String id);
  Future<String> createOrder({
    required String kindergartenId,
    required String kindergartenName,
    required String address,
    required String phone,
    required String managerName,
    required List<OrderItemEntity> items,
  });
  Future<void> updateStatus(String id, OrderStatus status);
  Future<void> deleteOrder(String id);
}
