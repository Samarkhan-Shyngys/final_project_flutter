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

class ManagerHomeScreen extends ConsumerWidget {
  const ManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final orderState = ref.watch(orderProvider);
    final kgIds = auth.currentUser?.kindergartenIds ?? [];
    final orders = orderState.ordersForKindergartens(kgIds);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, ref, auth)),
            SliverToBoxAdapter(child: _buildBody(context, ref, auth, orders)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AuthState auth) {
    final topPadding = MediaQuery.of(context).padding.top;
    final kgId = auth.currentUser?.kindergartenIds.isNotEmpty == true
        ? auth.currentUser!.kindergartenIds.first
        : null;
    final kgName = kgId != null
        ? (auth.kindergartenById(kgId)?.name ?? 'Детский сад')
        : 'Детский сад';

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Добрый день,',
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${auth.name} 👋',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '🏫 $kgName',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ),
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
                  decoration: const BoxDecoration(color: Color(0x55EF4444), shape: BoxShape.circle),
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
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                  ),
                  Positioned(
                    top: 2, right: 2,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
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

  Widget _buildBody(BuildContext context, WidgetRef ref, AuthState auth, List<OrderEntity> orders) {
    final inProgress = orders.where((o) => o.status == OrderStatus.inProgress).length;
    final inDelivery = orders.where((o) => o.status == OrderStatus.inDelivery).length;
    final delivered  = orders.where((o) => o.status == OrderStatus.delivered).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatTile(label: 'В работе',   value: '$inProgress', color: AppColors.courierAmber),
              const SizedBox(width: 8),
              _StatTile(label: 'В доставке', value: '$inDelivery',  color: AppColors.adminBlue),
              const SizedBox(width: 8),
              _StatTile(label: 'Выполнено',  value: '$delivered',  color: const Color(0xFF3B6D11)),
            ],
          ),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildRecentOrders(context, orders),
          const SizedBox(height: 24),
          _buildDeliveryBanner(),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('БЫСТРЫЕ ДЕЙСТВИЯ'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                emoji: '➕', label: '+ Новый заказ',
                bgColor: AppColors.primaryLight, textColor: AppColors.primary,
                onTap: () => context.go('/manager/catalog'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionCard(
                emoji: '📦', label: 'Каталог',
                bgColor: AppColors.adminBlueLight, textColor: AppColors.adminBlue,
                onTap: () => context.go('/manager/catalog'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionCard(
                emoji: '🛒', label: 'Корзина',
                bgColor: AppColors.courierAmberLight, textColor: AppColors.courierAmber,
                onTap: () => context.go('/manager/cart'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentOrders(BuildContext context, List<OrderEntity> orders) {
    final recent = orders.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionLabel('ПОСЛЕДНИЕ ЗАКАЗЫ'),
            TextButton(
              onPressed: () => context.go('/manager/orders'),
              child: const Text(
                'Все заказы',
                style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text('Нет заказов',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
            ),
          )
        else
          ...recent.map((order) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OrderCard(
              order: _OrderData(
                id: order.id,
                status: order.status,
                date: order.date,
                items: order.itemCount,
                amount: order.total.toInt(),
              ),
              onTap: () => context.go('/manager/order/${order.id}'),
            ),
          )),
      ],
    );
  }

  Widget _buildDeliveryBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF2E9E6B)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Следующая поставка',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Среда, 19 марта — 10:00',
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('📦', style: TextStyle(fontSize: 20))),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final String emoji, label;
  final Color bgColor, textColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.emoji, required this.label,
    required this.bgColor, required this.textColor, required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: widget.bgColor, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderData {
  final String id, date;
  final OrderStatus status;
  final int items, amount;

  const _OrderData({
    required this.id, required this.status,
    required this.date, required this.items, required this.amount,
  });
}

class _OrderCard extends StatefulWidget {
  final _OrderData order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
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
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Заказ #${order.id}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                        const SizedBox(width: 8),
                        StatusChip(status: order.status, size: ChipSize.sm),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${order.date} • ${order.items} позиций',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${order.amount} ₸',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
