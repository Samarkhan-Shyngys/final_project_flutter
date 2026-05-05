import 'package:flutter_test/flutter_test.dart';
import 'package:zakup_ai/domain/entities/app_user.dart';
import 'package:zakup_ai/domain/entities/kindergarten.dart';
import 'package:zakup_ai/domain/entities/order_entity.dart';
import 'package:zakup_ai/domain/entities/order_item_entity.dart';
import 'package:zakup_ai/domain/entities/order_status.dart';
import 'package:zakup_ai/domain/entities/user_role.dart';
import 'package:zakup_ai/domain/repositories/auth_repository.dart';
import 'package:zakup_ai/domain/repositories/order_repository.dart';
import 'package:zakup_ai/domain/usecases/login_use_case.dart';
import 'package:zakup_ai/domain/usecases/logout_use_case.dart';
import 'package:zakup_ai/domain/usecases/get_orders_use_case.dart';
import 'package:zakup_ai/domain/usecases/create_order_use_case.dart';
import 'package:zakup_ai/domain/usecases/update_order_status_use_case.dart';

// ─── Fake AuthRepository ──────────────────────────────────────────────────────
class FakeAuthRepository implements AuthRepository {
  final List<AppUser> _users = [
    AppUser(
      id: 'u1', name: 'Admin', email: 'admin@test.com',
      password: 'pass123', role: UserRole.admin,
      createdAt: DateTime(2024),
    ),
  ];
  AppUser? _currentUser;

  @override Future<void> init() async {}
  @override AppUser? get currentUser => _currentUser;
  @override List<AppUser> get allUsers => _users;
  @override List<Kindergarten> get allKindergartens => [];

  @override
  Future<bool> login(String email, String password) async {
    final user = _users.cast<AppUser?>().firstWhere(
      (u) => u!.email == email && u.password == password,
      orElse: () => null,
    );
    _currentUser = user;
    return user != null;
  }

  @override Future<void> logout() async { _currentUser = null; }

  @override Future<void> register({required String name, required String email, required String password}) async {}
  @override Future<AppUser> createAdmin({required String name, required String email, required String password}) async => _users.first;
  @override Future<AppUser> createManager({required String name, required String email, required String password, required String kindergartenId}) async => _users.first;
  @override Future<AppUser> createCourier({required String name, required String email, required String password, List<String> kindergartenIds = const []}) async => _users.first;
  @override Future<Kindergarten> createKindergarten({required String name, required String address, required String phone}) async => Kindergarten(id: 'kg1', name: name, address: address, phone: phone, adminId: 'u1', createdAt: DateTime(2024));
  @override Future<void> deleteUser(String userId) async {}
  @override Future<void> deleteKindergarten(String kgId) async {}
}

// ─── Fake OrderRepository ─────────────────────────────────────────────────────
class FakeOrderRepository implements OrderRepository {
  final List<OrderEntity> _orders = [
    const OrderEntity(
      id: 'ORD1', status: OrderStatus.inProgress, date: '01.05.2024',
      kindergartenId: 'kg1', kindergartenName: 'ДС №1', address: 'ул. Ленина 1',
      phone: '+7 777 111-11-11', managerName: 'Менеджер',
      items: [OrderItemEntity(name: 'Картофель', quantity: 10, unit: 'кг', price: 225)],
    ),
    const OrderEntity(
      id: 'ORD2', status: OrderStatus.delivered, date: '02.05.2024',
      kindergartenId: 'kg2', kindergartenName: 'ДС №2', address: 'ул. Пушкина 2',
      phone: '+7 777 222-22-22', managerName: 'Менеджер',
      items: [OrderItemEntity(name: 'Яблоки', quantity: 5, unit: 'кг', price: 325)],
    ),
  ];

  @override Future<void> init() async {}
  @override List<OrderEntity> getAll() => List.unmodifiable(_orders);
  @override OrderEntity? getById(String id) => _orders.cast<OrderEntity?>().firstWhere((o) => o!.id == id, orElse: () => null);

