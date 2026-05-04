import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  static const _tabs = ['/admin', '/admin/orders', '/admin/aggregated', '/admin/analytics'];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final activeIndex = _tabs.indexWhere((t) => location == t);

    return Scaffold(
      body: child,
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
                _AdminNavItem(icon: Icons.dashboard_outlined,   label: 'Дашборд', index: 0, active: activeIndex == 0, tabs: _tabs),
                _AdminNavItem(icon: Icons.list_alt_outlined,    label: 'Заказы',  index: 1, active: activeIndex == 1, tabs: _tabs),
                _AdminNavItem(icon: Icons.layers_outlined,      label: 'Сводный', index: 2, active: activeIndex == 2, tabs: _tabs),
                _AdminNavItem(icon: Icons.bar_chart_outlined,   label: 'Аналитика', index: 3, active: activeIndex == 3, tabs: _tabs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool active;
  final List<String> tabs;

  const _AdminNavItem({required this.icon, required this.label, required this.index, required this.active, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.go(tabs[index]),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? AppColors.adminBlue : AppColors.textLight, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: active ? AppColors.adminBlue : AppColors.textLight)),
            if (active) ...[
              const SizedBox(height: 4),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.adminBlue, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}
