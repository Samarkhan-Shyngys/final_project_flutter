import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/top_bar.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _period = 0;

  static const _periodLabels = ['Неделя', 'Месяц', 'Квартал'];

  static const _revenue = [324000, 679000, 3190000];
  static const _avgOrder = [5586, 14447, 16789];

  static const _weeklySpots = [42000.0, 68000.0, 38000.0, 87000.0, 55000.0, 22000.0, 12000.0];
  static const _monthlySpots = [210000.0, 185000.0, 284500.0];
  static const _quarterlySpots = [680000.0, 720000.0, 850000.0, 940000.0];

  List<double> get _spots => [_weeklySpots, _monthlySpots, _quarterlySpots][_period];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const TopBar(title: 'Аналитика', showBack: false),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _buildPeriodSwitcher(),
          const SizedBox(height: 16),
          _buildKpiRow(),
          const SizedBox(height: 16),
          _buildLineChart(),
          const SizedBox(height: 16),
          _buildCategoryBars(),
          const SizedBox(height: 16),
          _buildTopProducts(),
          const SizedBox(height: 16),
          _buildKindergartenActivity(),
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

  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(child: _KpiCard(
          label: 'Выручка',
          value: '${(_revenue[_period] / 1000).round()} тыс. ₽',
          trend: '+18%',
        )),
        const SizedBox(width: 12),
        Expanded(child: _KpiCard(
          label: 'Ср. заказ',
          value: '${_avgOrder[_period]} ₽',
          trend: '+5%',
        )),
      ],
    );
  }

  Widget _buildLineChart() {
    final spots = _spots;
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
          const Text('Динамика выручки', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(LineChartData(
              lineBarsData: [LineChartBarData(
                spots: List.generate(spots.length, (i) => FlSpot(i.toDouble(), spots[i] / 1000)),
                color: AppColors.adminBlue,
                barWidth: 2.5,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: true, color: AppColors.adminBlue.withValues(alpha: 0.1)),
              )],
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF3F4F6), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBars() {
    const cats = [
      ('Овощи',     186, AppColors.primary),
      ('Фрукты',    124, AppColors.accent),
      ('Хозтовары', 58,  AppColors.adminBlue),
    ];
    const maxVal = 186.0;

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
          const Text('По категориям', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
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
                    Text('${c.$2} кг', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(builder: (_, bc) => Stack(
                  children: [
                    Container(height: 8, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(8))),
                    Container(
                      height: 8,
                      width: bc.maxWidth * c.$2 / maxVal,
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

  Widget _buildTopProducts() {
    const products = [
      ('Картофель', 1240, 92, AppColors.primary),
      ('Морковь',   980,  78, AppColors.adminBlue),
      ('Яблоки',    860,  68, AppColors.accent),
      ('Капуста',   740,  59, AppColors.primary),
      ('Бананы',    620,  49, AppColors.adminBlue),
    ];

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
          const Text('Топ-5 товаров', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 16),
          ...products.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                    Row(children: [
                      Text('${p.$2} кг', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(width: 8),
                      Text('${p.$3}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.$4)),
                    ]),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(builder: (_, bc) => Stack(
                  children: [
                    Container(height: 6, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(100))),
                    Container(
                      height: 6,
                      width: bc.maxWidth * p.$3 / 100,
                      decoration: BoxDecoration(color: p.$4, borderRadius: BorderRadius.circular(100)),
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

  Widget _buildKindergartenActivity() {
    const kgs = [
      ('ДС №7 «Солнышко»',  18, 54200, '+22%'),
      ('ДС №45 «Ромашка»',  15, 47800, '+8%'),
      ('ДС №12 «Берёзка»',  12, 38400, '+15%'),
    ];

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
          const Text('Активность учреждений', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 12),
          ...List.generate(kgs.length, (i) {
            final kg = kgs[i];
            return Column(
              children: [
                if (i > 0) const Divider(color: Color(0xFFF9FAFB), height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
                        child: const Center(child: Text('🏫', style: TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(kg.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                            Text('${kg.$2} заказов • ${kg.$3} ₽', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(100)),
                        child: Text(kg.$4, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
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
  final String label, value, trend;
  const _KpiCard({required this.label, required this.value, required this.trend});

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
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(100)),
            child: Text(trend, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
          ),
        ],
      ),
    );
  }
}
