import 'package:flutter_test/flutter_test.dart';
import 'package:zakup_ai_project/presentation/providers/auth_provider.dart';

void main() {
  test('AuthProvider initial state is not logged in', () {
    final auth = AuthProvider();
    expect(auth.isLoggedIn, false);
    expect(auth.email, '');
    expect(auth.name, '');
  });
}
