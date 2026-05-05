import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/kindergarten.dart';
import '../../providers/auth_notifier.dart';
import '../../widgets/top_bar.dart';

class KindergartenDetailScreen extends ConsumerWidget {
  final String id;
  const KindergartenDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final kg = auth.kindergartenById(id);

    if (kg == null) {
      return const Scaffold(
        appBar: TopBar(title: 'Детский сад'),
        body: Center(child: Text('Не найдено')),
      );
    }

    final managers = auth.managersOf(id);
    final couriers = auth.couriersOf(id);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: TopBar(title: kg.name),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _buildInfoCard(kg),
          const SizedBox(height: 16),
          _buildSection(
            context: context,
            title: 'Менеджеры',
            emoji: '👔',
            users: managers,
            bgColor: AppColors.adminBlueLight,
            color: AppColors.adminBlue,
            onAdd: () => _showCreateManagerSheet(context, ref, kg.id),
          ),
          const SizedBox(height: 12),
          _buildSection(
            context: context,
            title: 'Курьеры',
            emoji: '🚚',
            users: couriers,
            bgColor: AppColors.courierAmberLight,
            color: AppColors.courierAmber,
            onAdd: () => _showCreateCourierSheet(context, ref, kg.id),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Kindergarten kg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.adminBlueLight, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('🏫', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kg.name, style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
                if (kg.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(child: Text(kg.address,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                  ]),
                ],
                if (kg.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(kg.phone, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ]),
                ],
              ],
            )),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title, required String emoji,
    required List<AppUser> users,
    required Color bgColor, required Color color,
    required VoidCallback onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(100)),
                  child: Text('${users.length}',
                      style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                ),
              ]),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.add, color: color, size: 18),
                ),
              ),
            ],
          ),
          if (users.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...users.map((u) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(18)),
                  child: Center(child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name, style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                    Text(u.email, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                )),
              ]),
            )),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Нет $title', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ),
        ],
      ),
    );
  }

  Future<void> _showCreateManagerSheet(BuildContext context, WidgetRef ref, String kgId) async {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl  = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateUserSheet(
        title: 'Добавить менеджера',
        color: AppColors.adminBlue,
        nameCtrl: nameCtrl, emailCtrl: emailCtrl, passCtrl: passCtrl,
        onSubmit: () async {
          if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
            await ref.read(authProvider.notifier).createManager(
              name: nameCtrl.text, email: emailCtrl.text,
              password: passCtrl.text, kindergartenId: kgId,
            );
            if (context.mounted) Navigator.pop(context);
          }
        },
      ),
    );
  }

  Future<void> _showCreateCourierSheet(BuildContext context, WidgetRef ref, String kgId) async {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl  = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateUserSheet(
        title: 'Добавить курьера',
        color: AppColors.courierAmber,
        nameCtrl: nameCtrl, emailCtrl: emailCtrl, passCtrl: passCtrl,
        onSubmit: () async {
          if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
            await ref.read(authProvider.notifier).createCourier(
              name: nameCtrl.text, email: emailCtrl.text,
              password: passCtrl.text, kindergartenIds: [kgId],
            );
            if (context.mounted) Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class _CreateUserSheet extends StatelessWidget {
  final String title;
  final Color color;
  final TextEditingController nameCtrl, emailCtrl, passCtrl;
  final VoidCallback onSubmit;

  const _CreateUserSheet({
    required this.title, required this.color,
    required this.nameCtrl, required this.emailCtrl,
    required this.passCtrl, required this.onSubmit,
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
            Text(title, style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
            const SizedBox(height: 20),
            _Field(ctrl: nameCtrl,  label: 'Имя',      hint: 'Иван Иванов'),
            const SizedBox(height: 12),
            _Field(ctrl: emailCtrl, label: 'Email',     hint: 'ivan@example.com'),
            const SizedBox(height: 12),
            _Field(ctrl: passCtrl,  label: 'Пароль',    hint: 'минимум 6 символов'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color, foregroundColor: Colors.white,
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

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;

  const _Field({required this.ctrl, required this.label, required this.hint});

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
