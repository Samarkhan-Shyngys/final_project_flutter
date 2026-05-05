import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/order_item_entity.dart';
import '../../../domain/entities/order_status.dart';
import '../../providers/order_notifier.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/top_bar.dart';

class DeliveryDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const DeliveryDetailScreen({super.key, required this.id});

  @override
  ConsumerState<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends ConsumerState<DeliveryDetailScreen> {
  late List<bool> _delivered;
  bool _confirmed = false;

  void _initChecklist(List<OrderItemEntity> items) {
    if (_delivered.length != items.length) {
      _delivered = List.filled(items.length, false);
    }
  }

  @override
  void initState() {
    super.initState();
    _delivered = [];
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final order = orderState.getById(widget.id);

    if (order == null) {
      return const Scaffold(
        appBar: TopBar(title: 'Детали доставки'),
        body: Center(child: Text('Заказ не найден')),
      );
    }

    _initChecklist(order.items);

    if (_confirmed) return _buildSuccess(context, order);

    final allDelivered = _delivered.isNotEmpty && _delivered.every((v) => v);
    final deliveredCount = _delivered.where((v) => v).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: TopBar(
        title: 'Детали доставки',
        action: StatusChip(status: order.status, size: ChipSize.sm),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _buildKgCard(order),
          const SizedBox(height: 12),
          _buildChecklist(order, deliveredCount),
          const SizedBox(height: 16),
          _buildConfirmButton(order, allDelivered),
        ],
      ),
    );
  }

  Widget _buildKgCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                  color: AppColors.courierAmberLight, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('🏫', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.kindergartenName, style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(child: Text(order.address,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted))),
                ]),
              ],
            )),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderMid),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(order.phone, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
              ]),
              Row(children: [
                const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text('Заказ #${order.id}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist(OrderEntity order, int deliveredCount) {
    return Container(
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
              const Text('Позиции', style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
              Text('$deliveredCount/${order.items.length} передано',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(order.items.length, (i) {
            final item = order.items[i];
            final done = i < _delivered.length && _delivered[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() {
                  if (i < _delivered.length) _delivered[i] = !_delivered[i];
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: done ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
                    border: Border.all(
                        color: done ? const Color(0xFFBBF7D0) : AppColors.border, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: done ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: done
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.name, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: done ? AppColors.textMuted : AppColors.text,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: done ? const Color(0xFFDCFCE7) : AppColors.border,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('${item.quantity} ${item.unit}', style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: done ? AppColors.primary : AppColors.textMuted,
                      )),
                    ),
                  ]),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(OrderEntity order, bool allDelivered) {
    return GestureDetector(
      onTap: allDelivered
          ? () async {
              await ref.read(orderProvider.notifier).updateStatus(order.id, OrderStatus.delivered);
              setState(() => _confirmed = true);
            }
          : null,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: allDelivered ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(16),
          boxShadow: allDelivered
              ? const [BoxShadow(color: Color(0x661A6B4A), blurRadius: 16, offset: Offset(0, 4))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              allDelivered ? Icons.check_circle_outline : Icons.pending_outlined,
              color: allDelivered ? Colors.white : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              allDelivered ? 'Подтвердить доставку' : 'Отметьте все позиции',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: allDelivered ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, OrderEntity order) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                const Text('Доставка подтверждена!', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(height: 8),
                Text(order.kindergartenName, style: const TextStyle(
                    fontSize: 14, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text('Заказ #${order.id} успешно доставлен',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/courier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('К доставкам',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
