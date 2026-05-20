import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'create_club_post_screen.dart';

// ── Palette (mirrors the rest of the app) ────────────────────────────────────
const _bg = Color(0xFF0E0E14);
const _surface = Color(0xFF16161F);
const _card = Color(0xFF1C1C28);
const _border = Color(0x12FFFFFF);
const _accent = Color(0xFFFF6B35);
const _textPrimary = Color(0xFFF0EEF8);
const _textSecondary = Color(0xFF9896AA);
const _textMuted = Color(0xFF5C5B6B);

// ─────────────────────────────────────────────────────────────────────────────
// ClubFeedScreen
// ─────────────────────────────────────────────────────────────────────────────
class ClubFeedScreen extends StatefulWidget {
  final String club;

  const ClubFeedScreen({
    super.key,
    required this.club,
  });

  @override
  State<ClubFeedScreen> createState() => _ClubFeedScreenState();
}

class _ClubFeedScreenState extends State<ClubFeedScreen> {
  // Cache the admin check so it doesn't re-fire on rebuild
  late final Future<bool> _isAdminFuture;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _isAdminFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((doc) {
      final data = doc.data() ?? {};
      return data['role'] == 'club_admin' &&
          data['assignedClub'] == widget.club;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        floatingActionButton: _AdminFab(
          club: widget.club,
          isAdminFuture: _isAdminFuture,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _AppBar(club: widget.club),
              Expanded(child: _PostFeed(club: widget.club)),
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
  final String club;
  const _AppBar({required this.club});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _card,
                shape: BoxShape.circle,
                border: Border.all(color: _border, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: _textSecondary, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CLUB',
                  style: TextStyle(
                    fontSize: 10,
                    color: _textMuted,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  club,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    height: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Post feed
// ─────────────────────────────────────────────────────────────────────────────
class _PostFeed extends StatelessWidget {
  final String club;
  const _PostFeed({required this.club});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('club_posts')
          .where('club', isEqualTo: club)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong',
                style: TextStyle(color: _textMuted)),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: _accent, strokeWidth: 2),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _card,
                    shape: BoxShape.circle,
                    border: Border.all(color: _border, width: 0.5),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: _textMuted, size: 24),
                ),
                const SizedBox(height: 14),
                const Text('No posts yet',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary)),
                const SizedBox(height: 4),
                const Text('Check back soon',
                    style: TextStyle(fontSize: 13, color: _textMuted)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final post = docs[index].data() as Map<String, dynamic>;
            return _PostCard(post: post);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Post card
// ─────────────────────────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (post['imageUrl'] ?? '') as String;
    final title = (post['title'] ?? '') as String;
    final description = (post['description'] ?? '') as String;
    final timestamp = post['createdAt'];

    String timeLabel = '';
    if (timestamp != null) {
      final dt = (timestamp as dynamic).toDate() as DateTime;
      timeLabel = _formatDate(dt);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 140,
                color: _surface,
                child: const Center(
                  child: Icon(Icons.broken_image_outlined,
                      color: _textMuted, size: 32),
                ),
              ),
            ),

          // Text content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + timestamp row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (timeLabel.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Text(
                        timeLabel,
                        style: const TextStyle(
                            fontSize: 11, color: _textMuted),
                      ),
                    ],
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textSecondary,
                      height: 1.55,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Admin FAB
// ─────────────────────────────────────────────────────────────────────────────
class _AdminFab extends StatelessWidget {
  final String club;
  final Future<bool> isAdminFuture;
  const _AdminFab({required this.club, required this.isAdminFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAdminFuture,
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateClubPostScreen(club: club),
            ),
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