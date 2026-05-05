import 'user_role.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final List<String> kindergartenIds;
  final String? createdByAdminId;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.kindergartenIds = const [],
    this.createdByAdminId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'role': role.name,
    'kindergartenIds': kindergartenIds,
    'createdByAdminId': createdByAdminId,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    id: m['id'] as String,
    name: m['name'] as String,
    email: m['email'] as String,
    password: m['password'] as String,
    role: UserRole.values.firstWhere((r) => r.name == m['role']),
    kindergartenIds: List<String>.from(m['kindergartenIds'] as List? ?? []),
    createdByAdminId: m['createdByAdminId'] as String?,
    createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
  );
}
