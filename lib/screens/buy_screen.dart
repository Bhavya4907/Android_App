import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_screen.dart';

class BuyScreen extends StatelessWidget {
  const BuyScreen({super.key});

  static const Color _bg = Color(0xFF0D0D0D);
  static const Color _surface = Color(0xFF1A1A1A);
  static const Color _surfaceBorder = Color(0xFF2A2A2A);
  static const Color _accent = Color(0xFFEEEDFE);
  static const Color _accentText = Color(0xFF3C3489);

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
          'Buy',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("products").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEEEDFE)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 12),
                  Text(
                    'No listings yet',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 15),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final productId = docs[index].id;

              return _ProductCard(
                data: data,
                onTap: () => Navigator.push(
                  context,
                  _slideRoute(ProductDetailScreen(
                    product: Map<String, dynamic>.from(data),
                    productId: productId,
                  )),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ProductCard({required this.data, required this.onTap});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  static const Color _surface = Color(0xFF1A1A1A);
  static const Color _surfaceBorder = Color(0xFF2A2A2A);
  static const Color _accent = Color(0xFFEEEDFE);
  static const Color _accentText = Color(0xFF3C3489);

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _surfaceBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: data["imageUrl"] != null
                      ? Image.network(
                          data["imageUrl"],
                          width: 86,
                          height: 86,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: const Color(0xFF242424),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.white.withOpacity(0.2),
                            size: 28,
                          ),
                        ),
                ),

                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["name"] ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        data["sellerName"] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.45),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _MetaChip(
                            label: '${data["sellerBranch"] ?? ''} · ${data["sellerYear"] ?? ''}',
                          ),
                          const SizedBox(width: 6),
                          _MetaChip(label: data["hostel"] ?? ''),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Price
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '₹${data["price"] ?? ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _accentText,
                    ),
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

class _MetaChip extends StatelessWidget {
  final String label;
  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: Colors.white.withOpacity(0.35),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}