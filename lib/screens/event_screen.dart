import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const _bg = Color(0xFF0E0E14);
const _surface = Color(0xFF16161F);
const _card = Color(0xFF1C1C28);
const _border = Color(0x12FFFFFF);
const _accent = Color(0xFFFF6B35);
const _accentDim = Color(0x26FF6B35);
const _purple = Color(0xFF7C6EE6);
const _purpleDim = Color(0x267C6EE6);
const _green = Color(0xFF4ADE80);
const _greenDim = Color(0x154ADE80);
const _textPrimary = Color(0xFFF0EEF8);
const _textSecondary = Color(0xFF9896AA);
const _textMuted = Color(0xFF5C5B6B);
const _pillBg = Color(0x12FFFFFF);
const _pillText = Color(0xFFC4C2D8);

// ── Category chip data ────────────────────────────────────────────────────────
const _chips = ['All events', 'This week', 'Music', 'Tech', 'Sports'];

// ── Tag colour helper ─────────────────────────────────────────────────────────
Color _tagColor(String? tag) {
  switch ((tag ?? '').toLowerCase()) {
    case 'music':
      return _purple;
    case 'tech':
      return _accent;
    case 'sports':
      return _green;
    default:
      return _purple;
  }
}

Color _tagDim(String? tag) {
  switch ((tag ?? '').toLowerCase()) {
    case 'music':
      return _purpleDim;
    case 'tech':
      return _accentDim;
    case 'sports':
      return _greenDim;
    default:
      return _purpleDim;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EventsScreen
// ─────────────────────────────────────────────────────────────────────────────
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late final Future<bool> _isAdminFuture;
  int _selectedChip = 0;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _isAdminFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((doc) => doc.data()?['role'] == 'club_admin');
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _bg,
        colorScheme: const ColorScheme.dark(
          primary: _accent,
          surface: _surface,
        ),
      ),
      child: Scaffold(
        backgroundColor: _bg,
        floatingActionButton: _AdminFab(isAdminFuture: _isAdminFuture),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppBar(),
              _ChipRow(
                chips: _chips,
                selected: _selectedChip,
                onTap: (i) => setState(() => _selectedChip = i),
              ),
              Expanded(child: _EventList(chipIndex: _selectedChip)),
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
          _CircleBtn(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DISCOVER',
                  style: TextStyle(
                    fontSize: 10,
                    color: _textMuted,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Events',
                  style: TextStyle(
                    fontSize: 22,
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          _CircleBtn(icon: Icons.search_rounded),
          const SizedBox(width: 8),
          GestureDetector(
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: _accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _card,
          shape: BoxShape.circle,
          border: Border.all(color: _border, width: 0.5),
        ),
        child: Icon(icon, color: _textSecondary, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter chips
// ─────────────────────────────────────────────────────────────────────────────
class _ChipRow extends StatelessWidget {
  final List<String> chips;
  final int selected;
  final ValueChanged<int> onTap;
  const _ChipRow(
      {required this.chips, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: active ? _accent : _pillBg,
                borderRadius: BorderRadius.circular(20),
                border: active
                    ? null
                    : Border.all(color: _border, width: 0.5),
              ),
              child: Text(
                chips[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : _pillText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Event list (stream from Firestore)
// ─────────────────────────────────────────────────────────────────────────────
class _EventList extends StatelessWidget {
  final int chipIndex;
  const _EventList({required this.chipIndex});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong', style: TextStyle(color: _textMuted)),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: _accent),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text('No events yet', style: TextStyle(color: _textMuted)),
          );
        }

        // First doc is featured, rest are upcoming
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: docs.length + 2, // +2 for section labels
          itemBuilder: (context, index) {
            if (index == 0) {
              return _sectionLabel('Featured');
            }
            if (index == 1) {
              final event = docs[0].data() as Map<String, dynamic>;
              return _FeaturedCard(
                event: event,
                eventId: docs[0].id,
              );
            }
            if (index == 2) {
              return _sectionLabel('Upcoming');
            }
            final docIndex = index - 2;
            if (docIndex >= docs.length) return const SizedBox.shrink();
            final event = docs[docIndex].data() as Map<String, dynamic>;
            return _EventRowCard(
              event: event,
              eventId: docs[docIndex].id,
            );
          },
        );
      },
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            color: _textMuted,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Featured card
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final String eventId;
  const _FeaturedCard({required this.event, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final tag = event['tag'] as String?;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventDetailScreen(event: event, eventId: eventId),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Stack(
              children: [
                // Background image or gradient fallback
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: (event['posterUrl'] ?? '').toString().isNotEmpty
                      ? Image.network(
                          event['posterUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const _GradientPoster(),
                        )
                      : const _GradientPoster(),
                ),
                // Featured badge
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
                // Bottom info overlay
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['date'] ?? '',
                          style: const TextStyle(
                              fontSize: 11, color: _textMuted, letterSpacing: 0.4),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          event['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _purpleDim,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline_rounded,
                        size: 14, color: _purple),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event['creatorName'] ?? '',
                      style: const TextStyle(
                          fontSize: 13, color: _textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _TagPill(tag: tag),
                  const SizedBox(width: 6),
                  _StatusPill(status: event['status'] as String?),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientPoster extends StatelessWidget {
  const _GradientPoster();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.4, 0.2),
          radius: 1.2,
          colors: [Color(0xFF2A1F5C), Color(0xFF0E0E14)],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming row card
// ─────────────────────────────────────────────────────────────────────────────
class _EventRowCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final String eventId;
  const _EventRowCard({required this.event, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final tag = event['tag'] as String?;
    final dateParts = _splitDate(event['date'] as String?);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventDetailScreen(event: event, eventId: eventId),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Date column
              Container(
                width: 80,
                decoration: BoxDecoration(
                  color: _tagDim(tag),
                  border: Border(
                    right: BorderSide(color: _border, width: 0.5),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dateParts.$1,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: _tagColor(tag),
                        height: 1,
                      ),
                    ),
                    Text(
                      dateParts.$2,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _textMuted,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _TagPill(tag: tag, small: true),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event['creatorName'] ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: _textMuted),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: _textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event['location'] ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: _textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: _accentDim,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chevron_right_rounded,
                                size: 16, color: _accent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Splits "27 MAY 2025" → ("27", "MAY")
  (String, String) _splitDate(String? raw) {
    if (raw == null || raw.isEmpty) return ('--', '---');
    final parts = raw.trim().split(RegExp(r'[\s,/\-]+'));
    if (parts.length >= 2) return (parts[0], parts[1].toUpperCase());
    return (raw, '');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pills
// ─────────────────────────────────────────────────────────────────────────────
class _TagPill extends StatelessWidget {
  final String? tag;
  final bool small;
  const _TagPill({this.tag, this.small = false});

  @override
  Widget build(BuildContext context) {
    final label = tag ?? 'Event';
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 9 : 10, vertical: small ? 3 : 4),
      decoration: BoxDecoration(
        color: _tagDim(tag),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w500,
          color: _tagColor(tag),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String? status;
  const _StatusPill({this.status});

  @override
  Widget build(BuildContext context) {
    final isOpen = (status ?? 'open').toLowerCase() == 'open';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? const Color(0x1522C55E)
            : const Color(0x15EF4444),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isOpen ? _green : const Color(0xFFF87171),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Admin FAB
// ─────────────────────────────────────────────────────────────────────────────
class _AdminFab extends StatelessWidget {
  final Future<bool> isAdminFuture;
  const _AdminFab({required this.isAdminFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAdminFuture,
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventScreen()),
          ),
          backgroundColor: _accent,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        );
      },
    );
  }
}