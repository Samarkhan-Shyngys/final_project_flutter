import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/order_status.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/top_bar.dart';

class _OrderItem {
  final String name;
  final int qty;
  final String unit;
  final double price;

  const _OrderItem({required this.name, required this.qty, required this.unit, required this.price});

  double get total => price * qty;
}

class _OrderDetails {
  final String id;
  final OrderStatus status;
  final String date;
  final String kindergarten;
  final String address;
  final String phone;
  final String manager;
  final List<_OrderItem> items;

  const _OrderDetails({
    required this.id,
    required this.status,
    required this.date,
    required this.kindergarten,
    required this.address,
    required this.phone,
    required this.manager,
    required this.items,
  });

  double get total => items.fold(0.0, (s, i) => s + i.total);
}

const _kOrdersData = {
  '2847': _OrderDetails(
    id: '2847',
    status: OrderStatus.inDelivery,
    date: '14.03.2024 09:15',
    kindergarten: 'ДС №45 «Ромашка»',
    address: 'ул. Ленина 12',
    phone: '+7 727 123-45-67',
    manager: 'Алина Иванова',
    items: [
      _OrderItem(name: 'Картофель', qty: 20, unit: 'кг', price: 45),
      _OrderItem(name: 'Морковь', qty: 10, unit: 'кг', price: 38),
      _OrderItem(name: 'Яблоки', qty: 15, unit: 'кг', price: 65),
      _OrderItem(name: 'Мыло хозяйственное', qty: 6, unit: 'шт', price: 25),
    ],
  ),
  '2831': _OrderDetails(
    id: '2831',
    status: OrderStatus.delivered,
    date: '12.03.2024',
    kindergarten: 'ДС №45 «Ромашка»',
    address: 'ул. Ленина 12',
    phone: '+7 727 123-45-67',
    manager: 'Алина Иванова',
    items: [
      _OrderItem(name: 'Капуста', qty: 15, unit: 'кг', price: 32),
      _OrderItem(name: 'Лук', qty: 8, unit: 'кг', price: 29),
      _OrderItem(name: 'Бананы', qty: 12, unit: 'кг', price: 72),
    ],
  ),
  '2818': _OrderDetails(
    id: '2818',
    status: OrderStatus.inProgress,
    date: '10.03.2024',
    kindergarten: 'ДС №45 «Ромашка»',
    address: 'ул. Ленина 12',
    phone: '+7 727 123-45-67',
    manager: 'Алина Иванова',
    items: [
      _OrderItem(name: 'Картофель', qty: 25, unit: 'кг', price: 45),
      _OrderItem(name: 'Свёкла', qty: 10, unit: 'кг', price: 35),
      _OrderItem(name: 'Огурцы', qty: 8, unit: 'кг', price: 85),
      _OrderItem(name: 'Средство', qty: 3, unit: 'л', price: 120),
      _OrderItem(name: 'Перчатки', qty: 10, unit: 'пара', price: 45),
    ],
  ),
};

class OrderDetailsScreen extends StatelessWidget {
  final String id;

  const OrderDetailsScreen({super.key, required this.id});

  static final _currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final order = _kOrdersData[id];
    if (order == null) {
      return const Scaffold(
        appBar: TopBar(title: 'Заказ не найден', showBack: true),
        body: Center(child: Text('Заказ не найден')),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: TopBar(
          title: 'Заказ #${order.id}',
          showBack: true,
          action: StatusChip(status: order.status, size: ChipSize.md),
        ),
        body: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
          child: ListView(
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
                _buildCancelButton(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKindergartenCard(_OrderDetails order) {
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('🏫', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.kindergarten,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          order.address,
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          order.phone,
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
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
              Text(
                'Создан: ${order.date}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              Text(
                'Менеджер: ${order.manager}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(_OrderDetails order) {
    final steps = [
      ('Создан', '09:00'),
      ('Подтверждён', '09:15'),
      ('В работе', '10:30'),
      ('В доставке', '14:00'),
      ('Выполнен', ''),
    ];

    int activeStep;
    switch (order.status) {
      case OrderStatus.draft:
        activeStep = 0;
        break;
      case OrderStatus.inProgress:
        activeStep = 2;
        break;
      case OrderStatus.inDelivery:
        activeStep = 3;
        break;
      case OrderStatus.delivered:
        activeStep = 4;
        break;
    }

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
          const Text(
            'Статус заказа',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final isDone = i < activeStep;
            final isActive = i == activeStep;
            final isLast = i == steps.length - 1;
            return _TimelineStep(
              label: steps[i].$1,
              time: steps[i].$2,
              isDone: isDone,
              isActive: isActive,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemsCard(_OrderDetails order) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Состав заказа',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ...order.items.map((item) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                '${item.qty} ${item.unit} × ${item.price.toInt()} ₽',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _currencyFormat.format(item.total),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                ],
              )),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Итого',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text),
                ),
                Text(
                  _currencyFormat.format(order.total),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return _PressableButton(
      onTap: () {},
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Отменить заказ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final String time;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  const _TimelineStep({
    required this.label,
    required this.time,
    required this.isDone,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _buildCircle(),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: isDone ? AppColors.primary : AppColors.borderMid,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isDone || isActive ? AppColors.text : AppColors.textLight,
                ),
              ),
              if (time.isNotEmpty)
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircle() {
    if (isDone) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    } else if (isActive) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: const Center(
          child: SizedBox(
            width: 12,
            height: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
        child: const Center(
          child: SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppColors.textLight, shape: BoxShape.circle),
            ),
          ),
        ),
      );
    }
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
