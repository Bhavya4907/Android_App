import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import 'choice_screen.dart';

import 'profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen>
      createState() =>
          _LoginScreenState();

}

class _LoginScreenState
    extends State<LoginScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final authService =
      AuthService();

  bool isLogin = true;

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          Colors.grey[100],

      body: SafeArea(

        child: Center(

          child:
              SingleChildScrollView(

            child: Padding(

              padding:
                  const EdgeInsets.all(
                25,
              ),

              child: Column(

                crossAxisAlignment:

                    CrossAxisAlignment
                        .start,

                children: [

                  const Text(

                    "CampusHub",

                    style: TextStyle(

                      fontSize: 34,

                      fontWeight:

                          FontWeight
                              .bold,

                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(

                    isLogin

                        ? "Welcome back"

                        : "Create account",

                    style:
                        const TextStyle(

                      fontSize: 18,

                    ),
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  TextField(

                    controller:

                        emailController,

                    decoration:

                        InputDecoration(

                      prefixIcon:

                          const Icon(
                        Icons.email,
                      ),

                      hintText:
                          "Email",

                      filled: true,

                      fillColor:
                          Colors.white,

                      border:

                          OutlineInputBorder(

                        borderRadius:

                            BorderRadius.circular(
                          20,
                        ),

                        borderSide:
                            BorderSide.none,

                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextField(

                    controller:

                        passwordController,

                    obscureText:
                        true,

                    decoration:

                        InputDecoration(

                      prefixIcon:

                          const Icon(
                        Icons.lock,
                      ),

                      hintText:
                          "Password",

                      filled: true,

                      fillColor:
                          Colors.white,

                      border:

                          OutlineInputBorder(

                        borderRadius:

                            BorderRadius.circular(
                          20,
                        ),

                        borderSide:
                            BorderSide.none,

                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  SizedBox(

                    width:
                        double.infinity,

                    height: 55,

                    child:
                        ElevatedButton(

                      style:

                          ElevatedButton.styleFrom(

                        shape:

                            RoundedRectangleBorder(

                          borderRadius:

                              BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),

                      onPressed:
                          () async {

                        try {

                          if(
                            isLogin
                          ){

                            await authService
                                .login(

                              emailController
                                  .text,

                              passwordController
                                  .text,

                            );

                            Navigator.pushReplacement(

                              context,

                              MaterialPageRoute(

                                builder:
                                    (_) =>
                                        const ChoiceScreen(),

                              ),
                            );

                          }

                          else {

                            await authService
                                .signUp(

                              emailController
                                  .text,

                              passwordController
                                  .text,

                            );

                            Navigator.pushReplacement(

                              context,

                              MaterialPageRoute(

                                builder:
                                    (_) =>
                                        const ProfileSetupScreen(),

                              ),
                            );

                          }

                        }

                        catch(e){

                          ScaffoldMessenger
                              .of(
                            context,
                          )
                              .showSnackBar(

                            SnackBar(

                              content:
                                  Text(
                                e.toString(),
                              ),

                            ),
                          );

                        }

                      },

                      child: Text(

                        isLogin

                            ? "LOGIN"

                            : "SIGN UP",

                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Center(

                    child:
                        TextButton(

                      onPressed:
                          () {

                        setState(() {

                          isLogin =
                              !isLogin;

                        });

                      },

                      child: Text(

                        isLogin

                            ? "Create account"

                            : "Already have account?",

                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}