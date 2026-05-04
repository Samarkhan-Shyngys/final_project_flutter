import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _email = '';
  String _name = '';
  String _role = 'manager';

  bool get isLoggedIn => _isLoggedIn;
  String get email => _email;
  String get name => _name;
  String get role => _role;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _email = prefs.getString('currentEmail') ?? '';
    _name = prefs.getString('currentName') ?? '';
    _role = prefs.getString('currentRole') ?? 'manager';
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) return 'Заполните все поля';
    final prefs = await SharedPreferences.getInstance();
    final storedPass = prefs.getString('user_pass_${email.trim()}');
    if (storedPass == null) return 'Пользователь не найден';
    if (storedPass != password) return 'Неверный пароль';

    _isLoggedIn = true;
    _email = email.trim();
    _name = prefs.getString('user_name_${email.trim()}') ?? email.trim();
    _role = prefs.getString('user_role_${email.trim()}') ?? 'manager';
    await _saveSession(prefs);
    notifyListeners();
    return null;
  }

  Future<String?> register(String name, String email, String password, String role) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) return 'Заполните все поля';
    if (password.length < 6) return 'Пароль минимум 6 символов';
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user_pass_${email.trim()}') != null) return 'Email уже зарегистрирован';

    await prefs.setString('user_pass_${email.trim()}', password);
    await prefs.setString('user_name_${email.trim()}', name.trim());
    await prefs.setString('user_role_${email.trim()}', role);

    _isLoggedIn = true;
    _email = email.trim();
    _name = name.trim();
    _role = role;
    await _saveSession(prefs);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    _isLoggedIn = false;
    _email = '';
    _name = '';
    notifyListeners();
  }

  Future<void> _saveSession(SharedPreferences prefs) async {
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('currentEmail', _email);
    await prefs.setString('currentName', _name);
    await prefs.setString('currentRole', _role);
  }
}
