import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/section_label.dart';
import '../../widgets/top_bar.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  bool _orderPlaced = false;

  static final _currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

  void _placeOrder(CartProvider cart) {
    cart.clear();
    setState(() => _orderPlaced = true);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: _orderPlaced ? _buildSuccess(context) : _buildCartContent(context),
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
                width: 80,
                height: 80,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Заказ оформлен!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Заказ #2851',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Принят в обработку',
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                          ],
                        ),
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

  Widget _buildCartContent(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Column(
          children: [
            TopBar(
              title: 'Корзина',
              showBack: false,
              action: cart.items.isNotEmpty
                  ? TextButton(
                      onPressed: cart.clear,
                      child: const Text(
                        'Очистить',
                        style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                      ),
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
                      _buildCTAButton(cart, context),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🛒', style: TextStyle(fontSize: 56)),
          SizedBox(height: 16),
          Text(
            'Корзина пуста',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
          ),
          SizedBox(height: 8),
          Text(
            'Добавьте товары из каталога',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
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
                  Text(
                    'Дата поставки',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4B7C63)),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Среда, 19 марта',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedItems(CartProvider cart) {
    final groups = <String, List<CartItem>>{
      'vegetables': [],
      'fruits': [],
      'supplies': [],
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
          child: _CartItemCard(item: item, cart: cart),
        ));
      }
    }
    return widgets;
  }

  Widget _buildSummaryCard(CartProvider cart) {
    const deliveryFee = 350.0;
    final grandTotal = cart.totalPrice + deliveryFee;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Товары (${cart.items.length} наим.)',
                  style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
                Text(
                  _currencyFormat.format(cart.totalPrice),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Доставка', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                Text(
                  _currencyFormat.format(deliveryFee),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderMid),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('К оплате:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
                Text(
                  _currencyFormat.format(grandTotal),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButton(CartProvider cart, BuildContext context) {
    const deliveryFee = 350.0;
    final grandTotal = cart.totalPrice + deliveryFee;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _PressableButton(
        onTap: () => _placeOrder(cart),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x661A6B4A), blurRadius: 16, offset: Offset(0, 4)),
            ],
          ),
          child: Center(
            child: Text(
              'Оформить заказ — ${_currencyFormat.format(grandTotal)}',
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
  final CartProvider cart;

  const _CartItemCard({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.price.toInt()} ₽ / ${item.unit}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          QuantityStepper(
            quantity: item.quantity,
            minOrder: 1,
            onChanged: (val) => cart.updateQuantity(item.id, val),
            size: StepperSize.compact,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.total.toInt()} ₽',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              Text(
                '${item.quantity} ${item.unit}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => cart.removeItem(item.id),
            child: Container(
              width: 32,
              height: 32,
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
