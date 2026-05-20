import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  final commentController = TextEditingController();
  bool _isPosting = false;

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
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (commentController.text.trim().isEmpty) return;
    setState(() => _isPosting = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      final userName = userDoc.data()!["name"];
      await FirebaseFirestore.instance
          .collection("products")
          .doc(widget.productId)
          .collection("comments")
          .add({
        "text": commentController.text.trim(),
        "userName": userName,
        "userId": uid,
        "isSeller": uid == widget.product["sellerId"],
        "createdAt": FieldValue.serverTimestamp(),
      });
      commentController.clear();
    } catch (e) {
      if (mounted) _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete listing?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'This will permanently remove your listing. This action cannot be undone.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _surfaceBorder),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE24B4A).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE24B4A).withOpacity(0.3),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Color(0xFFE24B4A),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection("products")
          .doc(widget.productId)
          .delete();
      if (mounted) Navigator.pop(context);
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
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isSeller = widget.product["sellerId"] == currentUid;

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
        title: Text(
          widget.product["name"] ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (isSeller)
            GestureDetector(
              onTap: _deleteProduct,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE24B4A).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE24B4A).withOpacity(0.25),
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Color(0xFFE24B4A),
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildProductDetails()),
                    _buildCommentsHeader(),
                    _buildCommentsList(),
                  ],
                ),
              ),
              _buildCommentInput(isSeller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (widget.product["imageUrl"] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                widget.product["imageUrl"],
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 16),

          // Name + Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.product["name"] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '₹${widget.product["price"]}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _accentText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Seller + Contact cards
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Seller',
                  children: [
                    widget.product["sellerName"] ?? '',
                    widget.product["sellerBranch"] ?? '',
                    widget.product["sellerYear"] ?? '',
                    widget.product["hostel"] ?? '',
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoCard(
                  label: 'Contact',
                  children: [widget.product["phone"] ?? ''],
                  icon: Icons.phone_outlined,
                  accent: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCommentsHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            const Text(
              'Q&A',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _surfaceBorder),
              ),
              child: Text(
                'Questions & Answers',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("products")
          .doc(widget.productId)
          .collection("comments")
          .orderBy("createdAt", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFEEEDFE),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 32,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No questions yet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Be the first to ask!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.15),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final comments = snapshot.data!.docs;

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final comment = comments[index].data() as Map<String, dynamic>;
                final isSellerComment = comment["isSeller"] == true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSellerComment
                        ? _accent.withOpacity(0.08)
                        : _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSellerComment
                          ? _accentText.withOpacity(0.25)
                          : _surfaceBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment["userName"] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (isSellerComment) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _accent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Seller',
                                style: TextStyle(
                                  color: _accentText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        comment["text"] ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: comments.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentInput(bool isSeller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _surfaceBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _surfaceBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: commentController,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                decoration: InputDecoration(
                  hintText: isSeller ? 'Answer a question…' : 'Ask a question…',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isPosting ? null : _postComment,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isPosting ? _accent.withOpacity(0.6) : _accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: _isPosting
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _accentText,
                        ),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: _accentText, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final List<String> children;
  final IconData? icon;
  final bool accent;

  const _InfoCard({
    required this.label,
    required this.children,
    this.icon,
    this.accent = false,
  });

  static const Color _surface = Color(0xFF1A1A1A);
  static const Color _surfaceBorder = Color(0xFF2A2A2A);
  static const Color _accent = Color(0xFFEEEDFE);
  static const Color _accentText = Color(0xFF3C3489);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent ? _accent.withOpacity(0.07) : _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent ? _accentText.withOpacity(0.2) : _surfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: Colors.white.withOpacity(0.3)),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.3),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children
              .where((s) => s.isNotEmpty)
              .map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  )),
        ],
      ),
    );
  }
}