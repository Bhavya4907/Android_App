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

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final commentController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isSeller = widget.product["sellerId"] == currentUid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product["name"]),
        actions: [
          if (isSeller)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProduct,
            ),
        ],
      ),

      body: Column(
        children: [
          // Product Details
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.product["imageUrl"] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.product["imageUrl"],
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 16),

                Text(
                  widget.product["name"],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text("₹${widget.product["price"]}",
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                const Text("Seller",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${widget.product["sellerName"]}"),
                Text("${widget.product["sellerBranch"]}"),
                Text("${widget.product["sellerYear"]}"),
                Text("${widget.product["hostel"]}"),
                const SizedBox(height: 20),
                const Text("Contact",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${widget.product["phone"]}"),
                const Divider(height: 40),
                const Text(
                  "Questions & Answers",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("products")
                  .doc(widget.productId)
                  .collection("comments")
                  .orderBy("createdAt", descending: false)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No questions yet. Be the first to ask!"),
                  );
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment =
                        comments[index].data() as Map<String, dynamic>;
                    final isSellerComment = comment["isSeller"] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSellerComment
                            ? Colors.blue.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: isSellerComment
                            ? Border.all(color: Colors.blue.shade200)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment["userName"] ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              if (isSellerComment) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    "Seller",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(comment["text"] ?? ""),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Comment Input
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: isSeller
                          ? "Answer a question..."
                          : "Ask a question...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isPosting
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _postComment,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}