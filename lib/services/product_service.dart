import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ProductService {
  final products = FirebaseFirestore.instance.collection("products");

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

  Future addProduct({
    required String name,
    required int price,
    required String hostel,
    required String phone,
    required File image,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final user = userDoc.data()!;

    final imageUrl = await uploadImageToCloudinary(image);

    await products.add({
      "name": name,
      "price": price,
      "hostel": hostel,
      "phone": phone,
      "sellerId": uid,
      "sellerName": user["name"],
      "sellerBranch": user["branch"],
      "sellerYear": user["year"],
      "imageUrl": imageUrl,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}