import 'package:flutter/material.dart';

class MessScreen extends StatefulWidget {
  const MessScreen({super.key});

  @override
  State<MessScreen> createState() => _MessScreenState();
}

class _MessScreenState extends State<MessScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> hostels = [
    'Hostel 1',
    'Hostel 2',
    'Hostel 3',
    'Hostel 4',
    'Hostel 5',
  ];

  static const Color _bg = Color(0xFF0D0D0D);
  static const Color _surface = Color(0xFF1A1A1A);
  static const Color _surfaceBorder = Color(0xFF2A2A2A);
  // Mess screen uses amber identity from ChoiceScreen card
  static const Color _accent = Color(0xFFFAEEDA);
  static const Color _accentText = Color(0xFF633806);

  int _selectedHostel = 0;
  int _selectedMess = 0; // 0 = Mess A, 1 = Mess B

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _switchHostel(int index) {
    if (_selectedHostel == index) return;
    _fadeController.reset();
    setState(() => _selectedHostel = index);
    _fadeController.forward();
  }

  void _switchMess(int index) {
    if (_selectedMess == index) return;
    _fadeController.reset();
    setState(() => _selectedMess = index);
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _surfaceBorder),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
          ),
        ),
        title: const Text(
          'Mess Menu',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHostelSelector(),
          _buildMessToggle(),
          const SizedBox(height: 8),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _buildMenuCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostelSelector() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: hostels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = _selectedHostel == index;
          return GestureDetector(
            onTap: () => _switchHostel(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? _accent : _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? _accentText.withOpacity(0.35) : _surfaceBorder,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  hostels[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? _accentText : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _surfaceBorder),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _messTab('Mess A', 0),
            _messTab('Mess B', 1),
          ],
        ),
      ),
    );
  }

  Widget _messTab(String label, int index) {
    final selected = _selectedMess == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMess(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? _accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? _accentText : Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard() {
    final hostel = hostels[_selectedHostel];
    final mess = _selectedMess == 0 ? 'Mess A' : 'Mess B';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hostel,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mess,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restaurant_outlined, size: 14, color: _accentText),
                    const SizedBox(width: 6),
                    Text(
                      "Today's menu",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _accentText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _mealCard(
            meal: 'Breakfast',
            time: '7:30 – 9:30 AM',
            icon: Icons.wb_sunny_outlined,
            menu: 'Loading...',
            color: const Color(0xFFFAEEDA),
            textColor: const Color(0xFF633806),
          ),
          const SizedBox(height: 12),
          _mealCard(
            meal: 'Lunch',
            time: '12:00 – 2:00 PM',
            icon: Icons.light_mode_outlined,
            menu: 'Loading...',
            color: const Color(0xFFE1F5EE),
            textColor: const Color(0xFF085041),
          ),
          const SizedBox(height: 12),
          _mealCard(
            meal: 'Dinner',
            time: '7:00 – 9:00 PM',
            icon: Icons.nightlight_outlined,
            menu: 'Loading...',
            color: const Color(0xFFEEEDFE),
            textColor: const Color(0xFF3C3489),
          ),
        ],
      ),
    );
  }

  Widget _mealCard({
    required String meal,
    required String time,
    required IconData icon,
    required String menu,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: textColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: _surfaceBorder,
          ),
          const SizedBox(height: 14),
          Text(
            menu,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.55),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}