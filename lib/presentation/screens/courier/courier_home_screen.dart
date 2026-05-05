import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/order_status.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/order_notifier.dart';
import '../../widgets/section_label.dart';
import '../../widgets/status_chip.dart';

class CourierHomeScreen extends ConsumerWidget {
  const CourierHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final orderState = ref.watch(orderProvider);
    final deliveries = orderState.orders
        .where((o) => o.status == OrderStatus.inDelivery || o.status == OrderStatus.inProgress)
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, ref, auth)),
            SliverToBoxAdapter(child: _buildProgress(deliveries)),
            SliverToBoxAdapter(child: _buildStats(deliveries)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(child: const SectionLabel('АКТИВНЫЕ ДОСТАВКИ')),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _DeliveryCard(
                    order: deliveries[i],
                    index: i + 1,
                    onTap: () => context.push('/courier/delivery/${deliveries[i].id}'),
                  ),
                ),
                childCount: deliveries.length,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              sliver: SliverToBoxAdapter(
                child: _buildCTAButton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AuthState auth) {
    final now = DateTime.now();
    final weekdays = ['Понедельник','Вторник','Среда','Четверг','Пятница','Суббота','Воскресенье'];
    final months  = ['января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря'];
    final dateStr = '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';

    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.courierAmber,
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Добрый день,',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 4),
                Text('${auth.name} 🚚',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Text('📅 $dateStr',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => ref.read(authProvider.notifier).logout(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.logout, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(List<OrderEntity> deliveries) {
    final delivered = deliveries.where((o) => o.status == OrderStatus.delivered).length;
    final total = deliveries.isEmpty ? 1 : deliveries.length;
    final done = delivered;
    final remaining = total - done;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.courierAmber, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x66BA7517), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Прогресс доставок',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.9))),
                Text('$done/$total',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: Colors.white,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Доставлено: $done',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                Text('Осталось: $remaining',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(List<OrderEntity> deliveries) {
    final totalItems = deliveries.fold(0, (s, o) => s + o.itemCount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _StatTile(emoji: '📦', label: 'Доставок', value: '${deliveries.length}',
              bg: AppColors.courierAmberLight, color: AppColors.courierAmber),
          const SizedBox(width: 8),
          _StatTile(emoji: '🛒', label: 'Закупить', value: '$totalItems',
              bg: AppColors.primaryLight, color: AppColors.primary),
          const SizedBox(width: 8),
          const _StatTile(emoji: '🗺️', label: 'Маршрут', value: '13.3 км',
              bg: AppColors.adminBlueLight, color: AppColors.adminBlue),
        ],
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/courier/route'),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.courierAmber, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x66BA7517), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route_outlined, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Начать маршрут',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String emoji, label, value;
  final Color bg, color;

  const _StatTile({
    required this.emoji, required this.label, required this.value,
    required this.bg, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final OrderEntity order;
  final int index;
  final VoidCallback onTap;

  const _DeliveryCard({required this.order, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.courierAmberLight, borderRadius: BorderRadius.circular(12)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(child: Text('🏫', style: TextStyle(fontSize: 24))),
                  Positioned(
                    top: -4, left: -4,
                    child: Container(
                      width: 20, height: 20,
                      decoration: const BoxDecoration(
                          color: AppColors.courierAmber, shape: BoxShape.circle),
                      child: Center(child: Text('$index',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.kindergartenName, style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 2),
                    Expanded(child: Text(order.address,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.inventory_2_outlined, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 2),
                    Text('${order.itemCount} позиций',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(status: order.status, size: ChipSize.sm),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right, color: AppColors.textLight, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
