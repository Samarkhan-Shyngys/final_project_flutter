import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository repository;
  const GetOrdersUseCase(this.repository);

  List<OrderEntity> call({List<String> kindergartenIds = const []}) {
    final all = repository.getAll();
    if (kindergartenIds.isEmpty) return all;
    return all
        .where((o) => o.kindergartenId != null && kindergartenIds.contains(o.kindergartenId))
        .toList();
  }
}
