import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final err = await context.read<AuthProvider>().login(_emailCtrl.text, _passCtrl.text);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildForm(),
              const SizedBox(height: 16),
              if (_error != null) _buildError(),
              const SizedBox(height: 8),
              _buildLoginButton(),
              const SizedBox(height: 20),
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
          child: const Center(child: Text('🌿', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 16),
        const Text('ДЕТПИТ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: AppColors.primary, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        const Text('Вход в систему', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 6),
        const Text('Система закупок для детских садов',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _Field(controller: _emailCtrl, label: 'Email', hint: 'example@mail.com',
            icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _Field(
          controller: _passCtrl, label: 'Пароль', hint: '••••••••',
          icon: Icons.lock_outline, obscure: _obscure,
          suffix: IconButton(
            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textLight, size: 20),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
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
        Text(_error!, style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444))),
      ]),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _loading ? null : _login,
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
              : const Text('Войти', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Нет аккаунта? ', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
        GestureDetector(
          onTap: () => context.push('/register'),
          child: const Text('Зарегистрироваться',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _Field({required this.controller, required this.label, required this.hint,
      required this.icon, this.obscure = false, this.suffix, this.keyboardType});

  @override
  Widget build(BuildContext context) {
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
            controller: controller,
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
}
