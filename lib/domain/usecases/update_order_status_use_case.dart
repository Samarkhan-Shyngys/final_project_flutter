import '../entities/order_status.dart';
import '../repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository repository;
  const UpdateOrderStatusUseCase(this.repository);

  Future<void> call({required String orderId, required OrderStatus status}) {
    return repository.updateStatus(orderId, status);
  }
}
