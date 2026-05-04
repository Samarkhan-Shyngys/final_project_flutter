import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/top_bar.dart';
import '../../providers/order_provider.dart';
import '../../../domain/entities/order_entity.dart';

class OrdersHistoryScreen extends StatelessWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const TopBar(title: 'История заказов'),
      body: Consumer<OrderProvider>(
        builder: (_, provider, __) {
          final orders = provider.orders;
          if (orders.isEmpty) {
            return const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('📋', style: TextStyle(fontSize: 48)),
                SizedBox(height: 12),
                Text('Нет заказов', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              ]),
            );
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: orders.length,
            itemBuilder: (_, i) => _OrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => context.push('/manager/order/${order.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('Заказ #${order.id}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                      const SizedBox(width: 8),
                      StatusChip(status: order.status, size: ChipSize.sm),
                    ]),
                    const SizedBox(height: 4),
                    Text('${order.date} • ${order.itemCount} поз. • ${order.total.toInt()} ₽',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
