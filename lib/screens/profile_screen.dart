import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: FutureBuilder(
          future: FirebaseFirestore.instance.collection("users").doc(uid).get(),

          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data()!;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(25),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(30),

                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 15),
                        ],
                      ),

                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,

                            child: const Icon(Icons.person, size: 40),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            data["name"],

                            style: const TextStyle(
                              fontSize: 24,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "${data["branch"]} • ${data["year"]}",

                            style: const TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 15),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,

                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),

                              color: Colors.grey[200],
                            ),

                            child: Text(
                              (data["adminRequested"] ?? false)
                                  ? "Admin Requested"
                                  : "Regular User",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(25),
                      ),

                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.badge),

                            title: const Text("UID"),

                            subtitle: Text(uid),

                            trailing: IconButton(
                              icon: const Icon(Icons.copy),

                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: uid));

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("UID copied")),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,

                      height: 55,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),

                        onPressed: (data["adminRequested"] ?? false)
                            ? null
                            : () async {
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(uid)
                                    .update({"adminRequested": true});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Admin request sent"),
                                  ),
                                );
                              },

                        child: Text(
                          (data["adminRequested"] ?? false)
                              ? "Request Pending"
                              : "Request Admin",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
