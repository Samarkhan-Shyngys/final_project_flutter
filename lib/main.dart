import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_notifier.dart';
import 'presentation/providers/order_notifier.dart';
import 'presentation/providers/cart_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final container = ProviderContainer();
  await container.read(authProvider.notifier).init();
  await container.read(orderProvider.notifier).init();
  await container.read(cartProvider.notifier).init();

  final appRouter = AppRouter(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: ZakupAIApp(router: appRouter.router),
    ),
  );
}

class ZakupAIApp extends StatelessWidget {
  final RouterConfig<Object> router;
  const ZakupAIApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ДЕТПИТ',
      theme: appTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
