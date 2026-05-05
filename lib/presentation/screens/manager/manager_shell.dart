import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/cart_notifier.dart';

class ManagerShell extends ConsumerStatefulWidget {
  final Widget child;
  const ManagerShell({super.key, required this.child});

  @override
  ConsumerState<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends ConsumerState<ManagerShell> {
  static const _tabs = ['/manager', '/manager/catalog', '/manager/cart', '/manager/orders'];

  static int _activeIndex(String location) {
    int best = 0;
    int bestLen = -1;
    for (int i = 0; i < _tabs.length; i++) {
      final t = _tabs[i];
      if (location == t || location.startsWith('$t/')) {
        if (t.length > bestLen) {
          bestLen = t.length;
          best = i;
        }
      }
    }
    return bestLen >= 0 ? best : 0;
  }

  void _onTap(int index) {
    context.go(_tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final location = GoRouterState.of(context).uri.path;
    final activeIndex = _activeIndex(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                _NavItem(icon: Icons.home_outlined, label: 'Главная',  index: 0, active: activeIndex == 0, onTap: _onTap),
                _NavItem(icon: Icons.inventory_2_outlined, label: 'Каталог', index: 1, active: activeIndex == 1, onTap: _onTap),
                _CartNavItem(count: cart.totalItems, index: 2, active: activeIndex == 2, onTap: _onTap),
                _NavItem(icon: Icons.assignment_outlined, label: 'Заказы', index: 3, active: activeIndex == 3, onTap: _onTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool active;
  final ValueChanged<int> onTap;

  const _NavItem({required this.icon, required this.label, required this.index, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? AppColors.primary : AppColors.textLight, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: active ? AppColors.primary : AppColors.textLight)),
            if (active) ...[
              const SizedBox(height: 4),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  final int count;
  final int index;
  final bool active;
  final ValueChanged<int> onTap;

  const _CartNavItem({required this.count, required this.index, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_cart_outlined, color: active ? AppColors.primary : AppColors.textLight, size: 22),
                if (count > 0)
                  Positioned(
                    top: -6, right: -8,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                      child: Center(
                        child: Text('$count', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Корзина', style: TextStyle(fontSize: 10, color: active ? AppColors.primary : AppColors.textLight)),
            if (active) ...[
              const SizedBox(height: 4),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}
