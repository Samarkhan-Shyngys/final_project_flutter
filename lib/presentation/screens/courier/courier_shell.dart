import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class CourierShell extends StatelessWidget {
  final Widget child;
  const CourierShell({super.key, required this.child});

  static const _tabs = ['/courier', '/courier/checklist', '/courier/route', '/courier/profile'];

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
                _CourierNavItem(icon: Icons.local_shipping_outlined, label: 'Доставки', index: 0, active: activeIndex == 0, tabs: _tabs),
                _CourierNavItem(icon: Icons.check_box_outlined,      label: 'Закупка',  index: 1, active: activeIndex == 1, tabs: _tabs),
                _CourierNavItem(icon: Icons.map_outlined,            label: 'Маршрут',  index: 2, active: activeIndex == 2, tabs: _tabs),
                _CourierNavItem(icon: Icons.person_outline,          label: 'Профиль',  index: 3, active: activeIndex == 3, tabs: _tabs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourierNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool active;
  final List<String> tabs;

  const _CourierNavItem({required this.icon, required this.label, required this.index, required this.active, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.go(tabs[index]),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? AppColors.courierAmber : AppColors.textLight, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: active ? AppColors.courierAmber : AppColors.textLight)),
            if (active) ...[
              const SizedBox(height: 4),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.courierAmber, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}
