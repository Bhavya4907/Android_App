import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../services/user_service.dart';

import 'choice_screen.dart';

class ProfileSetupScreen
    extends StatefulWidget {

  const ProfileSetupScreen({
    super.key,
  });

  @override
  State<ProfileSetupScreen>
      createState() =>
          _ProfileSetupScreenState();

}

class _ProfileSetupScreenState
    extends State<
        ProfileSetupScreen> {

  final nameController =
      TextEditingController();

  final branchController =
      TextEditingController();

  final yearController =
      TextEditingController();

  final userService =
      UserService();

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Complete Profile",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          children: [

            TextField(

              controller:
                  nameController,

              decoration:
                  const InputDecoration(

                labelText:
                    "Name",

              ),
            ),

            TextField(

              controller:
                  branchController,

              decoration:
                  const InputDecoration(

                labelText:
                    "Branch",

              ),
            ),

            TextField(

              controller:
                  yearController,

              decoration:
                  const InputDecoration(

                labelText:
                    "Year",

              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(

              onPressed:
                  () async {

                final uid =

                    FirebaseAuth
                        .instance
                        .currentUser!
                        .uid;

                await userService
                    .createUser(

                  uid: uid,

                  name:
                      nameController
                          .text,

                  branch:
                      branchController
                          .text,

                  year:
                      yearController
                          .text,

                );

                Navigator
                    .pushReplacement(

                  context,

                  MaterialPageRoute(

                    builder:
                        (_) =>
                            const ChoiceScreen(),

                  ),
                );

              },

              child: const Text(
                "SAVE",
              ),
            ),
          ],
        ),
      ),
    );
  }
}