import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zakup_ai_project/main.dart';
import 'package:zakup_ai_project/presentation/providers/cart_provider.dart';

void main() {
  testWidgets('App renders role select screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
        child: const DetpitApp(),
      ),
    );
    expect(find.text('ДЕТПИТ'), findsAny);
  });
}
