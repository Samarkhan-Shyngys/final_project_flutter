import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/order_status.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/top_bar.dart';

class _HistoryOrder {
  final String id;
  final OrderStatus status;
  final String date;
  final int items;
  final int amount;

  const _HistoryOrder({
    required this.id,
    required this.status,
    required this.date,
    required this.items,
    required this.amount,
  });
}

const _kOrders = [
  _HistoryOrder(id: '2847', status: OrderStatus.inDelivery, date: '14 марта', items: 8, amount: 3450),
  _HistoryOrder(id: '2831', status: OrderStatus.delivered, date: '12 марта', items: 5, amount: 2890),
  _HistoryOrder(id: '2818', status: OrderStatus.inProgress, date: '10 марта', items: 11, amount: 4120),
  _HistoryOrder(id: '2805', status: OrderStatus.delivered, date: '7 марта', items: 7, amount: 3210),
  _HistoryOrder(id: '2793', status: OrderStatus.delivered, date: '5 марта', items: 4, amount: 2640),
  _HistoryOrder(id: '2780', status: OrderStatus.delivered, date: '3 марта', items: 13, amount: 5100),
];

class OrdersHistoryScreen extends StatelessWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: const TopBar(title: 'История заказов', showBack: true),
        body: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: _kOrders.length,
            itemBuilder: (context, index) {
              final order = _kOrders[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _OrderHistoryCard(
                  order: order,
                  onTap: () => context.go('/manager/order/${order.id}'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrderHistoryCard extends StatefulWidget {
  final _HistoryOrder order;
  final VoidCallback onTap;

  const _OrderHistoryCard({required this.order, required this.onTap});

  @override
  State<_OrderHistoryCard> createState() => _OrderHistoryCardState();
}

class _OrderHistoryCardState extends State<_OrderHistoryCard> {
  bool _pressed = false;

  static final _currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

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
            boxShadow: const [
              BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Заказ #${order.id}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusChip(status: order.status, size: ChipSize.sm),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${order.date} • ${order.items} позиций • ${_currencyFormat.format(order.amount)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
