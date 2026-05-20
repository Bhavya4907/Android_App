import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import 'choice_screen.dart';
import 'profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  bool isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;

  static const Color _bg = Color(0xFF0D0D0D);
  static const Color _surface = Color(0xFF1A1A1A);
  static const Color _surfaceBorder = Color(0xFF2A2A2A);
  static const Color _accent = Color(0xFFEEEDFE);
  static const Color _accentText = Color(0xFF3C3489);

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _fadeController.reset();
    setState(() => isLogin = !isLogin);
    _fadeController.forward();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (isLogin) {
        await authService.login(
          emailController.text.trim(),
          passwordController.text,
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            _slideRoute(const ChoiceScreen()),
          );
        }
      } else {
        await authService.signUp(
          emailController.text.trim(),
          passwordController.text,
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            _slideRoute(const ProfileSetupScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFF1A1A1A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  PageRoute _slideRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildFields(),
                  const SizedBox(height: 28),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                  _buildToggle(),
                ],
              ),
            ),
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.school_outlined,
            color: _accentText,
            size: 22,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'CampusHub',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            isLogin ? 'Welcome back' : 'Create your account',
            key: ValueKey(isLogin),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.38),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFields() {
    return Column(
      children: [
        _InputField(
          controller: emailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _InputField(
          controller: passwordController,
          hint: 'Password',
          icon: Icons.lock_outlined,
          obscureText: _obscurePassword,
          suffix: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white.withOpacity(0.3),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: GestureDetector(
        onTap: _submit,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _loading ? _accent.withOpacity(0.6) : _accent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _accentText,
                    ),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      isLogin ? 'Log in' : 'Sign up',
                      key: ValueKey(isLogin),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _accentText,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Center(
      child: GestureDetector(
        onTap: _toggleMode,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: RichText(
            key: ValueKey(isLogin),
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.3),
              ),
              children: [
                TextSpan(
                  text: isLogin
                      ? "Don't have an account? "
                      : 'Already have an account? ',
                ),
                TextSpan(
                  text: isLogin ? 'Sign up' : 'Log in',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white.withOpacity(0.3)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.2),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}