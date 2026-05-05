import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_notifier.dart';

class SuperAdminProfileScreen extends ConsumerWidget {
  const SuperAdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final kgCount = auth.kindergartens.length;
    final usersCount = auth.users.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          children: [
            _buildHeader(context, auth),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  children: [
                    _buildStats(kgCount, usersCount),
                    const SizedBox(height: 16),
                    _buildMenu(),
                    const SizedBox(height: 16),
                    _buildLogout(context, ref),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthState auth) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 24),
      color: AppColors.primary,
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
          ),
          child: const Center(child: Text('👑', style: TextStyle(fontSize: 40))),
        ),
        const SizedBox(height: 12),
        Text(auth.name, style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text(auth.email, style: TextStyle(
            fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(100)),
          child: const Text('Суперадминистратор', style: TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _buildStats(int kgCount, int usersCount) {
    return Row(
      children: [
        Expanded(child: _StatCard(emoji: '🏫', label: 'Детских садов', value: '$kgCount')),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(emoji: '👥', label: 'Пользователей',  value: '$usersCount')),
        const SizedBox(width: 8),
        const Expanded(child: _StatCard(emoji: '⚙️', label: 'Система', value: '2.4.1')),
      ],
    );
  }

  Widget _buildMenu() {
    return Column(children: [
      _MenuItem(emoji: '🔐', label: 'Безопасность',  sub: 'Пароли и доступ'),
      const SizedBox(height: 8),
      _MenuItem(emoji: '⚙️', label: 'Настройки',      sub: 'Параметры системы'),
      const SizedBox(height: 8),
      _MenuItem(emoji: '📊', label: 'Системные логи', sub: 'История действий'),
    ]);
  }

  Widget _buildLogout(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(authProvider.notifier).logout();
        context.go('/');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFECACA), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Выйти из аккаунта', style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)))),
          const Icon(Icons.chevron_right, color: Color(0xFFEF4444), size: 20),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, label, value;
  const _StatCard({required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String emoji, label, sub;
  const _MenuItem({required this.emoji, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
            Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        )),
        const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
      ]),
    );
  }
}
