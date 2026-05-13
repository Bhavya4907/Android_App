import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'create_club_post_screen.dart';

class ClubFeedScreen
    extends StatelessWidget {

  final String club;

  const ClubFeedScreen({

    super.key,

    required this.club,

  });

  @override
  Widget build(
    BuildContext context,
  ) {

    final uid =

        FirebaseAuth
            .instance
            .currentUser!
            .uid;

    return FutureBuilder(

      future:

          FirebaseFirestore
              .instance
              .collection(
                "users",
              )
              .doc(
                uid,
              )
              .get(),

      builder: (

        context,

        userSnapshot,

      ) {

        if(
          !userSnapshot
              .hasData
        ){

          return const Scaffold(

            body: Center(

              child:

                  CircularProgressIndicator(),

            ),
          );
        }

        final user =

            userSnapshot
                .data!
                .data()!;

        final isAdmin =

            user["role"] ==

                "club_admin"

            &&

            user[
                "assignedClub"] ==

                club;

        return Scaffold(

          backgroundColor:

              Colors.grey[100],

          appBar: AppBar(

            title:
                Text(
              club,
            ),
          ),

          floatingActionButton:

              isAdmin

                  ? FloatingActionButton(

                      child:
                          const Icon(
                        Icons.add,
                      ),

                      onPressed:
                          () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder:
                                (_) =>

                                    CreateClubPostScreen(
                              club:
                                  club,
                            ),

                          ),
                        );

                      },

                    )

                  : null,

          body: StreamBuilder(

            stream:

                FirebaseFirestore
                    .instance
                    .collection(
                      "club_posts",
                    )
                    .where(
                      "club",

                      isEqualTo:
                          club,
                    )
                    .orderBy(
                      "createdAt",

                      descending:
                          true,
                    )
                    .snapshots(),

            builder: (

              context,

              snapshot,

            ) {

              if(
                !snapshot
                    .hasData
              ){

                return const Center(

                  child:

                      CircularProgressIndicator(),

                );
              }

              final docs =
                  snapshot
                      .data!
                      .docs;

              return ListView.builder(

                itemCount:
                    docs.length,

                itemBuilder: (

                  context,

                  index,

                ) {

                  final post =
                      docs[index]
                          .data();

                  return Container(

                    margin:

                        const EdgeInsets
                            .all(
                      15,
                    ),

                    decoration:

                        BoxDecoration(

                      color:
                          Colors.white,

                      borderRadius:

                          BorderRadius
                              .circular(
                        25,
                      ),

                    ),

                    child: Column(

                      children: [

                        ClipRRect(

                          borderRadius:

                              const BorderRadius
                                  .vertical(

                            top:
                                Radius.circular(
                              25,
                            ),
                          ),

                          child:
                              Image.network(

                            post[
                                "imageUrl"],

                            height:
                                250,

                            width:

                                double
                                    .infinity,

                            fit:
                                BoxFit.cover,

                          ),
                        ),

                        Padding(

                          padding:

                              const EdgeInsets
                                  .all(
                            15,
                          ),

                          child: Column(

                            crossAxisAlignment:

                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(

                                post[
                                    "title"],

                                style:
                                    const TextStyle(

                                  fontSize:
                                      20,

                                  fontWeight:

                                      FontWeight.bold,

                                ),
                              ),

                              const SizedBox(
                                height:
                                    10,
                              ),

                              Text(

                                post[
                                    "description"],

                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}