import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_role.dart';
import '../../presentation/providers/auth_notifier.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/superadmin/super_admin_shell.dart';
import '../../presentation/screens/superadmin/super_admin_home_screen.dart';
import '../../presentation/screens/superadmin/super_admin_profile_screen.dart';
import '../../presentation/screens/manager/manager_shell.dart';
import '../../presentation/screens/manager/manager_home_screen.dart';
import '../../presentation/screens/manager/product_catalog_screen.dart';
import '../../presentation/screens/manager/shopping_cart_screen.dart';
import '../../presentation/screens/manager/orders_history_screen.dart';
import '../../presentation/screens/manager/order_details_screen.dart';
import '../../presentation/screens/admin/admin_shell.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/orders_list_screen.dart';
import '../../presentation/screens/admin/aggregated_orders_screen.dart';
import '../../presentation/screens/admin/analytics_screen.dart';
import '../../presentation/screens/admin/admin_management_screen.dart';
import '../../presentation/screens/admin/kindergarten_detail_screen.dart';
import '../../presentation/screens/courier/courier_shell.dart';
import '../../presentation/screens/courier/courier_home_screen.dart';
import '../../presentation/screens/courier/purchase_checklist_screen.dart';
import '../../presentation/screens/courier/route_list_screen.dart';
import '../../presentation/screens/courier/courier_profile_screen.dart';
import '../../presentation/screens/courier/delivery_detail_screen.dart';

class AppRouter {
  final ProviderContainer _container;
  late final GoRouter router;

  AppRouter(this._container) {
    final notifier = _RouterNotifier(_container);
    router = GoRouter(
      initialLocation: '/',
      refreshListenable: notifier,
      redirect: (context, state) {
        final auth = _container.read(authProvider);
        final loggedIn = auth.isLoggedIn;
        final loc = state.matchedLocation;
        if (!loggedIn && loc != '/') return '/';
        if (loggedIn && loc == '/') {
          return switch (auth.currentUser!.role) {
            UserRole.superAdmin => '/superadmin',
            UserRole.admin      => '/admin',
            UserRole.manager    => '/manager',
            UserRole.courier    => '/courier',
          };
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const LoginScreen()),

        ShellRoute(
          builder: (_, __, child) => SuperAdminShell(child: child),
          routes: [
            GoRoute(path: '/superadmin',         builder: (_, __) => const SuperAdminHomeScreen()),
            GoRoute(path: '/superadmin/profile', builder: (_, __) => const SuperAdminProfileScreen()),
          ],
        ),

        ShellRoute(
          builder: (_, __, child) => ManagerShell(child: child),
          routes: [
            GoRoute(path: '/manager',         builder: (_, __) => const ManagerHomeScreen()),
            GoRoute(path: '/manager/catalog', builder: (_, __) => const ProductCatalogScreen()),
            GoRoute(path: '/manager/cart',    builder: (_, __) => const ShoppingCartScreen()),
            GoRoute(path: '/manager/orders',  builder: (_, __) => const OrdersHistoryScreen()),
          ],
        ),
        GoRoute(path: '/manager/order/:id', builder: (_, s) => OrderDetailsScreen(id: s.pathParameters['id']!)),

        ShellRoute(
          builder: (_, __, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: '/admin',            builder: (_, __) => const AdminDashboardScreen()),
            GoRoute(path: '/admin/orders',     builder: (_, __) => const OrdersListScreen()),
            GoRoute(path: '/admin/aggregated', builder: (_, __) => const AggregatedOrdersScreen()),
            GoRoute(path: '/admin/analytics',  builder: (_, __) => const AnalyticsScreen()),
            GoRoute(path: '/admin/management', builder: (_, __) => const AdminManagementScreen()),
          ],
        ),
        GoRoute(path: '/admin/kindergarten/:id', builder: (_, s) => KindergartenDetailScreen(id: s.pathParameters['id']!)),

        ShellRoute(
          builder: (_, __, child) => CourierShell(child: child),
          routes: [
            GoRoute(path: '/courier',           builder: (_, __) => const CourierHomeScreen()),
            GoRoute(path: '/courier/checklist', builder: (_, __) => const PurchaseChecklistScreen()),
            GoRoute(path: '/courier/route',     builder: (_, __) => const RouteListScreen()),
            GoRoute(path: '/courier/profile',   builder: (_, __) => const CourierProfileScreen()),
          ],
        ),
        GoRoute(path: '/courier/delivery/:id', builder: (_, s) => DeliveryDetailScreen(id: s.pathParameters['id']!)),
      ],
    );
  }
}

class _RouterNotifier extends ChangeNotifier {
  late final ProviderSubscription<AuthState> _sub;

  _RouterNotifier(ProviderContainer container) {
    _sub = container.listen(authProvider, (_, __) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
