import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/club_data.dart';
import 'club_feed_screen.dart';

// ── Palette (mirrors the rest of the app) ────────────────────────────────────
const _bg = Color(0xFF0E0E14);
const _surface = Color(0xFF16161F);
const _card = Color(0xFF1C1C28);
const _border = Color(0x12FFFFFF);
const _accent = Color(0xFFFF6B35);
const _textPrimary = Color(0xFFF0EEF8);
const _textSecondary = Color(0xFF9896AA);
const _textMuted = Color(0xFF5C5B6B);

// ── Per-club accent colours — cycles through the palette ─────────────────────
const _clubColors = [
  (bg: Color(0x267C6EE6), fg: Color(0xFF7C6EE6)),   // purple
  (bg: Color(0x26FF6B35), fg: Color(0xFFFF6B35)),   // orange
  (bg: Color(0x154ADE80), fg: Color(0xFF4ADE80)),   // green
  (bg: Color(0x26E879F9), fg: Color(0xFFE879F9)),   // pink
  (bg: Color(0x26FBBF24), fg: Color(0xFFFBBF24)),   // amber
  (bg: Color(0x2638BDF8), fg: Color(0xFF38BDF8)),   // sky
];

({Color bg, Color fg}) _colorFor(int index) =>
    _clubColors[index % _clubColors.length];

// ── Icon set — one per slot, cycling ─────────────────────────────────────────
const _clubIcons = [
  Icons.music_note_rounded,
  Icons.computer_rounded,
  Icons.sports_soccer_rounded,
  Icons.palette_outlined,
  Icons.camera_alt_outlined,
  Icons.science_outlined,
  Icons.theater_comedy_outlined,
  Icons.menu_book_outlined,
];

IconData _iconFor(int index) => _clubIcons[index % _clubIcons.length];

// ─────────────────────────────────────────────────────────────────────────────
// ClubsScreen
// ─────────────────────────────────────────────────────────────────────────────
class ClubsScreen extends StatelessWidget {
  const ClubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppBar(),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: clubs.length,
                  itemBuilder: (context, index) {
                    return _ClubCard(
                      club: clubs[index],
                      index: index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXPLORE',
                  style: TextStyle(
                    fontSize: 10,
                    color: _textMuted,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Clubs',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _card,
              shape: BoxShape.circle,
              border: Border.all(color: _border, width: 0.5),
            ),
            child: const Icon(Icons.search_rounded,
                color: _textSecondary, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Club card
// ─────────────────────────────────────────────────────────────────────────────
class _ClubCard extends StatefulWidget {
  final String club;
  final int index;
  const _ClubCard({required this.club, required this.index});

  @override
  State<_ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<_ClubCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = _colorFor(widget.index);
    final icon = _iconFor(widget.index);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClubFeedScreen(club: widget.club),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colors.bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.fg, size: 26),
              ),
              const SizedBox(height: 14),
              // Club name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  widget.club,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // "View feed" hint
              Text(
                'View feed',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.fg,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}