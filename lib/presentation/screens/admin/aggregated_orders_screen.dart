import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/product.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/order_notifier.dart';
import '../../widgets/top_bar.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/order_status.dart';

class _AggItem {
  final String name, unit;
  final int totalQty, kindergartenCount;
  const _AggItem({
    required this.name, required this.unit,
    required this.totalQty, required this.kindergartenCount,
  });
}

class _AggGroup {
  final String category, emoji, name;
  final Color color, bgColor;
  final List<_AggItem> items;
  const _AggGroup({
    required this.category, required this.emoji, required this.name,
    required this.color, required this.bgColor, required this.items,
  });
}

const _catMeta = {
  'vegetables': (emoji: '🥕', name: 'Овощи',      color: AppColors.primary,      bg: AppColors.primaryLight),
  'fruits':     (emoji: '🍎', name: 'Фрукты',     color: AppColors.courierAmber, bg: AppColors.courierAmberLight),
  'supplies':   (emoji: '🧹', name: 'Хозтовары',  color: AppColors.adminBlue,    bg: AppColors.adminBlueLight),
};

List<_AggGroup> _aggregate(List<OrderEntity> orders) {
  final active = orders.where((o) => o.status != OrderStatus.delivered);
  final Map<String, Map<String, int>> itemMap = {};
  final Map<String, String> nameToUnit = { for (final p in kProducts) p.name: p.unit };
  final Map<String, String> nameToCategory = { for (final p in kProducts) p.name: p.category };

  for (final order in active) {
    for (final item in order.items) {
      itemMap.putIfAbsent(item.name, () => {});
      itemMap[item.name]!.update(
        order.kindergartenName, (v) => v + item.quantity, ifAbsent: () => item.quantity,
      );
      nameToUnit.putIfAbsent(item.name, () => item.unit);
    }
  }

  final Map<String, List<_AggItem>> byCategory = {};
  for (final entry in itemMap.entries) {
    final cat = nameToCategory[entry.key] ?? 'other';
    final totalQty = entry.value.values.fold(0, (s, v) => s + v);
    byCategory.putIfAbsent(cat, () => []);
    byCategory[cat]!.add(_AggItem(
      name: entry.key, unit: nameToUnit[entry.key] ?? '',
      totalQty: totalQty, kindergartenCount: entry.value.length,
    ));
  }

  final groups = <_AggGroup>[];
  for (final cat in ['vegetables', 'fruits', 'supplies']) {
    if (!byCategory.containsKey(cat)) continue;
    final meta = _catMeta[cat]!;
    groups.add(_AggGroup(
      category: cat, emoji: meta.emoji, name: meta.name,
      color: meta.color, bgColor: meta.bg, items: byCategory[cat]!,
    ));
  }
  if (byCategory.containsKey('other')) {
    groups.add(_AggGroup(
      category: 'other', emoji: '📦', name: 'Прочее',
      color: AppColors.textMuted, bgColor: AppColors.border,
      items: byCategory['other']!,
    ));
  }
  return groups;
}

class AggregatedOrdersScreen extends ConsumerStatefulWidget {
  const AggregatedOrdersScreen({super.key});

  @override
  ConsumerState<AggregatedOrdersScreen> createState() => _AggregatedOrdersScreenState();
}

class _AggregatedOrdersScreenState extends ConsumerState<AggregatedOrdersScreen> {
  final Map<int, bool> _expanded = {0: true};

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final orderState = ref.watch(orderProvider);
    final kgIds = auth.myKindergartens.map((k) => k.id).toList();
    final orders = orderState.ordersForKindergartens(kgIds);
    final groups = _aggregate(orders);
    final activeOrders = orders.where((o) => o.status != OrderStatus.delivered);
    final kgCount = activeOrders.map((o) => o.kindergartenName).toSet().length;
    final itemCount = groups.fold(0, (s, g) => s + g.items.length);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: TopBar(
        title: 'Сводный заказ',
        showBack: false,
        action: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.download_outlined, color: AppColors.adminBlue, size: 20),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _buildBanner(kgCount, itemCount),
          const SizedBox(height: 16),
          if (groups.isEmpty)
            _buildEmpty()
          else
            ...List.generate(groups.length, (i) => _buildGroup(groups, i)),
          const SizedBox(height: 16),
          if (groups.isNotEmpty) _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildBanner(int kgCount, int itemCount) {
    final now = DateTime.now();
    final months = ['января','февраля','марта','апреля','мая','июня',
                    'июля','августа','сентября','октября','ноября','декабря'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Text('📊', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$dateStr — Все детские сады',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.adminBlue)),
              const SizedBox(height: 2),
              Text(
                kgCount == 0 ? 'Нет активных заказов'
                    : '${formatNumber(kgCount)} учреждений • $itemCount позиций',
                style: TextStyle(fontSize: 12, color: Colors.blue.shade300),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('📦', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Нет активных заказов',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          SizedBox(height: 4),
          Text('Сводный заказ формируется из заказов\nсо статусом «В работе» и «В доставке»',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textLight)),
        ]),
      ),
    );
  }

  Widget _buildGroup(List<_AggGroup> groups, int i) {
    final g = groups[i];
    final expanded = _expanded[i] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded[i] = !expanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: g.bgColor, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(g.emoji, style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                        Text('${g.items.length} наим.',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: g.bgColor, borderRadius: BorderRadius.circular(100)),
                    child: Text('${g.items.length} поз.',
                        style: TextStyle(fontSize: 12, color: g.color, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: g.items.map((item) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                            Text('${item.kindergartenCount} д/с',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: g.bgColor, borderRadius: BorderRadius.circular(100)),
                        child: Text('${item.totalQty} ${item.unit}',
                            style: TextStyle(fontSize: 12, color: g.color, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.adminBlue, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x4D185FA5), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download_outlined, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text('Экспортировать в Excel',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}
