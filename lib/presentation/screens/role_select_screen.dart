import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 20, right: 20, bottom: 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F3D2A), AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(child: Text('🌿', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 10),
              const Text(
                'ДЕТПИТ',
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: Colors.white, letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Система закупок',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Питание для детских садов',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _RoleCard(
                  emoji: '📋',
                  title: 'Менеджер',
                  subtitle: 'Управление заказами',
                  description: 'Создание и отслеживание заказов',
                  color: AppColors.primary,
                  bgColor: AppColors.primaryLight,
                  onTap: () => context.go('/manager'),
                ),
                const SizedBox(height: 12),
                _RoleCard(
                  emoji: '📊',
                  title: 'Администратор',
                  subtitle: 'Аналитика и контроль',
                  description: 'Дашборд и отчёты',
                  color: AppColors.adminBlue,
                  bgColor: AppColors.adminBlueLight,
                  onTap: () => context.go('/admin'),
                ),
                const SizedBox(height: 12),
                _RoleCard(
                  emoji: '🚚',
                  title: 'Курьер',
                  subtitle: 'Доставка и закупка',
                  description: 'Маршруты и чеклисты',
                  color: AppColors.courierAmber,
                  bgColor: AppColors.courierAmberLight,
                  onTap: () => context.go('/courier'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Версия 2.4.1 • Казахстан / Россия',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFFD1D5DB)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) { setState(() => _scale = 1.0); widget.onTap(); },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: 2),
                    Text(widget.subtitle,
                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(widget.description,
                        style: TextStyle(fontSize: 12, color: widget.color, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.chevron_right, color: widget.color, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
