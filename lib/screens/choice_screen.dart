import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'buy_screen.dart';
import 'profile_screen.dart';
import 'sell_screen.dart';
import 'admin_requests_screen.dart';
import 'event_screen.dart';
import 'mess_screen.dart';
import 'clubs_screen.dart';

class ChoiceScreen extends StatefulWidget {
  const ChoiceScreen({super.key});

  @override
  State<ChoiceScreen> createState() => _ChoiceScreenState();
}

class _ChoiceScreenState extends State<ChoiceScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  final List<Animation<double>> _cardAnimations = [];
  final int _cardCount = 8;

  static const Color _bg = Color(0xFF0D0D0D);
  static const Color _surface = Color(0xFF1A1A1A);
  static const Color _surfaceBorder = Color(0xFF2A2A2A);

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    for (int i = 0; i < _cardCount; i++) {
      final start = (i / _cardCount) * 0.6;
      final end = start + 0.4;
      _cardAnimations.add(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end.clamp(0, 1), curve: Curves.easeOutCubic),
        ),
      );
    }

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isAdmin = currentUid == "81pFdvPilzem9QyYL2fjaaMqtRs2";

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                childAspectRatio: 0.95,
                children: [
                  _animatedCard(0, _DashCard(
                    tag: 'Marketplace',
                    title: 'Buy',
                    subtitle: 'Browse listings',
                    icon: Icons.shopping_bag_outlined,
                    bg: const Color(0xFFEEEDFE),
                    iconColor: const Color(0xFF3C3489),
                    textColor: const Color(0xFF3C3489),
                    tagColor: const Color(0xFF534AB7).withOpacity(0.15),
                    screen: const BuyScreen(),
                  )),
                  _animatedCard(1, _DashCard(
                    tag: 'Marketplace',
                    title: 'Sell',
                    subtitle: 'Post an item',
                    icon: Icons.sell_outlined,
                    bg: _surface,
                    border: _surfaceBorder,
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    tagColor: _surfaceBorder,
                    tagTextColor: const Color(0xFF888780),
                    screen: const SellScreen(),
                  )),
                  _animatedCard(2, _DashCard(
                    tag: 'Campus',
                    title: 'Events',
                    subtitle: "What's on",
                    icon: Icons.calendar_today_outlined,
                    bg: const Color(0xFFE1F5EE),
                    iconColor: const Color(0xFF085041),
                    textColor: const Color(0xFF085041),
                    tagColor: const Color(0xFF0F6E56).withOpacity(0.15),
                    screen: const EventsScreen(),
                  )),
                  _animatedCard(3, _DashCard(
                    tag: 'Social',
                    title: 'Clubs',
                    subtitle: 'Join a club',
                    icon: Icons.groups_outlined,
                    bg: const Color(0xFFFAECE7),
                    iconColor: const Color(0xFF712B13),
                    textColor: const Color(0xFF712B13),
                    tagColor: const Color(0xFF993C1D).withOpacity(0.15),
                    screen: const ClubsScreen(),
                  )),
                  _animatedCard(4, _DashCard(
                    tag: 'Food',
                    title: 'Mess',
                    subtitle: "Today's menu",
                    icon: Icons.restaurant_outlined,
                    bg: const Color(0xFFFAEEDA),
                    iconColor: const Color(0xFF633806),
                    textColor: const Color(0xFF633806),
                    tagColor: const Color(0xFF854F0B).withOpacity(0.15),
                    screen: const MessScreen(),
                  )),
                  _animatedCard(5, _DashCard(
                    tag: 'Coming soon',
                    title: 'Lost & Found',
                    subtitle: '',
                    icon: Icons.search_outlined,
                    bg: _surface,
                    border: _surfaceBorder,
                    iconColor: const Color(0xFF555555),
                    textColor: const Color(0xFF555555),
                    tagColor: _surfaceBorder,
                    tagTextColor: const Color(0xFF555555),
                    disabled: true,
                  )),
                  if (isAdmin)
                    _animatedCard(6, _DashCard(
                      tag: 'Admin',
                      title: 'Admin requests',
                      subtitle: 'Review pending',
                      icon: Icons.admin_panel_settings_outlined,
                      bg: const Color(0xFFE24B4A),
                      iconColor: const Color(0xFF501313),
                      textColor: const Color(0xFF501313),
                      tagColor: const Color(0xFFA32D2D).withOpacity(0.2),
                      screen: const AdminRequestsScreen(),
                      wide: true,
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CampusHub',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The 2nd most important hub',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.35),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
// Change this:
GestureDetector(
  onTap: () => Navigator.push(
    context,
    _slideRoute(const ProfileScreen()),  // ❌ _slideRoute is in _ChoiceScreenState, this is fine here
  ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _surface,
                shape: BoxShape.circle,
                border: Border.all(color: _surfaceBorder, width: 1.5),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF888780),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _surfaceBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: Colors.white.withOpacity(0.25)),
            const SizedBox(width: 10),
            Text(
              'Search campus...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedCard(int index, Widget child) {
    final anim = index < _cardAnimations.length
        ? _cardAnimations[index]
        : _cardAnimations.last;
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - anim.value)),
          child: child,
        ),
      ),
    );
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
}

class _DashCard extends StatefulWidget {
  final String tag;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bg;
  final Color? border;
  final Color iconColor;
  final Color textColor;
  final Color tagColor;
  final Color? tagTextColor;
  final Widget? screen;
  final bool disabled;
  final bool wide;

  const _DashCard({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bg,
    this.border,
    required this.iconColor,
    required this.textColor,
    required this.tagColor,
    this.tagTextColor,
    this.screen,
    this.disabled = false,
    this.wide = false,
  });

  @override
  State<_DashCard> createState() => _DashCardState();
}

class _DashCardState extends State<_DashCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.disabled || widget.screen == null) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.screen!,
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

  @override
  Widget build(BuildContext context) {
    final tagText = widget.tagTextColor ?? widget.iconColor;

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.disabled) _pressController.forward();
      },
      onTapUp: (_) {
        _pressController.reverse();
        _onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Opacity(
          opacity: widget.disabled ? 0.45 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: widget.bg,
              borderRadius: BorderRadius.circular(20),
              border: widget.border != null
                  ? Border.all(color: widget.border!, width: 1)
                  : null,
            ),
            padding: widget.wide
                ? const EdgeInsets.symmetric(horizontal: 18, vertical: 16)
                : const EdgeInsets.fromLTRB(14, 16, 14, 14),
            child: widget.wide ? _wideContent(tagText) : _stackedContent(tagText),
          ),
        ),
      ),
    );
  }

  Widget _stackedContent(Color tagText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Tag(label: widget.tag, bg: widget.tagColor, textColor: tagText),
        const SizedBox(height: 10),
        Icon(widget.icon, color: widget.iconColor, size: 26),
        const Spacer(),
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: widget.textColor,
            height: 1.2,
          ),
        ),
        if (widget.subtitle.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            widget.subtitle,
            style: TextStyle(
              fontSize: 11,
              color: widget.textColor.withOpacity(0.55),
            ),
          ),
        ],
      ],
    );
  }

  Widget _wideContent(Color tagText) {
    return Row(
      children: [
        Icon(widget.icon, color: widget.iconColor, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Tag(label: widget.tag, bg: widget.tagColor, textColor: tagText),
            const SizedBox(height: 4),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: widget.textColor,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (widget.subtitle.isNotEmpty)
          Text(
            '${widget.subtitle} →',
            style: TextStyle(
              fontSize: 11,
              color: widget.textColor.withOpacity(0.55),
            ),
          ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const _Tag({
    required this.label,
    required this.bg,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}