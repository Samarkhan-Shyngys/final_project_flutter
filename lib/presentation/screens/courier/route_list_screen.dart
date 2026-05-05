import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/order_status.dart';
import '../../providers/order_notifier.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/top_bar.dart';

class RouteListScreen extends ConsumerWidget {
  const RouteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);
    final deliveries = orderState.orders
        .where((o) => o.status == OrderStatus.inDelivery || o.status == OrderStatus.inProgress)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const TopBar(title: 'Маршрут доставки', showBack: false),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _buildRouteBanner(deliveries.length),
          const SizedBox(height: 16),
          _buildTimeline(context, deliveries),
          const SizedBox(height: 16),
          _buildSummary(deliveries),
        ],
      ),
    );
  }

  Widget _buildRouteBanner(int count) {
    final now = DateTime.now();
    final months = ['января','февраля','марта','апреля','мая','июня',
                    'июля','августа','сентября','октября','ноября','декабря'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Маршрут на $dateStr',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.courierAmber)),
                const SizedBox(height: 2),
                Text('$count остановок • ~4 ч 30 мин',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFD97706))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.courierAmber, borderRadius: BorderRadius.circular(12)),
            child: const Text('Навигация',
                style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<OrderEntity> deliveries) {
    final stops = <({String label, String address, String time, String? orderId,
                     OrderStatus? status, bool isOffice, double? dist})>[];

    for (int i = 0; i < deliveries.length; i++) {
      final o = deliveries[i];
      stops.add((
        label: o.kindergartenName, address: o.address,
        time: o.date.isNotEmpty ? o.date : '—', orderId: o.id,
        status: o.status, isOffice: false,
        dist: i == 0 ? 2.4 : 4.1 + (i - 1) * 2.7,
      ));
    }
    stops.add((
      label: 'Возврат в офис', address: 'пр. Абая 150',
      time: '16:30', orderId: null, status: null, isOffice: true, dist: 3.2,
    ));

    return Column(
      children: List.generate(stops.length, (i) {
        final stop = stops[i];
        final isLast = i == stops.length - 1;
        final isDone = stop.status == OrderStatus.delivered;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              _StopCircle(isDone: isDone, isOffice: stop.isOffice, index: i + 1),
              if (!isLast) Container(width: 2, height: 48, color: isDone ? AppColors.primary : AppColors.borderMid),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.courierAmberLight, borderRadius: BorderRadius.circular(6)),
                        child: Text(stop.time, style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.courierAmber)),
                      ),
                      const SizedBox(width: 8),
                      if (stop.status != null)
                        StatusChip(status: stop.status!, size: ChipSize.sm),
                    ]),
                    const SizedBox(height: 6),
                    if (stop.isOffice)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          border: Border.all(color: AppColors.borderMid, width: 2,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(children: [
                          const Text('🏢', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(stop.label, style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                              Text(stop.address,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          )),
                          if (stop.dist != null)
                            Text('${stop.dist} км',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ]),
                      )
                    else
                      GestureDetector(
                        onTap: stop.orderId != null
                            ? () => context.push('/courier/delivery/${stop.orderId}')
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(color: AppColors.border, width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
                          ),
                          child: Row(children: [
                            const Text('🏫', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stop.label, style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                                Text(stop.address,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            )),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              if (stop.dist != null)
                                Text('${stop.dist} км',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const Icon(Icons.chevron_right, color: AppColors.textLight, size: 16),
                            ]),
                          ]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummary(List<OrderEntity> deliveries) {
    final totalDist = deliveries.isEmpty ? 0.0 : 13.3;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Сводка маршрута',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(icon: '📍', label: '${deliveries.length} остановок'),
              _SummaryItem(icon: '🛣️', label: '$totalDist км'),
              const _SummaryItem(icon: '⏱️', label: '4 ч 30 мин'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StopCircle extends StatelessWidget {
  final bool isDone, isOffice;
  final int index;
  const _StopCircle({required this.isDone, required this.isOffice, required this.index});

  @override
  Widget build(BuildContext context) {
    if (isDone) {
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
        color: AppColors.courierAmberLight, shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Center(child: Text('$index', style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.courierAmber))),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String icon, label;
  const _SummaryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
    ]);
  }
}
