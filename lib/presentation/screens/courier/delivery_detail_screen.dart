import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/status_chip.dart';
import '../../../domain/entities/order_status.dart';

class _DeliveryItem {
  final String name, qty;
  bool delivered;
  _DeliveryItem({required this.name, required this.qty, required this.delivered});
}

class _DeliveryData {
  final String name, address, phone, contact, time, orderId;
  final List<_DeliveryItem> items;
  const _DeliveryData({required this.name, required this.address, required this.phone,
      required this.contact, required this.time, required this.orderId, required this.items});
}

class DeliveryDetailScreen extends StatefulWidget {
  final String id;
  const DeliveryDetailScreen({super.key, required this.id});

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  bool _confirmed = false;
  late List<_DeliveryItem> _items;
  late _DeliveryData _data;

  @override
  void initState() {
    super.initState();
    _data = _getDelivery(widget.id);
    _items = _data.items;
  }

  _DeliveryData _getDelivery(String id) {
    switch (id) {
      case '1':
        return _DeliveryData(
          name: 'ДС №12 «Берёзка»', address: 'ул. Ленина 45',
          phone: '+7 777 123-45-67', contact: 'Петрова Мария Ивановна',
          time: '09:00', orderId: '2847',
          items: [
            _DeliveryItem(name: 'Картофель',  qty: '40 кг',  delivered: true),
            _DeliveryItem(name: 'Морковь',    qty: '15 кг',  delivered: true),
            _DeliveryItem(name: 'Яблоки',     qty: '25 кг',  delivered: false),
          ],
        );
      case '2':
        return _DeliveryData(
          name: 'ДС №7 «Солнышко»', address: 'ул. Пушкина 12',
          phone: '+7 777 234-56-78', contact: 'Смирнова Ксения Валерьевна',
          time: '11:00', orderId: '2846',
          items: [
            _DeliveryItem(name: 'Капуста',    qty: '30 кг',  delivered: false),
            _DeliveryItem(name: 'Свёкла',     qty: '20 кг',  delivered: false),
            _DeliveryItem(name: 'Бананы',     qty: '25 кг',  delivered: false),
            _DeliveryItem(name: 'Мыло',       qty: '12 шт',  delivered: false),
            _DeliveryItem(name: 'Средство',   qty: '5 л',    delivered: false),
          ],
        );
      default:
        return _DeliveryData(
          name: 'ДС №23 «Радуга»', address: 'ул. Гагарина 78',
          phone: '+7 777 345-67-89', contact: 'Козлова Наталья Анатольевна',
          time: '14:00', orderId: '2845',
          items: [
            _DeliveryItem(name: 'Лук',        qty: '12 кг',  delivered: false),
            _DeliveryItem(name: 'Апельсины',  qty: '20 кг',  delivered: false),
          ],
        );
    }
  }

  int get _deliveredCount => _items.where((i) => i.delivered).length;
  bool get _allDelivered => _deliveredCount == _items.length;

  @override
  Widget build(BuildContext context) {
    if (_confirmed) return _buildSuccess(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const TopBar(
        title: 'Детали доставки',
        action: StatusChip(status: OrderStatus.inDelivery, size: ChipSize.sm),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _buildKindergartenCard(),
          const SizedBox(height: 12),
          _buildChecklist(),
          const SizedBox(height: 16),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildKindergartenCard() {
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
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: AppColors.courierAmberLight, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('🏫', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_data.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(_data.address, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(children: [
            const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Expanded(child: Text(_data.contact, style: const TextStyle(fontSize: 13, color: AppColors.textMuted))),
          ]),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('tel:${_data.phone.replaceAll(' ', '').replaceAll('-', '')}')),
            child: Row(children: [
              const Icon(Icons.phone_outlined, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(_data.phone, style: const TextStyle(fontSize: 13, color: AppColors.primary)),
            ]),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text('Заказ #${_data.orderId} • ${_data.time}',
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ]),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Позиции', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
              Text('$_deliveredCount/${_items.length} передано',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          ..._items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _items[i].delivered = !_items[i].delivered),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: item.delivered ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.delivered ? const Color(0xFFBBF7D0) : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: item.delivered ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                          border: item.delivered ? null : Border.all(color: AppColors.borderMid, width: 2),
                        ),
                        child: item.delivered ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: item.delivered ? AppColors.textMuted : AppColors.text,
                            decoration: item.delivered ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.delivered ? const Color(0xFFDCFCE7) : AppColors.border,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(item.qty,
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: item.delivered ? const Color(0xFF16A34A) : AppColors.textMuted,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return GestureDetector(
      onTap: _allDelivered ? () => setState(() => _confirmed = true) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: _allDelivered ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _allDelivered
              ? const [BoxShadow(color: Color(0x661A6B4A), blurRadius: 16, offset: Offset(0, 4))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_allDelivered ? Icons.check_circle_outline : Icons.lock_outline,
                color: _allDelivered ? Colors.white : AppColors.textLight, size: 20),
            const SizedBox(width: 8),
            Text(
              _allDelivered ? 'Подтвердить доставку' : 'Отметьте все позиции',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600,
                color: _allDelivered ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              const Text('Доставка подтверждена!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 8),
              Text(_data.name,
                  style: const TextStyle(fontSize: 15, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text('Заказ #${_data.orderId} успешно доставлен',
                  style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => context.go('/courier'),
                child: Container(
                  height: 56, width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x661A6B4A), blurRadius: 16, offset: Offset(0, 4))],
                  ),
                  child: const Center(
                    child: Text('К доставкам',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
