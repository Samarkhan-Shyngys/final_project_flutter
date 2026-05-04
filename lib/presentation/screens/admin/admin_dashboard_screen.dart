import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/section_label.dart';
import '../../../domain/entities/order_status.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
            SliverToBoxAdapter(child: _buildChart()),
            SliverToBoxAdapter(child: _buildRecentOrders(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 40,
      ),
      color: AppColors.adminBlue,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Панель управления',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 4),
                const Text('Администратор',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Text('📅 Понедельник, 16 марта 2026',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => context.read<AuthProvider>().logout(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0x55EF4444),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.logout, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _StatCard(emoji: '📋', label: 'Всего заказов', value: '47',
                    sub: '+12% к прошлой неделе', bg: Color(0xFFEFF6FF), color: AppColors.adminBlue, trendUp: true)),
                SizedBox(width: 12),
                Expanded(child: _StatCard(emoji: '💰', label: 'Сумма заказов', value: '284 500 ₽',
                    sub: 'За текущий месяц', bg: AppColors.primaryLight, color: AppColors.primary, trendUp: true)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(emoji: '🏫', label: 'Детских садов', value: '12',
                    sub: '3 новых в этом месяце', bg: AppColors.courierAmberLight, color: AppColors.courierAmber, trendUp: false)),
                SizedBox(width: 12),
                Expanded(child: _StatCard(emoji: '📦', label: 'Позиций в закупке', value: '156',
                    sub: 'Требует обработки', bg: Color(0xFFFCE7F3), color: Color(0xFF9D174D), trendUp: false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    const values = [8.0, 12.0, 7.0, 15.0, 10.0, 4.0, 2.0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Заказы по дням', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(100)),
                  child: const Text('Эта неделя', style: TextStyle(fontSize: 11, color: AppColors.adminBlue, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(7, (i) => BarChartGroupData(
                    x: i,
                    barRods: [BarChartRodData(
                      toY: values[i],
                      color: AppColors.adminBlue,
                      width: 22,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6), topRight: Radius.circular(6),
                      ),
                    )],
                  )),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF3F4F6), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(days[v.toInt()],
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    )),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Всего заказов: 58', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                Text('Сумма (тыс.₽): 324', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                Text('Ср./день: 8.3', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    final orders = [
      {'id': '2847', 'name': 'ДС №45', 'amount': 3450, 'status': OrderStatus.inDelivery},
      {'id': '2846', 'name': 'ДС №12', 'amount': 2100, 'status': OrderStatus.inProgress},
      {'id': '2845', 'name': 'ДС №7',  'amount': 5680, 'status': OrderStatus.delivered},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionLabel('Последние заказы'),
              TextButton(
                onPressed: () => context.go('/admin/orders'),
                child: const Text('Все заказы', style: TextStyle(color: AppColors.adminBlue, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...orders.map((o) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.assignment_outlined, color: AppColors.adminBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('Заказ #${o['id']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                          const SizedBox(width: 8),
                          StatusChip(status: o['status'] as OrderStatus, size: ChipSize.sm),
                        ]),
                        const SizedBox(height: 4),
                        Text('${o['name']} • ${o['amount']} ₽',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textLight),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, label, value, sub;
  final Color bg, color;
  final bool trendUp;

  const _StatCard({required this.emoji, required this.label, required this.value,
      required this.sub, required this.bg, required this.color, required this.trendUp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (trendUp) const Icon(Icons.trending_up, size: 12, color: Color(0xFF16A34A)),
              const SizedBox(width: 2),
              Expanded(child: Text(sub,
                  style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }
}
