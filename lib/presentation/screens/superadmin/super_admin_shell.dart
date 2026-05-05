import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class SuperAdminShell extends StatelessWidget {
  final Widget child;
  const SuperAdminShell({super.key, required this.child});

  static const _tabs = ['/superadmin', '/superadmin/profile'];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    final activeIndex = _tabs.indexOf(loc).clamp(0, 1);

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
                _NavItem(icon: Icons.admin_panel_settings_outlined, label: 'Администраторы',
                    index: 0, active: activeIndex == 0,
                    onTap: () => context.go(_tabs[0])),
                _NavItem(icon: Icons.person_outlined, label: 'Профиль',
                    index: 1, active: activeIndex == 1,
                    onTap: () => context.go(_tabs[1])),
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
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.index,
      required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? AppColors.primary : AppColors.textLight, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10,
                color: active ? AppColors.primary : AppColors.textLight)),
            if (active) ...[
              const SizedBox(height: 4),
              Container(width: 4, height: 4,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}
