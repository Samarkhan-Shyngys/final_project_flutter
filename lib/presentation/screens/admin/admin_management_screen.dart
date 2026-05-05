import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/kindergarten.dart';
import '../../providers/auth_notifier.dart';
import '../../widgets/top_bar.dart';
import 'kindergarten_detail_screen.dart';

class AdminManagementScreen extends ConsumerWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final kgs = auth.myKindergartens;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const TopBar(title: 'Управление', showBack: false),
      body: kgs.isEmpty
          ? _buildEmpty(context, ref)
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                ...kgs.map((kg) => _KindergartenCard(
                  kg: kg,
                  managers: auth.managersOf(kg.id),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => KindergartenDetailScreen(id: kg.id)),
                  ),
                )),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateKgSheet(context, ref),
        backgroundColor: AppColors.adminBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Добавить д/с', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏫', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          const Text('Нет детских садов',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 8),
          const Text('Добавьте детский сад для управления',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreateKgSheet(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Добавить детский сад'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateKgSheet(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateKgSheet(
        nameCtrl: nameCtrl, addrCtrl: addrCtrl, phoneCtrl: phoneCtrl,
        onSubmit: () async {
          if (nameCtrl.text.isNotEmpty) {
            await ref.read(authProvider.notifier).createKindergarten(
              name: nameCtrl.text,
              address: addrCtrl.text,
              phone: phoneCtrl.text,
            );
            if (context.mounted) Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class _KindergartenCard extends StatelessWidget {
  final Kindergarten kg;
  final List<AppUser> managers;
  final VoidCallback onTap;

  const _KindergartenCard({required this.kg, required this.managers, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.adminBlueLight, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('🏫', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kg.name, style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: 4),
                    if (kg.address.isNotEmpty)
                      Text(kg.address, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text('${managers.length} менеджеров',
                        style: const TextStyle(fontSize: 12, color: AppColors.adminBlue)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateKgSheet extends StatelessWidget {
  final TextEditingController nameCtrl, addrCtrl, phoneCtrl;
  final VoidCallback onSubmit;

  const _CreateKgSheet({
    required this.nameCtrl, required this.addrCtrl,
    required this.phoneCtrl, required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Добавить детский сад',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
            const SizedBox(height: 20),
            _SheetField(ctrl: nameCtrl, label: 'Название', hint: 'ДС №45 «Ромашка»'),
            const SizedBox(height: 12),
            _SheetField(ctrl: addrCtrl, label: 'Адрес', hint: 'ул. Ленина 12'),
            const SizedBox(height: 12),
            _SheetField(ctrl: phoneCtrl, label: 'Телефон', hint: '+7 727 123-45-67'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adminBlue, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Создать', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;

  const _SheetField({required this.ctrl, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
