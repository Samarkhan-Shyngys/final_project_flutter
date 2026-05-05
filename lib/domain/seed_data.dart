import 'entities/app_user.dart';
import 'entities/kindergarten.dart';
import 'entities/user_role.dart';

final kSeedUsers = <AppUser>[
  AppUser(
    id: 'superadmin_1',
    name: 'Суперадминистратор',
    email: 'superadmin@zakupai.kz',
    password: 'super123',
    role: UserRole.superAdmin,
    kindergartenIds: [],
    createdAt: DateTime(2024, 1, 1),
  ),
  AppUser(
    id: 'admin_1',
    name: 'Арман Сейткали',
    email: 'admin@zakupai.kz',
    password: 'admin123',
    role: UserRole.admin,
    kindergartenIds: [],
    createdByAdminId: 'superadmin_1',
    createdAt: DateTime(2024, 1, 2),
  ),
  AppUser(
    id: 'manager_1',
    name: 'Алина Иванова',
    email: 'manager@zakupai.kz',
    password: 'manager123',
    role: UserRole.manager,
    kindergartenIds: ['kg_1'],
    createdByAdminId: 'admin_1',
    createdAt: DateTime(2024, 1, 3),
  ),
  AppUser(
    id: 'courier_1',
    name: 'Александр Курьеров',
    email: 'courier@zakupai.kz',
    password: 'courier123',
    role: UserRole.courier,
    kindergartenIds: ['kg_1', 'kg_2', 'kg_3'],
    createdByAdminId: 'admin_1',
    createdAt: DateTime(2024, 1, 4),
  ),
];

final kSeedKindergartens = <Kindergarten>[
  Kindergarten(
    id: 'kg_1',
    name: 'Детский сад №45 «Ромашка»',
    address: 'ул. Ленина 12, Алматы',
    phone: '+7 727 111-11-11',
    adminId: 'admin_1',
    createdAt: DateTime(2024, 1, 2),
  ),
  Kindergarten(
    id: 'kg_2',
    name: 'Детский сад №7 «Солнышко»',
    address: 'ул. Пушкина 12, Алматы',
    phone: '+7 727 222-22-22',
    adminId: 'admin_1',
    createdAt: DateTime(2024, 1, 2),
  ),
  Kindergarten(
    id: 'kg_3',
    name: 'Детский сад №12 «Берёзка»',
    address: 'ул. Ленина 45, Алматы',
    phone: '+7 727 333-33-33',
    adminId: 'admin_1',
    createdAt: DateTime(2024, 1, 2),
  ),
];
