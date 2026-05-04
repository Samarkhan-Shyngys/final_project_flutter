import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/top_bar.dart';

class _GroupItem {
  final String name, qty;
  final int kindergartens;
  const _GroupItem({required this.name, required this.qty, required this.kindergartens});
}

class _Group {
  final String emoji, name;
  final Color color, bgColor;
  final List<_GroupItem> items;
  const _Group({required this.emoji, required this.name, required this.color,
      required this.bgColor, required this.items});
}

const _kGroups = [
  _Group(
    emoji: '🥕', name: 'Овощи', color: AppColors.primary, bgColor: AppColors.primaryLight,
    items: [
      _GroupItem(name: 'Картофель',  qty: '285 кг', kindergartens: 8),
      _GroupItem(name: 'Морковь',    qty: '164 кг', kindergartens: 6),
      _GroupItem(name: 'Капуста',    qty: '198 кг', kindergartens: 7),
      _GroupItem(name: 'Лук',        qty: '112 кг', kindergartens: 5),
      _GroupItem(name: 'Свёкла',     qty: '95 кг',  kindergartens: 4),
    ],
  ),
  _Group(
    emoji: '🍎', name: 'Фрукты', color: AppColors.courierAmber, bgColor: AppColors.courierAmberLight,
    items: [
      _GroupItem(name: 'Яблоки',     qty: '210 кг', kindergartens: 8),
      _GroupItem(name: 'Бананы',     qty: '156 кг', kindergartens: 6),
      _GroupItem(name: 'Апельсины',  qty: '88 кг',  kindergartens: 5),
    ],
  ),
  _Group(
    emoji: '🧹', name: 'Хозтовары', color: AppColors.adminBlue, bgColor: AppColors.adminBlueLight,
    items: [
      _GroupItem(name: 'Мыло хозяйственное',  qty: '84 шт',  kindergartens: 7),
      _GroupItem(name: 'Средство для посуды', qty: '24 л',   kindergartens: 5),
      _GroupItem(name: 'Мешки для мусора',    qty: '36 уп',  kindergartens: 4),
    ],
  ),
];

class AggregatedOrdersScreen extends StatefulWidget {
  const AggregatedOrdersScreen({super.key});

  @override
  State<AggregatedOrdersScreen> createState() => _AggregatedOrdersScreenState();
}

class _AggregatedOrdersScreenState extends State<AggregatedOrdersScreen> {
  final List<bool> _expanded = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: TopBar(
        title: 'Сводный заказ',
        showBack: false,
        action: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.download_outlined, color: AppColors.adminBlue, size: 20),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _buildBanner(),
          const SizedBox(height: 16),
          ...List.generate(_kGroups.length, (i) => _buildGroup(i)),
          const SizedBox(height: 16),
          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('📊', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('16 марта 2026 — Все детские сады',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.adminBlue)),
              const SizedBox(height: 2),
              Text('12 учреждений • 11 позиций',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade300)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(int i) {
    final g = _kGroups[i];
    final expanded = _expanded[i];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded[i] = !expanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
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
                        Text('${g.items.length} наим.', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: g.bgColor, borderRadius: BorderRadius.circular(100)),
                    child: Text('${g.items.length} поз.', style: TextStyle(fontSize: 12, color: g.color, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.textMuted),
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
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                            Text('${item.kindergartens} д/с', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: g.bgColor, borderRadius: BorderRadius.circular(100)),
                        child: Text(item.qty, style: TextStyle(fontSize: 12, color: g.color, fontWeight: FontWeight.w600)),
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
        color: AppColors.adminBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x4D185FA5), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download_outlined, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text('Экспортировать в Excel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}
