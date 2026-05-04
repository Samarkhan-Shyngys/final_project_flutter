import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/top_bar.dart';

class _CheckItem {
  final String name, qty;
  bool checked;
  _CheckItem({required this.name, required this.qty, required this.checked});
}

class PurchaseChecklistScreen extends StatefulWidget {
  const PurchaseChecklistScreen({super.key});

  @override
  State<PurchaseChecklistScreen> createState() => _PurchaseChecklistScreenState();
}

class _PurchaseChecklistScreenState extends State<PurchaseChecklistScreen> {
  final List<_CheckItem> _vegetables = [
    _CheckItem(name: 'Картофель',  qty: '285 кг', checked: true),
    _CheckItem(name: 'Морковь',    qty: '164 кг', checked: true),
    _CheckItem(name: 'Капуста',    qty: '198 кг', checked: false),
    _CheckItem(name: 'Лук',        qty: '112 кг', checked: true),
    _CheckItem(name: 'Свёкла',     qty: '95 кг',  checked: false),
    _CheckItem(name: 'Огурцы',     qty: '48 кг',  checked: true),
  ];
  final List<_CheckItem> _fruits = [
    _CheckItem(name: 'Яблоки',     qty: '210 кг', checked: false),
    _CheckItem(name: 'Бананы',     qty: '156 кг', checked: true),
    _CheckItem(name: 'Апельсины',  qty: '88 кг',  checked: false),
    _CheckItem(name: 'Груши',      qty: '72 кг',  checked: false),
  ];
  final List<_CheckItem> _supplies = [
    _CheckItem(name: 'Мыло хозяйственное', qty: '84 шт',  checked: true),
    _CheckItem(name: 'Средство для посуды', qty: '24 л',  checked: true),
    _CheckItem(name: 'Перчатки латексные', qty: '40 пар', checked: false),
    _CheckItem(name: 'Мешки для мусора',   qty: '36 уп',  checked: false),
    _CheckItem(name: 'Жидкое мыло',        qty: '18 л',   checked: true),
  ];

  List<_CheckItem> get _all => [..._vegetables, ..._fruits, ..._supplies];

  int get _checkedCount => _all.where((i) => i.checked).length;
  int get _total => _all.length;
  bool get _allDone => _checkedCount == _total;

  void _toggle(List<_CheckItem> list, int index) {
    setState(() => list[index].checked = !list[index].checked);
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_checkedCount / _total * 100).round();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: TopBar(
        title: 'Закупочный лист',
        showBack: false,
        action: Text('$_checkedCount/$_total',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ),
      body: Column(
        children: [
          _buildProgress(pct),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _buildGroup('🥕 ОВОЩИ', _vegetables, AppColors.primary, AppColors.primaryLight),
                const SizedBox(height: 12),
                _buildGroup('🍎 ФРУКТЫ', _fruits, const Color(0xFFB45309), AppColors.courierAmberLight),
                const SizedBox(height: 12),
                _buildGroup('🧹 ХОЗТОВАРЫ', _supplies, AppColors.adminBlue, AppColors.adminBlueLight),
                if (_allDone) ...[
                  const SizedBox(height: 20),
                  _buildCompleteButton(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(int pct) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('16 марта 2026 · Рынок «Зелёный»',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text('$pct%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: _checkedCount / _total,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(String title, List<_CheckItem> items, Color color, Color bg) {
    final checked = items.where((i) => i.checked).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
              Text('$checked/${items.length}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ...List.generate(items.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GestureDetector(
            onTap: () => _toggle(items, i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: items[i].checked ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                      border: items[i].checked ? null : Border.all(color: const Color(0xFFD1D5DB), width: 2),
                    ),
                    child: items[i].checked
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[i].name,
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: items[i].checked ? AppColors.textMuted : AppColors.text,
                        decoration: items[i].checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: items[i].checked ? AppColors.primaryLight : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(items[i].qty,
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: items[i].checked ? AppColors.primary : const Color(0xFF374151),
                        )),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x661A6B4A), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text('Закупка завершена!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}
