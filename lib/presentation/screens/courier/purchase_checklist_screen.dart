import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/order_notifier.dart';
import '../../widgets/top_bar.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/order_status.dart';

class _CheckItem {
  final String name, unit;
  final int totalQty;
  _CheckItem({required this.name, required this.unit, required this.totalQty});
}

class _Group {
  final String emoji, name;
  final List<_CheckItem> items;
  final Color color, bgColor;
  _Group({required this.emoji, required this.name, required this.items,
          required this.color, required this.bgColor});
}

class PurchaseChecklistScreen extends ConsumerStatefulWidget {
  const PurchaseChecklistScreen({super.key});

  @override
  ConsumerState<PurchaseChecklistScreen> createState() => _PurchaseChecklistScreenState();
}

class _PurchaseChecklistScreenState extends ConsumerState<PurchaseChecklistScreen> {
  final Map<String, bool> _checked = {};

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final activeOrders = orderState.orders
        .where((o) => o.status == OrderStatus.inDelivery || o.status == OrderStatus.inProgress)
        .toList();

    final Map<String, int> qtyMap = {};
    final Map<String, String> unitMap = { for (final p in kProducts) p.name: p.unit };
    for (final order in activeOrders) {
      for (final item in order.items) {
        qtyMap.update(item.name, (v) => v + item.quantity, ifAbsent: () => item.quantity);
        unitMap.putIfAbsent(item.name, () => item.unit);
      }
    }

    final nameToCat = { for (final p in kProducts) p.name: p.category };
    final Map<String, List<_CheckItem>> byCat = {};
    for (final entry in qtyMap.entries) {
      final cat = nameToCat[entry.key] ?? 'other';
      byCat.putIfAbsent(cat, () => []);
      byCat[cat]!.add(_CheckItem(
        name: entry.key, unit: unitMap[entry.key] ?? '', totalQty: entry.value));
    }

    final groups = <_Group>[
      if (byCat['vegetables'] != null)
        _Group(emoji: '🥕', name: 'Овощи', items: byCat['vegetables']!,
               color: AppColors.primary, bgColor: AppColors.primaryLight),
      if (byCat['fruits'] != null)
        _Group(emoji: '🍎', name: 'Фрукты', items: byCat['fruits']!,
               color: AppColors.courierAmber, bgColor: AppColors.courierAmberLight),
      if (byCat['supplies'] != null)
        _Group(emoji: '🧹', name: 'Хозтовары', items: byCat['supplies']!,
               color: AppColors.adminBlue, bgColor: AppColors.adminBlueLight),
    ];

    final allItems = groups.expand((g) => g.items).toList();
    final totalCount = allItems.length;
    final checkedCount = allItems.where((i) => _checked[i.name] == true).length;
    final pct = totalCount == 0 ? 0 : (checkedCount * 100 ~/ totalCount);
    final allDone = totalCount > 0 && checkedCount == totalCount;

    final now = DateTime.now();
    final months = ['января','февраля','марта','апреля','мая','июня',
                    'июля','августа','сентября','октября','ноября','декабря'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: TopBar(
        title: 'Закупочный лист',
        showBack: false,
        action: Text('$checkedCount/$totalCount', style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('$dateStr · Рынок «Зелёный»',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  Text('$pct%', style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ]),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: totalCount == 0 ? 0 : checkedCount / totalCount,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(100),
                ),
              ],
            ),
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(scrollbars: false),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  if (allItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('🛒', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text('Нет активных заказов',
                              style: TextStyle(fontSize: 15, color: AppColors.textMuted)),
                        ]),
                      ),
                    )
                  else
                    ...groups.expand((g) => [
                      _buildGroupHeader(g),
                      ...g.items.map((item) => _buildCheckItem(item, g)),
                    ]),
                  if (allDone) ...[
                    const SizedBox(height: 16),
                    _buildDoneButton(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(_Group g) {
    final checkedInGroup = g.items.where((i) => _checked[i.name] == true).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: g.bgColor, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${g.emoji} ${g.name}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: g.color)),
            Text('$checkedInGroup/${g.items.length}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: g.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(_CheckItem item, _Group g) {
    final done = _checked[item.name] == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _checked[item.name] = !done),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
            color: AppColors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: done ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(8),
                border: done ? null : Border.all(color: const Color(0xFFD1D5DB), width: 2),
              ),
              child: done ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
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
                color: done ? AppColors.primaryLight : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('${item.totalQty} ${item.unit}', style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: done ? AppColors.primary : const Color(0xFF374151),
              )),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x661A6B4A), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text('Закупка завершена!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}
