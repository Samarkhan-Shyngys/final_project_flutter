import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/order_notifier.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/top_bar.dart';
import '../../../domain/entities/order_entity.dart';
class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  String _search = '';
  String _filter = 'all';

  List<OrderEntity> _filtered(List<OrderEntity> all) {
    return all.where((o) {
      final matchSearch = _search.isEmpty ||
          o.id.contains(_search) ||
          o.kindergartenName.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filter == 'all' || o.status.name == _filter;
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final orderState = ref.watch(orderProvider);
    final kgIds = auth.myKindergartens.map((k) => k.id).toList();
    final adminOrders = orderState.ordersForKindergartens(kgIds);
    final filtered = _filtered(adminOrders);
    final totalAmount = filtered.fold(0.0, (s, o) => s + o.total);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: TopBar(
        title: 'Все заказы',
        showBack: false,
        action: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.calendar_today_outlined, color: AppColors.adminBlue, size: 18),
        ),
      ),
      body: Column(
        children: [
          _buildSearch(),
          _buildFilters(),
          _buildSummary(filtered.length, totalAmount),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _OrderCard(order: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SizedBox(
        height: 44,
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          decoration: InputDecoration(
            hintText: 'Поиск по заказам...',
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textLight),
            prefixIcon: const Icon(Icons.search, color: AppColors.textLight, size: 20),
            filled: true, fillColor: AppColors.bg,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = [
      ('all', 'Все'), ('draft', 'Черновик'), ('inProgress', 'В работе'),
      ('inDelivery', 'В доставке'), ('delivered', 'Выполнен'),
    ];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: filters.map((f) {
          final active = _filter == f.$1;
          return GestureDetector(
            onTap: () => setState(() => _filter = f.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.adminBlue : AppColors.border,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(f.$2, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.textMuted,
              )),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummary(int count, double total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Найдено: $count',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.adminBlue)),
            Text('${total.toInt()} ₸',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.adminBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('📋', style: TextStyle(fontSize: 48)),
        SizedBox(height: 12),
        Text('Заказов не найдено',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      ]),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('🏫', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
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
                  Text(order.kindergartenName,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text('${order.date} • ${order.itemCount} поз. • ${order.total.toInt()} ₸',
                      style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
