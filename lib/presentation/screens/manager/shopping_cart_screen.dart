import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/order_item_entity.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/cart_notifier.dart';
import '../../providers/order_notifier.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/section_label.dart';
import '../../widgets/top_bar.dart';

class ShoppingCartScreen extends ConsumerStatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  ConsumerState<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends ConsumerState<ShoppingCartScreen> {
  bool _orderPlaced = false;
  String _newOrderId = '';

  Future<void> _placeOrder() async {
    final auth = ref.read(authProvider);
    final kgId = auth.currentUser?.kindergartenIds.isNotEmpty == true
        ? auth.currentUser!.kindergartenIds.first
        : '';
    final kg = kgId.isNotEmpty ? auth.kindergartenById(kgId) : null;
    final cart = ref.read(cartProvider);

    final items = cart.items.map((c) => OrderItemEntity(
      name: c.name, quantity: c.quantity, unit: c.unit, price: c.price,
    )).toList();

    final id = await ref.read(orderProvider.notifier).createOrder(
      kindergartenId: kgId,
      kindergartenName: kg?.name ?? 'Детский сад',
      address: kg?.address ?? '',
      phone: kg?.phone ?? '',
      managerName: auth.name.isEmpty ? 'Менеджер' : auth.name,
      items: items,
    );
    ref.read(cartProvider.notifier).clear();
    setState(() { _orderPlaced = true; _newOrderId = id; });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: _orderPlaced ? _buildSuccess(context) : _buildCartContent(context, cart),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text('Заказ оформлен!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Заказ #$_newOrderId',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
                        const SizedBox(height: 4),
                        const Text('Принят в обработку',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _orderPlaced = false);
                    context.go('/manager');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('На главную', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartState cart) {
    return Column(
      children: [
        TopBar(
          title: 'Корзина',
          showBack: false,
          action: cart.items.isNotEmpty
              ? TextButton(
                  onPressed: () => ref.read(cartProvider.notifier).clear(),
                  child: const Text('Очистить',
                      style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                )
              : null,
        ),
        if (cart.items.isEmpty)
          Expanded(child: _buildEmpty())
        else
          Expanded(
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(scrollbars: false),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const SizedBox(height: 16),
                  _buildDeliveryBanner(),
                  const SizedBox(height: 20),
                  ..._buildGroupedItems(cart),
                  const SizedBox(height: 8),
                  _buildSummaryCard(cart),
                  const SizedBox(height: 16),
                  _buildCTAButton(cart),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🛒', style: TextStyle(fontSize: 56)),
          SizedBox(height: 16),
          Text('Корзина пуста',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
          SizedBox(height: 8),
          Text('Добавьте товары из каталога',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildDeliveryBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          border: Border.all(color: const Color(0xFFC6E8D6)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Дата поставки',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4B7C63))),
                  SizedBox(height: 2),
                  Text('Среда, 19 марта',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedItems(CartState cart) {
    final groups = <String, List<CartItem>>{
      'vegetables': [], 'fruits': [], 'supplies': [],
    };
    for (final item in cart.items) {
      groups[item.category]?.add(item);
    }

    final categoryInfo = {
      'vegetables': ('🥕', 'ОВОЩИ'),
      'fruits': ('🍎', 'ФРУКТЫ'),
      'supplies': ('🧹', 'ХОЗТОВАРЫ'),
    };

    final widgets = <Widget>[];
    for (final entry in groups.entries) {
      if (entry.value.isEmpty) continue;
      final info = categoryInfo[entry.key]!;
      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: SectionLabel('${info.$1} ${info.$2}'),
      ));
      for (final item in entry.value) {
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: _CartItemCard(
            item: item,
            onQuantityChanged: (val) => ref.read(cartProvider.notifier).updateQuantity(item.id, val),
            onRemove: () => ref.read(cartProvider.notifier).removeItem(item.id),
          ),
        ));
      }
    }
    return widgets;
  }

  Widget _buildSummaryCard(CartState cart) {
    const deliveryFee = 1750.0;
    final grandTotal = cart.totalPrice + deliveryFee;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Товары (${cart.items.length} наим.)',
                    style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                Text(formatCurrency(cart.totalPrice),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Доставка', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                Text(formatCurrency(deliveryFee),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderMid),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('К оплате:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
                Text(formatCurrency(grandTotal),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButton(CartState cart) {
    const deliveryFee = 1750.0;
    final grandTotal = cart.totalPrice + deliveryFee;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _PressableButton(
        onTap: _placeOrder,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x661A6B4A), blurRadius: 16, offset: Offset(0, 4))],
          ),
          child: Center(
            child: Text(
              'Оформить заказ — ${formatCurrency(grandTotal)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(item.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 2),
                Text('${item.price.toInt()} ₸ / ${item.unit}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          QuantityStepper(
            quantity: item.quantity,
            minOrder: 1,
            onChanged: onQuantityChanged,
            size: StepperSize.compact,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.total.toInt()} ₸',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
              Text('${item.quantity} ${item.unit}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableButton({required this.child, required this.onTap});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
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
        child: widget.child,
      ),
    );
  }
}
