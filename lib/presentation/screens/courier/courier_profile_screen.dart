import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class CourierProfileScreen extends StatelessWidget {
  const CourierProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildStats()),
            SliverToBoxAdapter(child: _buildMenu(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 20, right: 20, bottom: 32,
      ),
      color: AppColors.courierAmber,
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
            ),
            child: const Center(child: Text('👨', style: TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: 12),
          Text(context.read<AuthProvider>().name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          Text('Курьер • Алматы',
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Color(0xFFFDE68A), size: 18),
              const SizedBox(width: 4),
              const Text('4.9',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFDE68A))),
              const SizedBox(width: 4),
              Text('(148 оценок)',
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Expanded(child: _StatTile(emoji: '📦', value: '248', label: 'Доставок')),
          SizedBox(width: 12),
          Expanded(child: _StatTile(emoji: '🚚', value: '18', label: 'Этот месяц')),
          SizedBox(width: 12),
          Expanded(child: _StatTile(emoji: '⭐', value: '4.9', label: 'Рейтинг')),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _MenuItem(
            iconEmoji: '🚚',
            iconBg: AppColors.courierAmberLight,
            iconColor: AppColors.courierAmber,
            title: 'История доставок',
            subtitle: '248 завершённых',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _MenuItem(
            iconEmoji: '📦',
            iconBg: AppColors.courierAmberLight,
            iconColor: AppColors.courierAmber,
            title: 'Отчёты закупок',
            subtitle: 'Текущий месяц',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
                await context.read<AuthProvider>().logout();
              },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFECACA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Выйти из аккаунта',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String emoji, value, label;
  const _StatTile({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String iconEmoji, title, subtitle;
  final Color iconBg, iconColor;
  final VoidCallback onTap;

  const _MenuItem({required this.iconEmoji, required this.iconBg, required this.iconColor,
      required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(20)),
              child: Center(child: Text(iconEmoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
