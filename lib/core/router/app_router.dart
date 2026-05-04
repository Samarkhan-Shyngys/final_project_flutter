import 'package:go_router/go_router.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/role_select_screen.dart';
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
import '../../presentation/screens/courier/courier_shell.dart';
import '../../presentation/screens/courier/courier_home_screen.dart';
import '../../presentation/screens/courier/purchase_checklist_screen.dart';
import '../../presentation/screens/courier/route_list_screen.dart';
import '../../presentation/screens/courier/courier_profile_screen.dart';
import '../../presentation/screens/courier/delivery_detail_screen.dart';

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;
      final isAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (!loggedIn && !isAuth) return '/login';
      if (loggedIn && isAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/',         builder: (_, __) => const RoleSelectScreen()),

      ShellRoute(
        builder: (_, __, child) => ManagerShell(child: child),
        routes: [
          GoRoute(path: '/manager',         builder: (_, __) => const ManagerHomeScreen()),
          GoRoute(path: '/manager/catalog', builder: (_, __) => const ProductCatalogScreen()),
          GoRoute(path: '/manager/cart',    builder: (_, __) => const ShoppingCartScreen()),
          GoRoute(path: '/manager/orders',  builder: (_, __) => const OrdersHistoryScreen()),
        ],
      ),
      GoRoute(
        path: '/manager/order/:id',
        builder: (_, s) => OrderDetailsScreen(id: s.pathParameters['id']!),
      ),

      ShellRoute(
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin',            builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/orders',     builder: (_, __) => const OrdersListScreen()),
          GoRoute(path: '/admin/aggregated', builder: (_, __) => const AggregatedOrdersScreen()),
          GoRoute(path: '/admin/analytics',  builder: (_, __) => const AnalyticsScreen()),
        ],
      ),

      ShellRoute(
        builder: (_, __, child) => CourierShell(child: child),
        routes: [
          GoRoute(path: '/courier',           builder: (_, __) => const CourierHomeScreen()),
          GoRoute(path: '/courier/checklist', builder: (_, __) => const PurchaseChecklistScreen()),
          GoRoute(path: '/courier/route',     builder: (_, __) => const RouteListScreen()),
          GoRoute(path: '/courier/profile',   builder: (_, __) => const CourierProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/courier/delivery/:id',
        builder: (_, s) => DeliveryDetailScreen(id: s.pathParameters['id']!),
      ),
    ],
  );
}
