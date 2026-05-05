import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/order_notifier.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/section_label.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/order_status.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final orderState = ref.watch(orderProvider);
    final kgIds = auth.myKindergartens.map((k) => k.id).toList();
    final orders = orderState.ordersForKindergartens(kgIds);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, ref, auth)),
            SliverToBoxAdapter(child: _buildStats(auth, orders)),
            SliverToBoxAdapter(child: _buildChart(orders)),
            SliverToBoxAdapter(child: _buildRecentOrders(context, orders)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AuthState auth) {
    final now = DateTime.now();
    final weekdays = ['Понедельник','Вторник','Среда','Четверг','Пятница','Суббота','Воскресенье'];
    final months  = ['января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря'];
    final dateStr = '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 20,
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
                Text(auth.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Text('📅 $dateStr',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => ref.read(authProvider.notifier).logout(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.logout, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                  ),
                  Positioned(
                    top: 2, right: 2,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: Color(0xFFF5A623), shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(AuthState auth, List<OrderEntity> orders) {
    final totalOrders = orders.length;
    final totalAmount = orders.fold(0.0, (s, o) => s + o.total);
    final kgCount = auth.myKindergartens.length;
    final itemsActive = orders
        .where((o) => o.status != OrderStatus.delivered)
        .fold(0, (s, o) => s + o.itemCount);
    final amountStr = formatCurrency(totalAmount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatCard(
                emoji: '📋', label: 'Всего заказов', value: '$totalOrders',
                sub: 'Всего в системе',
                bg: const Color(0xFFEFF6FF), color: AppColors.adminBlue, trendUp: totalOrders > 0,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                emoji: '💰', label: 'Сумма заказов', value: amountStr,
                sub: 'За все время',
                bg: AppColors.primaryLight, color: AppColors.primary, trendUp: totalAmount > 0,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCard(
                emoji: '🏫', label: 'Детских садов', value: '$kgCount',
                sub: kgCount == 0 ? 'Добавьте детсад' : 'Под вашим управлением',
                bg: AppColors.courierAmberLight, color: AppColors.courierAmber, trendUp: false,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                emoji: '📦', label: 'Позиций в работе', value: '$itemsActive',
                sub: itemsActive > 0 ? 'Требует обработки' : 'Нет активных заказов',
                bg: const Color(0xFFFCE7F3), color: const Color(0xFF9D174D), trendUp: false,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<OrderEntity> orders) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));

    final weekValues = List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      final dayFmt = '${day.day.toString().padLeft(2,'0')}.${day.month.toString().padLeft(2,'0')}.${day.year}';
      return orders.where((o) => o.date == dayFmt).length.toDouble();
    });

    final weekTotal = weekValues.fold(0.0, (s, v) => s + v);
    final weekAmount = () {
      double sum = 0;
      for (int i = 0; i < 7; i++) {
        final day = monday.add(Duration(days: i));
        final dayFmt = '${day.day.toString().padLeft(2,'0')}.${day.month.toString().padLeft(2,'0')}.${day.year}';
        for (final o in orders) { if (o.date == dayFmt) sum += o.total; }
      }
      return sum;
    }();
    final avgPerDay = weekTotal > 0 ? (weekTotal / 7).toStringAsFixed(1) : '0';
    final maxY = weekValues.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Заказы по дням',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(100)),
                  child: const Text('Эта неделя',
                      style: TextStyle(fontSize: 11, color: AppColors.adminBlue, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(BarChartData(
                barGroups: List.generate(7, (i) => BarChartGroupData(
                  x: i,
                  barRods: [BarChartRodData(
                    toY: weekValues[i] == 0 ? 0.1 : weekValues[i],
                    color: i == now.weekday - 1 ? AppColors.adminBlue : AppColors.adminBlue.withValues(alpha: 0.4),
                    width: 22,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6), topRight: Radius.circular(6),
                    ),
                  )],
                )),
                maxY: maxY < 1 ? 5 : maxY * 1.3,
                gridData: FlGridData(
                  show: true, drawVerticalLine: false, horizontalInterval: 1,
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
              )),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Заказов: ${weekTotal.toInt()}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                Text('Сумма: ${formatThousands(weekAmount)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                Text('Ср./день: $avgPerDay',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context, List<OrderEntity> orders) {
    final recent = orders.take(3).toList();
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
                child: const Text('Все заказы',
                    style: TextStyle(color: AppColors.adminBlue, fontSize: 13)),
              ),
            ],
          ),
          if (recent.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: const Center(
                child: Text('Нет заказов', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
              ),
            )
          else
            ...recent.map((o) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.assignment_outlined, color: AppColors.adminBlue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text('Заказ #${o.id}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                            const SizedBox(width: 8),
                            StatusChip(status: o.status, size: ChipSize.sm),
                          ]),
                          const SizedBox(height: 4),
                          Text('${o.kindergartenName} • ${formatCurrency(o.total)}',
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
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
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
          Text(value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
              maxLines: 1, overflow: TextOverflow.ellipsis),
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
