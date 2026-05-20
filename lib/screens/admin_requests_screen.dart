import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: _buildAppBar(context),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("adminRequested", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const _LoadingState();
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final user = docs[index];
              final data = user.data();
              return _RequestCard(
                user: user,
                data: data,
                index: index,
              );
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F1117),
          border: Border(
            bottom: BorderSide(color: Color(0xFF1E2130), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D2E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF2A2D40), width: 1),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF8B8FA8),
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Admin Requests",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Review & approve access",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFF818CF8), size: 13),
                      SizedBox(width: 4),
                      Text(
                        "Admin",
                        style: TextStyle(
                          color: Color(0xFF818CF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class _RequestCard extends StatefulWidget {
  final QueryDocumentSnapshot user;
  final Map<String, dynamic> data;
  final int index;

  const _RequestCard({
    required this.user,
    required this.data,
    required this.index,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard>
    with SingleTickerProviderStateMixin {
  bool _isApproving = false;
  bool _isApproved = false;

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFF4F46E5),
      const Color(0xFF0891B2),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFFDC2626),
    ];
    return colors[index % colors.length];
  }

  Future<void> _approveUser() async {
    setState(() => _isApproving = true);
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user.id)
          .update({
        "role": "club_admin",
        "adminRequested": false,
      });
      if (mounted) setState(() => _isApproved = true);
    } catch (e) {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.data["name"] ?? "Unknown";
    final branch = widget.data["branch"] ?? "—";
    final year = widget.data["year"] ?? "—";
    final avatarColor = _getAvatarColor(widget.index);

    return AnimatedOpacity(
      opacity: _isApproved ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF141720),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isApproved
                ? const Color(0xFF10B981).withOpacity(0.4)
                : const Color(0xFF1E2130),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: avatarColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: TextStyle(
                      color: avatarColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _MetaChip(label: branch, icon: Icons.school_outlined),
                        const SizedBox(width: 6),
                        _MetaChip(label: "Year $year", icon: Icons.calendar_today_outlined),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Approve button
              _isApproved
                  ? Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    )
                  : GestureDetector(
                      onTap: _isApproving ? null : _approveUser,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _isApproving
                              ? const Color(0xFF1E2130)
                              : const Color(0xFF4F46E5).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isApproving
                                ? const Color(0xFF2A2D40)
                                : const Color(0xFF4F46E5).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: _isApproving
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF818CF8),
                                ),
                              )
                            : const Icon(
                                Icons.check_rounded,
                                color: Color(0xFF818CF8),
                                size: 20,
                              ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MetaChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D2E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF252840), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2D40), width: 1),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF4F46E5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading requests...",
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A2D40), width: 1),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              color: Color(0xFF4B5563),
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "All clear",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "No pending admin requests",
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}