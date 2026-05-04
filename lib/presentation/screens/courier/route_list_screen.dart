import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/status_chip.dart';
import '../../../domain/entities/order_status.dart';

class RouteListScreen extends StatelessWidget {
  const RouteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const TopBar(title: 'Маршрут доставки', showBack: false),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _buildBanner(),
          const SizedBox(height: 20),
          _buildTimeline(context),
          const SizedBox(height: 20),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.courierAmberLight,
        border: Border.all(color: const Color(0xFFFDE68A)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Маршрут на 16 марта 2026',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.courierAmber)),
                SizedBox(height: 2),
                Text('3 остановки • 16.5 км • ~4 ч 30 мин',
                    style: TextStyle(fontSize: 12, color: Color(0xFFD97706))),
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.courierAmber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Навигация',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final stops = [
      {'num': 1, 'time': '09:00', 'name': 'ДС №12 «Берёзка»',  'addr': 'ул. Ленина 45',    'items': 3, 'dist': '2.4 км', 'status': OrderStatus.inDelivery, 'deliveryId': '1', 'isOffice': false},
      {'num': 2, 'time': '11:00', 'name': 'ДС №7 «Солнышко»',  'addr': 'ул. Пушкина 12',   'items': 5, 'dist': '4.1 км', 'status': OrderStatus.inProgress, 'deliveryId': '2', 'isOffice': false},
      {'num': 3, 'time': '14:00', 'name': 'ДС №23 «Радуга»',   'addr': 'ул. Гагарина 78',  'items': 2, 'dist': '6.8 км', 'status': OrderStatus.inProgress, 'deliveryId': '3', 'isOffice': false},
      {'num': 4, 'time': '16:30', 'name': 'Возврат в офис',     'addr': 'пр. Абая 150',     'items': 0, 'dist': '3.2 км', 'status': OrderStatus.draft,      'deliveryId': '',  'isOffice': true},
    ];

    return Column(
      children: List.generate(stops.length, (i) {
        final s = stops[i];
        final isDone = i == 0;
        final isOffice = s['isOffice'] as bool;
        final isLast = i == stops.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                _buildCircle(isDone, isOffice, s['num'] as int),
                if (!isLast)
                  Container(
                    width: 2, height: 48,
                    color: isDone ? AppColors.primary : AppColors.borderMid,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.primaryLight : AppColors.courierAmberLight,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(s['time'] as String,
                              style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: isDone ? AppColors.primary : AppColors.courierAmber,
                              )),
                        ),
                        const SizedBox(width: 8),
                        if (!isOffice)
                          StatusChip(status: s['status'] as OrderStatus, size: ChipSize.sm),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (isOffice)
                      _buildOfficeCard(s)
                    else
                      _buildDeliveryCard(context, s, isDone),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCircle(bool done, bool isOffice, int num) {
    if (done) {
      return Container(
        width: 40, height: 40,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      );
    }
    if (isOffice) {
      return Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.border,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderMid, width: 2),
        ),
        child: const Center(child: Text('🏢', style: TextStyle(fontSize: 18))),
      );
    }
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: AppColors.courierAmberLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.courierAmber, width: 2),
      ),
      child: Center(
        child: Text('$num', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.courierAmber)),
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, Map s, bool done) {
    return GestureDetector(
      onTap: () => context.push('/courier/delivery/${s['deliveryId']}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 2),
              Text(s['addr'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.inventory_2_outlined, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 2),
              Text('${s['items']} поз.', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(width: 8),
              const Icon(Icons.map_outlined, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 2),
              Text(s['dist'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeCard(Map s) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMid, width: 2, style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Возврат в офис', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textLight),
            const SizedBox(width: 2),
            Text(s['addr'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
            const SizedBox(width: 8),
            const Icon(Icons.map_outlined, size: 12, color: AppColors.textLight),
            const SizedBox(width: 2),
            Text(s['dist'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          ]),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Сводка маршрута', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(emoji: '📍', value: '3', label: 'остановки'),
              _SummaryItem(emoji: '🛣️', value: '16.5 км', label: 'расстояние'),
              _SummaryItem(emoji: '⏱️', value: '4 ч 30 мин', label: 'время'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String emoji, value, label;
  const _SummaryItem({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}
