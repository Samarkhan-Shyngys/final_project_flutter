import '../entities/order_item_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;
  const CreateOrderUseCase(this.repository);

  Future<String> call({
    required String kindergartenId,
    required String kindergartenName,
    required String address,
    required String phone,
    required String managerName,
    required List<OrderItemEntity> items,
  }) {
    return repository.createOrder(
      kindergartenId: kindergartenId,
      kindergartenName: kindergartenName,
      address: address,
      phone: phone,
      managerName: managerName,
      items: items,
    );
  }
}
