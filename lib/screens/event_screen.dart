import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Events")),

      // FAB only shows for admin
      floatingActionButton: FutureBuilder(
        future: FirebaseFirestore.instance.collection("users").doc(uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          final user = snapshot.data!.data()!;
          final isAdmin = user["role"] == "club_admin";

          if (!isAdmin) return const SizedBox();

          return FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
              );
            },
            child: const Icon(Icons.add),
          );
        },
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("events")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No events yet"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final event = docs[index].data();
              final eventData = Map<String, dynamic>.from(event);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(
                        event: eventData,
                        eventId: docs[index].id,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 12),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                        child: Image.network(
                          event["posterUrl"] ?? "",
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event["date"] ?? ""),
                            const SizedBox(height: 10),
                            Text(
                              event["title"] ?? "",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(event["creatorName"] ?? ""),
                          ],
                        ),
                      ),
                    ],
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
