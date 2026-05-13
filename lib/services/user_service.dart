import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {

  final users =
      FirebaseFirestore
          .instance
          .collection(
            "users",
          );

  Future createUser({

    required String uid,

    required String name,

    required String branch,

    required String year,

  }) async {

    await users
        .doc(uid)
        .set({

      "uid": uid,

      "name": name,

      "branch": branch,

      "year": year,

    });

  }

}