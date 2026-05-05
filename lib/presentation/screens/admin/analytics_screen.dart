import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/product.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/order_notifier.dart';
import '../../widgets/top_bar.dart';
import '../../../domain/entities/order_entity.dart';

DateTime? _parseDate(String s) {
  final p = s.split('.');
  if (p.length != 3) return null;
  return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
}

List<OrderEntity> _filterByPeriod(List<OrderEntity> orders, int period) {
  final now = DateTime.now();
  final cutoff = now.subtract(Duration(days: period == 0 ? 7 : period == 1 ? 30 : 90));
  return orders.where((o) {
    final d = _parseDate(o.date);
    return d != null && d.isAfter(cutoff);
  }).toList();
}

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _period = 0;
  static const _periodLabels = ['Неделя', 'Месяц', 'Квартал'];

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final orderState = ref.watch(orderProvider);
    final kgIds = auth.myKindergartens.map((k) => k.id).toList();
    final allOrders = orderState.ordersForKindergartens(kgIds);
    final filtered = _filterByPeriod(allOrders, _period);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const TopBar(title: 'Аналитика', showBack: false),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _buildPeriodSwitcher(),
          const SizedBox(height: 16),
          _buildKpiRow(filtered),
          const SizedBox(height: 16),
          _buildLineChart(allOrders),
          const SizedBox(height: 16),
          _buildCategoryBars(allOrders),
          const SizedBox(height: 16),
          _buildTopProducts(allOrders),
          const SizedBox(height: 16),
          _buildKindergartenActivity(allOrders),
        ],
      ),
    );
  }

  Widget _buildPeriodSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: List.generate(3, (i) {
          final active = _period == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _period = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.adminBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_periodLabels[i], textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? Colors.white : AppColors.textMuted,
                    )),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKpiRow(List<OrderEntity> filtered) {
    final revenue = filtered.fold(0.0, (s, o) => s + o.total);
    final avgOrder = filtered.isEmpty ? 0.0 : revenue / filtered.length;
    return Row(
      children: [
        Expanded(child: _KpiCard(
          label: 'Выручка',
          value: '${formatNumber(revenue.round())} ₸',
          sub: filtered.isEmpty ? 'Нет данных' : '${filtered.length} заказов',
        )),
        const SizedBox(width: 12),
        Expanded(child: _KpiCard(
          label: 'Ср. заказ',
          value: '${formatNumber(avgOrder.round())} ₸',
          sub: filtered.isEmpty ? 'Нет данных' : _periodLabels[_period],
        )),
      ],
    );
  }

  Widget _buildLineChart(List<OrderEntity> orders) {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    final labels = <String>[];
    final months = ['Янв','Фев','Мар','Апр','Май','Июн','Июл','Авг','Сен','Окт','Ноя','Дек'];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final revenue = orders.where((o) {
        final d = _parseDate(o.date);
        return d != null && d.year == month.year && d.month == month.month;
      }).fold(0.0, (s, o) => s + o.total);
      spots.add(FlSpot((5 - i).toDouble(), revenue / 1000));
      labels.add(months[month.month - 1]);
    }

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final hasData = spots.any((s) => s.y > 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Динамика выручки (тыс. ₸)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 16),
          if (!hasData)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Нет данных за последние 6 месяцев',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              ),
            )
          else
            SizedBox(
              height: 160,
              child: LineChart(LineChartData(
                lineBarsData: [LineChartBarData(
                  spots: spots,
                  color: AppColors.adminBlue,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: AppColors.adminBlue.withValues(alpha: 0.1)),
                )],
                maxY: maxY < 1 ? 10 : maxY * 1.3,
                gridData: FlGridData(
                  show: true, drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF3F4F6), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                      return Text(labels[i], style: const TextStyle(fontSize: 10, color: AppColors.textMuted));
                    },
                  )),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              )),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBars(List<OrderEntity> orders) {
    final nameToCategory = { for (final p in kProducts) p.name: p.category };
    final Map<String, double> catQty = {'vegetables': 0, 'fruits': 0, 'supplies': 0};
    for (final order in orders) {
      for (final item in order.items) {
        final cat = nameToCategory[item.name] ?? 'other';
        if (catQty.containsKey(cat)) catQty[cat] = catQty[cat]! + item.quantity;
      }
    }

    final cats = [
      ('Овощи',     catQty['vegetables']!, AppColors.primary),
      ('Фрукты',    catQty['fruits']!,     AppColors.accent),
      ('Хозтовары', catQty['supplies']!,   AppColors.adminBlue),
    ];
    final maxVal = cats.map((c) => c.$2).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('По категориям',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 16),
          ...cats.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(c.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                    Text('${c.$2.toInt()} кг/шт',
                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(builder: (_, bc) => Stack(
                  children: [
                    Container(height: 8, decoration: BoxDecoration(
                        color: AppColors.border, borderRadius: BorderRadius.circular(8))),
                    Container(
                      height: 8,
                      width: maxVal == 0 ? 0 : bc.maxWidth * c.$2 / maxVal,
                      decoration: BoxDecoration(color: c.$3, borderRadius: BorderRadius.circular(8)),
                    ),
                  ],
                )),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTopProducts(List<OrderEntity> orders) {
    final Map<String, double> qtyMap = {};
    for (final order in orders) {
      for (final item in order.items) {
        qtyMap.update(item.name, (v) => v + item.quantity, ifAbsent: () => item.quantity.toDouble());
      }
    }
    final sorted = qtyMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();
    final maxQty = top5.isEmpty ? 1.0 : top5.first.value;
    const colors = [AppColors.primary, AppColors.adminBlue, AppColors.accent, AppColors.primary, AppColors.adminBlue];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Топ-5 товаров',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 16),
          if (top5.isEmpty)
            const Text('Нет данных', style: TextStyle(fontSize: 13, color: AppColors.textMuted))
          else
            ...List.generate(top5.length, (i) {
              final entry = top5[i];
              final pct = (entry.value / maxQty * 100).round();
              final color = colors[i % colors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(entry.key, style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text))),
                        Row(children: [
                          Text('${entry.value.toInt()} кг',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(width: 8),
                          Text('$pct%', style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LayoutBuilder(builder: (_, bc) => Stack(
                      children: [
                        Container(height: 6, decoration: BoxDecoration(
                            color: AppColors.border, borderRadius: BorderRadius.circular(100))),
                        Container(
                          height: 6,
                          width: bc.maxWidth * pct / 100,
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(100)),
                        ),
                      ],
                    )),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildKindergartenActivity(List<OrderEntity> orders) {
    final Map<String, ({int count, double amount})> kgMap = {};
    for (final order in orders) {
      final existing = kgMap[order.kindergartenName];
      kgMap[order.kindergartenName] = (
        count: (existing?.count ?? 0) + 1,
        amount: (existing?.amount ?? 0.0) + order.total,
      );
    }
    final sorted = kgMap.entries.toList()
      ..sort((a, b) => b.value.count.compareTo(a.value.count));
    final top3 = sorted.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Активность учреждений',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 12),
          if (top3.isEmpty)
            const Text('Нет данных', style: TextStyle(fontSize: 13, color: AppColors.textMuted))
          else
            ...List.generate(top3.length, (i) {
              final entry = top3[i];
              return Column(
                children: [
                  if (i > 0) const Divider(color: Color(0xFFF9FAFB), height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
                          child: const Center(child: Text('🏫', style: TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key, style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                              Text('${entry.value.count} заказов • ${formatNumber(entry.value.amount.round())} ₸',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(100)),
                          child: Text('#${i + 1}', style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value, sub;
  const _KpiCard({required this.label, required this.value, required this.sub});

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
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(100)),
            child: Text(sub, style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.adminBlue)),
          ),
        ],
      ),
    );
  }
}
