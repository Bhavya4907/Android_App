import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(
                  event["posterUrl"] ?? "",
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event["title"] ?? "",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  infoTile(Icons.calendar_today, event["date"] ?? ""),
                  infoTile(Icons.location_on, event["venue"] ?? ""),
                  infoTile(Icons.groups, event["creatorName"] ?? ""),
                  const SizedBox(height: 25),
                  const Text(
                    "About",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(event["description"] ?? ""),
                  const SizedBox(height: 30),

                  // Interested Button with count
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("events")
                        .doc(eventId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final interestedList = List<String>.from(data["interested"] ?? []);
                      final isInterested = interestedList.contains(uid);
                      final count = interestedList.length;

                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInterested
                                    ? Colors.green
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () async {
                                final eventRef = FirebaseFirestore.instance
                                    .collection("events")
                                    .doc(eventId);

                                if (isInterested) {
                                  await eventRef.update({
                                    "interested": FieldValue.arrayRemove([uid]),
                                  });
                                } else {
                                  await eventRef.update({
                                    "interested": FieldValue.arrayUnion([uid]),
                                  });
                                }
                              },
                              child: Text(
                                isInterested ? "Interested ✓" : "Interested",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "$count ${count == 1 ? 'person' : 'people'} interested",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 15),
          Text(text),
        ],
      ),
    );
  }
}