  @override
  Future<String> createOrder({
    required String kindergartenId, required String kindergartenName,
    required String address, required String phone, required String managerName,
    required List<OrderItemEntity> items,
  }) async {
    const newId = 'ORD3';
    _orders.add(OrderEntity(
      id: newId, status: OrderStatus.inProgress, date: '03.05.2024',
      kindergartenId: kindergartenId, kindergartenName: kindergartenName,
      address: address, phone: phone, managerName: managerName, items: items,
    ));
    return newId;
  }

  @override
  Future<void> updateStatus(String id, OrderStatus status) async {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      _orders[idx] = _orders[idx].copyWith(status: status);
    }
  }

  @override Future<void> deleteOrder(String id) async { _orders.removeWhere((o) => o.id == id); }
}

// ─── Tests ────────────────────────────────────────────────────────────────────
void main() {
  group('LoginUseCase', () {
    test('возвращает true при правильных credentials', () async {
      final repo = FakeAuthRepository();
      final useCase = LoginUseCase(repo);
      final result = await useCase(email: 'admin@test.com', password: 'pass123');
      expect(result, isTrue);
      expect(repo.currentUser, isNotNull);
      expect(repo.currentUser!.email, 'admin@test.com');
    });

    test('возвращает false при неверном пароле', () async {
      final repo = FakeAuthRepository();
      final useCase = LoginUseCase(repo);
      final result = await useCase(email: 'admin@test.com', password: 'wrong');
      expect(result, isFalse);
      expect(repo.currentUser, isNull);
    });
  });

  group('LogoutUseCase', () {
    test('сбрасывает текущего пользователя', () async {
      final repo = FakeAuthRepository();
      await repo.login('admin@test.com', 'pass123');
      expect(repo.currentUser, isNotNull);

      final useCase = LogoutUseCase(repo);
      await useCase();
      expect(repo.currentUser, isNull);
    });
  });

  group('GetOrdersUseCase', () {
    test('возвращает все заказы без фильтра', () {
      final repo = FakeOrderRepository();
      final useCase = GetOrdersUseCase(repo);
      final orders = useCase();
      expect(orders.length, 2);
    });

    test('фильтрует заказы по kindergartenIds', () {
      final repo = FakeOrderRepository();
      final useCase = GetOrdersUseCase(repo);
      final orders = useCase(kindergartenIds: ['kg1']);
      expect(orders.length, 1);
      expect(orders.first.id, 'ORD1');
    });

    test('возвращает пустой список если kindergartenIds не совпадают', () {
      final repo = FakeOrderRepository();
      final useCase = GetOrdersUseCase(repo);
      final orders = useCase(kindergartenIds: ['kg999']);
      expect(orders, isEmpty);
    });
  });

  group('CreateOrderUseCase', () {
    test('создаёт новый заказ и возвращает ID', () async {
      final repo = FakeOrderRepository();
      final useCase = CreateOrderUseCase(repo);
      final id = await useCase(
        kindergartenId: 'kg1', kindergartenName: 'ДС №1',
        address: 'ул. Ленина 1', phone: '+7 777 111-11-11',
        managerName: 'Тест',
        items: [const OrderItemEntity(name: 'Морковь', quantity: 5, unit: 'кг', price: 190)],
      );
      expect(id, isNotEmpty);
      expect(repo.getAll().length, 3);
    });
  });

  group('UpdateOrderStatusUseCase', () {
    test('обновляет статус заказа на delivered', () async {
      final repo = FakeOrderRepository();
      final useCase = UpdateOrderStatusUseCase(repo);
      await useCase(orderId: 'ORD1', status: OrderStatus.delivered);
      final order = repo.getById('ORD1');
      expect(order?.status, OrderStatus.delivered);
    });

    test('не падает если заказ не найден', () async {
      final repo = FakeOrderRepository();
      final useCase = UpdateOrderStatusUseCase(repo);
      await expectAsync0(() => useCase(orderId: 'NONEXISTENT', status: OrderStatus.delivered));
    });
  });
}
