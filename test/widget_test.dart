import 'package:flutter_test/flutter_test.dart';
import 'package:zakup_ai/domain/entities/order_status.dart';

void main() {
  test('OrderStatus label returns correct Russian text', () {
    expect(OrderStatus.draft.label, 'Черновик');
    expect(OrderStatus.inProgress.label, 'В работе');
    expect(OrderStatus.inDelivery.label, 'В доставке');
    expect(OrderStatus.delivered.label, 'Выполнен');
  });
}
