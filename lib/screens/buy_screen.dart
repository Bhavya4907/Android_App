import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_screen.dart';

class BuyScreen extends StatelessWidget {
  const BuyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buy Products")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("products")
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Products"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final productData = Map<String, dynamic>.from(data);
              final productId = docs[index].id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        product: productData,
                        productId: productId,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: data["imageUrl"] != null
                                ? Image.network(
                                    data["imageUrl"],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["name"] ?? "",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text("${data["sellerName"] ?? ""}"),
                                Text("${data["sellerBranch"] ?? ""} • ${data["sellerYear"] ?? ""}"),
                                Text(data["hostel"] ?? ""),
                              ],
                            ),
                          ),

                          Text(
                            "₹${data["price"] ?? ""}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}