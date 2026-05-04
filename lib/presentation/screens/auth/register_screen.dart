import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  String _role = 'manager';

  static const _roles = [
    ('manager', '📋 Менеджер', AppColors.primary, AppColors.primaryLight),
    ('admin', '📊 Администратор', AppColors.adminBlue, AppColors.adminBlueLight),
    ('courier', '🚚 Курьер', AppColors.courierAmber, AppColors.courierAmberLight),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    final err = await context.read<AuthProvider>().register(
        _nameCtrl.text, _emailCtrl.text, _passCtrl.text, _role);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Center(
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.chevron_left, color: AppColors.text),
            ),
          ),
        ),
        title: const Text('Регистрация',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildFields(),
              const SizedBox(height: 20),
              _buildRoleSelect(),
              const SizedBox(height: 16),
              if (_error != null) ...[
                _buildError(),
                const SizedBox(height: 12),
              ],
              _buildRegisterButton(),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Уже есть аккаунт? ', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Text('Войти',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFields() {
    return Column(children: [
      _buildField(_nameCtrl, 'Имя и фамилия', 'Алина Иванова', Icons.person_outline),
      const SizedBox(height: 12),
      _buildField(_emailCtrl, 'Email', 'example@mail.com', Icons.email_outlined,
          keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 12),
      _buildField(_passCtrl, 'Пароль', '••••••••', Icons.lock_outline, obscure: _obscure,
          suffix: IconButton(
            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textLight, size: 20),
            onPressed: () => setState(() => _obscure = !_obscure),
          )),
    ]);
  }

  Widget _buildField(TextEditingController ctrl, String label, String hint, IconData icon,
      {bool obscure = false, Widget? suffix, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: TextField(
            controller: ctrl,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textLight),
              prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
              suffixIcon: suffix,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true, fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Роль', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 10),
        Row(
          children: _roles.map((r) {
            final active = _role == r.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _role = r.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: active ? r.$4 : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: active ? r.$3 : AppColors.borderMid, width: 1.5),
                    boxShadow: active ? null :
                        const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Column(children: [
                    Text(r.$2.split(' ').first, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(r.$2.split(' ').last,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: active ? r.$3 : AppColors.textMuted)),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(_error!, style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444)))),
      ]),
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: _loading ? null : _register,
      child: Container(
        height: 56, width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x661A6B4A), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Center(
          child: _loading
              ? const SizedBox(width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Создать аккаунт',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}
