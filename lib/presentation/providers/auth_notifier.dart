import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/kindergarten.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/seed_data.dart';

class AuthState {
  final AppUser? currentUser;
  final List<AppUser> users;
  final List<Kindergarten> kindergartens;

  const AuthState({
    this.currentUser,
    this.users = const [],
    this.kindergartens = const [],
  });

  bool get isLoggedIn => currentUser != null;
  String get name => currentUser?.name ?? '';
  String get email => currentUser?.email ?? '';
  String get role => currentUser?.role.name ?? '';

  List<Kindergarten> get myKindergartens {
    if (currentUser == null) return [];
    return kindergartens.where((kg) => kg.adminId == currentUser!.id).toList();
  }

  Kindergarten? kindergartenById(String id) =>
      kindergartens.cast<Kindergarten?>().firstWhere(
        (kg) => kg?.id == id,
        orElse: () => null,
      );

  List<AppUser> managersOf(String kgId) =>
      users.where((u) => u.role == UserRole.manager && u.kindergartenIds.contains(kgId)).toList();

  List<AppUser> couriersOf(String kgId) =>
      users.where((u) => u.role == UserRole.courier && u.kindergartenIds.contains(kgId)).toList();

  List<AppUser> get admins => users.where((u) => u.role == UserRole.admin).toList();
  List<Kindergarten> get allKindergartens => kindergartens;
  List<AppUser> get allUsers => users;

  AuthState copyWith({AppUser? currentUser, List<AppUser>? users, List<Kindergarten>? kindergartens, bool clearUser = false}) =>
      AuthState(
        currentUser: clearUser ? null : (currentUser ?? this.currentUser),
        users: users ?? this.users,
        kindergartens: kindergartens ?? this.kindergartens,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  static const _usersBoxName = 'users';
  static const _kgBoxName = 'kindergartens';
  static const _sessionKey = 'session_user_id';

  late Box _usersBox;
  late Box _kgBox;

  AuthNotifier() : super(const AuthState());

  Future<void> init() async {
    _usersBox = await Hive.openBox(_usersBoxName);
    _kgBox = await Hive.openBox(_kgBoxName);

    if (_usersBox.isEmpty) {
      for (final u in kSeedUsers) {
        await _usersBox.put(u.id, u.toMap());
      }
    }
    if (_kgBox.isEmpty) {
      for (final kg in kSeedKindergartens) {
        await _kgBox.put(kg.id, kg.toMap());
      }
    }

    final users = _readUsers();
    final kindergartens = _readKindergartens();

    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_sessionKey);
    AppUser? currentUser;
    if (savedId != null) {
      currentUser = users.cast<AppUser?>().firstWhere(
        (u) => u!.id == savedId,
        orElse: () => null,
      );
    }

    state = AuthState(currentUser: currentUser, users: users, kindergartens: kindergartens);
  }

  List<AppUser> _readUsers() => _usersBox.values
      .map((v) => AppUser.fromMap(Map<String, dynamic>.from(v as Map)))
      .toList();

  List<Kindergarten> _readKindergartens() => _kgBox.values
      .map((v) => Kindergarten.fromMap(Map<String, dynamic>.from(v as Map)))
      .toList();

  void _reload() {
    state = state.copyWith(users: _readUsers(), kindergartens: _readKindergartens());
  }

  Future<bool> login(String email, String password) async {
    final user = state.users.cast<AppUser?>().firstWhere(
      (u) => u!.email == email.trim() && u.password == password,
      orElse: () => null,
    );
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, user.id);
      state = state.copyWith(currentUser: user);
      return true;
    }
    return false;
  }

  Future<bool> register({required String name, required String email, required String password}) async {
    final exists = state.users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (exists) return false;
    final user = AppUser(
      id: const Uuid().v4(),
      name: name,
      email: email.trim(),
      password: password,
      role: UserRole.manager,
      kindergartenIds: [],
      createdAt: DateTime.now(),
    );
    await _usersBox.put(user.id, user.toMap());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.id);
    _reload();
    state = state.copyWith(currentUser: user);
    return true;
  }

  Future<void> logout() async {
    state = state.copyWith(clearUser: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<AppUser> createAdmin({required String name, required String email, required String password}) async {
    final user = AppUser(
      id: const Uuid().v4(),
      name: name, email: email.trim(), password: password,
      role: UserRole.admin, kindergartenIds: [],
      createdByAdminId: state.currentUser?.id, createdAt: DateTime.now(),
    );
    await _usersBox.put(user.id, user.toMap());
    _reload();
    return user;
  }

  Future<Kindergarten> createKindergarten({required String name, required String address, required String phone}) async {
    final kg = Kindergarten(
      id: const Uuid().v4(),
      name: name, address: address, phone: phone,
      adminId: state.currentUser!.id, createdAt: DateTime.now(),
    );
    await _kgBox.put(kg.id, kg.toMap());
    _reload();
    return kg;
  }

  Future<AppUser> createManager({required String name, required String email, required String password, required String kindergartenId}) async {
    final user = AppUser(
      id: const Uuid().v4(),
      name: name, email: email.trim(), password: password,
      role: UserRole.manager, kindergartenIds: [kindergartenId],
      createdByAdminId: state.currentUser?.id, createdAt: DateTime.now(),
    );
    await _usersBox.put(user.id, user.toMap());
    _reload();
    return user;
  }

  Future<AppUser> createCourier({required String name, required String email, required String password, List<String> kindergartenIds = const []}) async {
    final user = AppUser(
      id: const Uuid().v4(),
      name: name, email: email.trim(), password: password,
      role: UserRole.courier, kindergartenIds: kindergartenIds,
      createdByAdminId: state.currentUser?.id, createdAt: DateTime.now(),
    );
    await _usersBox.put(user.id, user.toMap());
    _reload();
    return user;
  }

  Future<void> deleteUser(String userId) async {
    await _usersBox.delete(userId);
    _reload();
  }

  Future<void> deleteKindergarten(String kgId) async {
    await _kgBox.delete(kgId);
    _reload();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
