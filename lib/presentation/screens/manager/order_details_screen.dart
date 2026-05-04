import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/order_status.dart';
import '../../providers/order_provider.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/top_bar.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String id;
  const OrderDetailsScreen({super.key, required this.id});

  static final _fmt = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (_, provider, __) {
        final order = provider.getById(id);
        if (order == null) {
          return const Scaffold(
            appBar: TopBar(title: 'Заказ не найден'),
            body: Center(child: Text('Заказ не найден')),
          );
        }
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: AppColors.bg,
            appBar: TopBar(
              title: 'Заказ #${order.id}',
              action: StatusChip(status: order.status, size: ChipSize.md),
            ),
            body: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _buildKindergartenCard(order),
                const SizedBox(height: 12),
                _buildTimeline(order),
                const SizedBox(height: 12),
                _buildItemsCard(order),
                if (order.status != OrderStatus.delivered) ...[
                  const SizedBox(height: 12),
                  _buildCancelButton(context, provider, order),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKindergartenCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('🏫', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.kindergartenName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(order.address, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ]),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(order.phone, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderMid),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Создан: ${order.date}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text('Менеджер: ${order.managerName}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(OrderEntity order) {
    const steps = [
      ('Создан', '09:00'), ('Подтверждён', '09:15'), ('В работе', '10:30'),
      ('В доставке', '14:00'), ('Выполнен', ''),
    ];
    final activeStep = switch (order.status) {
      OrderStatus.draft      => 0,
      OrderStatus.inProgress => 2,
      OrderStatus.inDelivery => 3,
      OrderStatus.delivered  => 4,
    };

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
          const Text('Статус заказа',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) => _TimelineStep(
            label: steps[i].$1, time: steps[i].$2,
            isDone: i < activeStep, isActive: i == activeStep, isLast: i == steps.length - 1,
          )),
        ],
      ),
    );
  }

  Widget _buildItemsCard(OrderEntity order) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(alignment: Alignment.centerLeft,
                child: Text('Состав заказа',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text))),
          ),
          const Divider(height: 1, color: AppColors.border),
          ...order.items.map((item) => Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                        Text('${item.quantity} ${item.unit} × ${item.price.toInt()} ₽',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(_fmt.format(item.total),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
          ])),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Итого',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                Text(_fmt.format(order.total),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, OrderProvider provider, OrderEntity order) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Отменить заказ?'),
            content: Text('Заказ #${order.id} будет удалён.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Нет')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Удалить', style: TextStyle(color: Color(0xFFEF4444))),
              ),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          await provider.deleteOrder(order.id);
          if (context.mounted) context.pop();
        }
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Отменить заказ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label, time;
  final bool isDone, isActive, isLast;

  const _TimelineStep({required this.label, required this.time,
      required this.isDone, required this.isActive, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _buildCircle(),
            if (!isLast) Container(width: 2, height: 24, color: isDone ? AppColors.primary : AppColors.borderMid),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isDone || isActive ? AppColors.text : AppColors.textLight,
              )),
              if (time.isNotEmpty)
                Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircle() {
    if (isDone) {
      return Container(
        width: 28, height: 28,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    }
    if (isActive) {
      return Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: AppColors.primaryLight, shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: const Center(child: SizedBox(width: 12, height: 12,
            child: DecoratedBox(decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)))),
      );
    }
    return Container(
      width: 28, height: 28,
      decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
      child: const Center(child: SizedBox(width: 8, height: 8,
          child: DecoratedBox(decoration: BoxDecoration(color: AppColors.textLight, shape: BoxShape.circle)))),
    );
  }
}
