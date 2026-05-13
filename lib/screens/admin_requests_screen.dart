import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Requests")),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("adminRequested", isEqualTo: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,

            itemBuilder: (context, index) {
              final user = docs[index];

              final data = user.data();

              return Card(
                child: ListTile(
                  title: Text(data["name"]),

                  subtitle: Text("${data["branch"]} • ${data["year"]}"),

                  trailing: IconButton(
                    icon: const Icon(Icons.check),

                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(user.id)
                          .update({
                            "role": "club_admin",

                            "adminRequested": false,
                          });
                    },
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
