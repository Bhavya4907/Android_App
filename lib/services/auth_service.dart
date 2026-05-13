import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  Future signUp(
    String email,
    String password,
  ) async {

    return await auth
        .createUserWithEmailAndPassword(

      email: email,

      password: password,

    );
  }

  Future login(
    String email,
    String password,
  ) async {

    return await auth
        .signInWithEmailAndPassword(

      email: email,

      password: password,

    );
  }

}