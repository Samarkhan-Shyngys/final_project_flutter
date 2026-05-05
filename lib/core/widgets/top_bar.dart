import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? action;
  final bool showBack;

  const TopBar({super.key, required this.title, this.action, this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBack
          ? GestureDetector(
              onTap: () { if (context.canPop()) context.pop(); },
              child: Center(
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.chevron_left, color: AppColors.text),
                ),
              ),
            )
          : null,
      automaticallyImplyLeading: false,
      title: Text(title),
      actions: action != null ? [action!, const SizedBox(width: 16)] : null,
    );
  }
}
