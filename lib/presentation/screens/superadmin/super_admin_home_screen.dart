import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/user_role.dart';
import '../../providers/auth_notifier.dart';
class SuperAdminHomeScreen extends ConsumerWidget {
  const SuperAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final admins = auth.admins;
    final allKg = auth.kindergartens;
    final allUsers = auth.users;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          children: [
            _buildHeader(context, ref, auth),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _buildStats(allKg.length, allUsers.length, admins.length),
                  const SizedBox(height: 20),
                  const Text('Администраторы',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
                  const SizedBox(height: 12),
                  if (admins.isEmpty)
                    const _EmptyState(
                      emoji: '👔', label: 'Нет администраторов',
                      sub: 'Добавьте первого администратора'),
                  ...admins.map((admin) => _AdminCard(
                    admin: admin,
                    kgCount: allKg.where((kg) => kg.adminId == admin.id).length,
                    mgrCount: allUsers.where((u) =>
                      u.role == UserRole.manager &&
                      u.createdByAdminId == admin.id).length,
                    onDelete: () => _confirmDeleteAdmin(context, ref, admin),
                  )),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateAdminSheet(context, ref),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Добавить admin', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AuthState auth) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Суперадмин', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 4),
              Text(auth.name, style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          )),
          GestureDetector(
            onTap: () {
              ref.read(authProvider.notifier).logout();
              context.go('/');
            },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.logout, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int kgCount, int usersCount, int adminsCount) {
    return Row(
      children: [
        _StatTile(label: 'Детских садов', value: '$kgCount',
            bg: AppColors.primaryLight, color: AppColors.primary),
        const SizedBox(width: 8),
        _StatTile(label: 'Администраторов', value: '$adminsCount',
            bg: AppColors.adminBlueLight, color: AppColors.adminBlue),
        const SizedBox(width: 8),
        _StatTile(label: 'Пользователей', value: '$usersCount',
            bg: AppColors.courierAmberLight, color: AppColors.courierAmber),
      ],
    );
  }

  Future<void> _confirmDeleteAdmin(BuildContext context, WidgetRef ref, AppUser admin) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Удалить администратора?'),
        content: Text('${admin.name} будет удалён из системы.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Удалить', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(authProvider.notifier).deleteUser(admin.id);
  }

  Future<void> _showCreateAdminSheet(BuildContext context, WidgetRef ref) async {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl  = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateAdminSheet(
        nameCtrl: nameCtrl, emailCtrl: emailCtrl, passCtrl: passCtrl,
        onSubmit: () async {
          if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
            await ref.read(authProvider.notifier).createAdmin(
              name: nameCtrl.text, email: emailCtrl.text, password: passCtrl.text,
            );
            if (context.mounted) Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final Color bg, color;
  const _StatTile({required this.label, required this.value, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final AppUser admin;
  final int kgCount, mgrCount;
  final VoidCallback onDelete;

  const _AdminCard({required this.admin, required this.kgCount,
      required this.mgrCount, required this.onDelete});

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
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.adminBlueLight, borderRadius: BorderRadius.circular(24)),
            child: Center(child: Text(
              admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.adminBlue))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(admin.name, style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 2),
              Text(admin.email, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Row(children: [
                _Badge(label: '$kgCount д/с', bg: AppColors.primaryLight, color: AppColors.primary),
                const SizedBox(width: 6),
                _Badge(label: '$mgrCount мен.', bg: AppColors.adminBlueLight, color: AppColors.adminBlue),
              ]),
            ],
          )),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
            onPressed: onDelete,
          ),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg, color;
  const _Badge({required this.label, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String emoji, label, sub;
  const _EmptyState({required this.emoji, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ]),
      ),
    );
  }
}

class _CreateAdminSheet extends StatelessWidget {
  final TextEditingController nameCtrl, emailCtrl, passCtrl;
  final VoidCallback onSubmit;

  const _CreateAdminSheet({
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
            const Text('Добавить администратора', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
            const SizedBox(height: 20),
            _Field(ctrl: nameCtrl,  label: 'Имя',    hint: 'Иван Иванов'),
            const SizedBox(height: 12),
            _Field(ctrl: emailCtrl, label: 'Email',   hint: 'admin@example.com'),
            const SizedBox(height: 12),
            _Field(ctrl: passCtrl,  label: 'Пароль',  hint: 'минимум 6 символов'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
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
