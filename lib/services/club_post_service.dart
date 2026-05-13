import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';

class ClubPostService {

  final posts =

      FirebaseFirestore
          .instance
          .collection(
            "club_posts",
          );

  Future createPost({

    required String title,

    required String description,

    required File image,

  }) async {

    final uid =

        FirebaseAuth
            .instance
            .currentUser!
            .uid;

    final userDoc =

        await FirebaseFirestore
            .instance
            .collection(
              "users",
            )
            .doc(
              uid,
            )
            .get();

    final user =
        userDoc.data()!;

    final imageRef =

        FirebaseStorage
            .instance
            .ref()
            .child(
              "club_posts",
            )
            .child(
              "${DateTime.now().millisecondsSinceEpoch}.jpg",
            );

    final snapshot =

        await imageRef
            .putFile(
              image,
            );

    final imageUrl =

        await snapshot
            .ref
            .getDownloadURL();

    await posts.add({

      "club":
          user[
              "assignedClub"],

      "title":
          title,

      "description":
          description,

      "imageUrl":
          imageUrl,

      "creatorUid":
          uid,

      "createdAt":

          FieldValue
              .serverTimestamp(),

    });

  }

}