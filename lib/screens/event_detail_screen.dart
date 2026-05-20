import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Palette (mirrors events_screen.dart) ─────────────────────────────────────
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

// ── Tag helpers ───────────────────────────────────────────────────────────────
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
// EventDetailScreen
// ─────────────────────────────────────────────────────────────────────────────
class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final tag = event['tag'] as String?;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // ── Scrollable content ──────────────────────────────────────────
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  _PosterSection(event: event, tag: tag),

                  // Content sheet
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _bg,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 20),
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tag pill
                              if (tag != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _tagDim(tag),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _tagColor(tag),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Title
                              Text(
                                event['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                  height: 1.15,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Info tiles
                              _InfoCard(
                                tiles: [
                                  _InfoTile(
                                    icon: Icons.calendar_today_outlined,
                                    label: 'Date',
                                    value: event['date'] ?? '',
                                  ),
                                  _InfoTile(
                                    icon: Icons.location_on_outlined,
                                    label: 'Venue',
                                    value: event['venue'] ?? '',
                                  ),
                                  _InfoTile(
                                    icon: Icons.groups_outlined,
                                    label: 'Organised by',
                                    value: event['creatorName'] ?? '',
                                    isLast: true,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),

                              // About
                              const Text(
                                'About',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                event['description'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _textSecondary,
                                  height: 1.65,
                                ),
                              ),

                              // Extra bottom padding for the FAB
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Back button ─────────────────────────────────────────────────
            Positioned(
              top: 52,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.15), width: 0.5),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),

            // ── Interested button pinned to bottom ──────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _InterestedBar(eventId: eventId, uid: uid),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Poster section
// ─────────────────────────────────────────────────────────────────────────────
class _PosterSection extends StatelessWidget {
  final Map<String, dynamic> event;
  final String? tag;
  const _PosterSection({required this.event, this.tag});

  @override
  Widget build(BuildContext context) {
    final posterUrl = (event['posterUrl'] ?? '') as String;

    return SizedBox(
      height: 340,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image or gradient fallback
          posterUrl.isNotEmpty
              ? Image.network(
                  posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _GradientPoster(tag: tag),
                )
              : _GradientPoster(tag: tag),

          // Scrim at bottom for smooth bleed into sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _bg.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientPoster extends StatelessWidget {
  final String? tag;
  const _GradientPoster({this.tag});

  @override
  Widget build(BuildContext context) {
    final Color a = _tagDim(tag).withOpacity(0.6);
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.3, 0.1),
          radius: 1.3,
          colors: [a, _bg],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info card (grouped tiles)
// ─────────────────────────────────────────────────────────────────────────────
class _InfoTile {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });
}

class _InfoCard extends StatelessWidget {
  final List<_InfoTile> tiles;
  const _InfoCard({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        children: tiles.map((t) {
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border, width: 0.5),
                      ),
                      child: Icon(t.icon, size: 17, color: _textSecondary),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.label,
                          style: const TextStyle(
                              fontSize: 11,
                              color: _textMuted,
                              letterSpacing: 0.3),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.value,
                          style: const TextStyle(
                              fontSize: 14,
                              color: _textPrimary,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!t.isLast)
                const Divider(
                    height: 0, thickness: 0.5, color: _border, indent: 66),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interested bar (pinned bottom)
// ─────────────────────────────────────────────────────────────────────────────
class _InterestedBar extends StatelessWidget {
  final String eventId;
  final String uid;
  const _InterestedBar({required this.eventId, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _border, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 55,
              child: Center(
                child: CircularProgressIndicator(color: _accent, strokeWidth: 2),
              ),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final interestedList =
              List<String>.from(data['interested'] ?? []);
          final isInterested = interestedList.contains(uid);
          final count = interestedList.length;

          return Row(
            children: [
              // Count badge
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                      height: 1,
                    ),
                  ),
                  Text(
                    count == 1 ? 'person' : 'people',
                    style: const TextStyle(fontSize: 11, color: _textMuted),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Button
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final ref = FirebaseFirestore.instance
                        .collection('events')
                        .doc(eventId);
                    if (isInterested) {
                      await ref.update({
                        'interested': FieldValue.arrayRemove([uid]),
                      });
                    } else {
                      await ref.update({
                        'interested': FieldValue.arrayUnion([uid]),
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 52,
                    decoration: BoxDecoration(
                      color: isInterested ? _greenDim : _accent,
                      borderRadius: BorderRadius.circular(16),
                      border: isInterested
                          ? Border.all(color: _green.withOpacity(0.4), width: 0.5)
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isInterested
                                ? Icons.check_circle_outline_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(isInterested),
                            color: isInterested ? _green : Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            isInterested ? 'Interested' : "I'm interested",
                            key: ValueKey(isInterested),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isInterested ? _green : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}