import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class EventService {
  final events = FirebaseFirestore.instance.collection("events");

  Future<String> uploadImageToCloudinary(File image) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/dunfufj3r/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields["upload_preset"] = "images"
      ..files.add(
        await http.MultipartFile.fromPath("file", image.path),
      );

    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final jsonData = json.decode(String.fromCharCodes(responseData));

    return jsonData["secure_url"];
  }

  Future createEvent({
    required String title,
    required String venue,
    required String date,
    required String description,
    required File image,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final user = userDoc.data()!;

    final imageUrl = await uploadImageToCloudinary(image);

    await events.add({
      "title": title,
      "venue": venue,
      "date": date,
      "description": description,
      "posterUrl": imageUrl,
      "creatorUid": uid,
      "creatorName": user["name"],
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}