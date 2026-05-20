import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import 'choice_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final branchController = TextEditingController();
  final yearController = TextEditingController();
  final userService = UserService();

  bool _isSaving = false;

  static const Color _bg = Color(0xFF0D0D0D);
  static const Color _surface = Color(0xFF1A1A1A);
  static const Color _surfaceBorder = Color(0xFF2A2A2A);
  static const Color _accent = Color(0xFFEEEDFE);
  static const Color _accentText = Color(0xFF3C3489);

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Year dropdown options
  final List<String> _yearOptions = ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year'];
  String? _selectedYear;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    nameController.dispose();
    branchController.dispose();
    yearController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (nameController.text.trim().isEmpty ||
        branchController.text.trim().isEmpty ||
        _selectedYear == null) {
      _showSnack('Please fill all fields');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await userService.createUser(
        uid: uid,
        name: nameController.text.trim(),
        branch: branchController.text.trim(),
        year: _selectedYear!,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ChoiceScreen(),
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
          ),
        );
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: _surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _surfaceBorder),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildFields(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
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
          child: const Icon(Icons.person_outline, color: _accentText, size: 22),
        ),
        const SizedBox(height: 20),
        const Text(
          'Set up\nyour profile',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tell us a bit about yourself so others\ncan find and contact you.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.35),
            height: 1.55,
          ),
        ),
      ],
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Personal info'),
        const SizedBox(height: 12),
        _InputField(
          controller: nameController,
          hint: 'Full name',
          icon: Icons.badge_outlined,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 10),
        _InputField(
          controller: branchController,
          hint: 'Branch (e.g. CSE, ECE)',
          icon: Icons.account_tree_outlined,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 24),
        _sectionLabel('Academic year'),
        const SizedBox(height: 12),
        _buildYearSelector(),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.35),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildYearSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _yearOptions.map((year) {
        final selected = _selectedYear == year;
        return GestureDetector(
          onTap: () => setState(() => _selectedYear = year),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? _accent : _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? _accentText.withOpacity(0.4) : _surfaceBorder,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              year,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? _accentText : Colors.white.withOpacity(0.55),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: GestureDetector(
        onTap: _save,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isSaving ? _accent.withOpacity(0.6) : _accent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _accentText,
                    ),
                  )
                : const Text(
                    'Save & continue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _accentText,
                      letterSpacing: 0.2,
                    ),
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
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
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
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              style: const TextStyle(fontSize: 14, color: Colors.white),
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
        ],
      ),
    );
  }
}