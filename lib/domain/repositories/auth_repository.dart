import '../entities/app_user.dart';
import '../entities/kindergarten.dart';

abstract class AuthRepository {
  Future<void> init();
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<void> register({required String name, required String email, required String password});
  Future<AppUser> createAdmin({required String name, required String email, required String password});
  Future<AppUser> createManager({required String name, required String email, required String password, required String kindergartenId});
  Future<AppUser> createCourier({required String name, required String email, required String password, List<String> kindergartenIds});
  Future<Kindergarten> createKindergarten({required String name, required String address, required String phone});
  Future<void> deleteUser(String userId);
  Future<void> deleteKindergarten(String kgId);
  AppUser? get currentUser;
  List<AppUser> get allUsers;
  List<Kindergarten> get allKindergartens;
}
