import 'package:flutter/material.dart';

import '../data/club_data.dart';

import 'club_feed_screen.dart';

class ClubsScreen
    extends StatelessWidget {

  const ClubsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:

          Colors.grey[100],

      appBar: AppBar(

        title:
            const Text(
          "Clubs",
        ),
      ),

      body: GridView.builder(

        padding:

            const EdgeInsets
                .all(
          20,
        ),

        gridDelegate:

            const SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount:
              2,

          crossAxisSpacing:
              15,

          mainAxisSpacing:
              15,

        ),

        itemCount:
            clubs.length,

        itemBuilder: (

          context,

          index,

        ) {

          final club =
              clubs[index];

          return GestureDetector(

            onTap:
                () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder:
                      (_) =>

                          ClubFeedScreen(
                    club:
                        club,
                  ),

                ),
              );

            },

            child: Container(

              decoration:

                  BoxDecoration(

                color:
                    Colors.white,

                borderRadius:

                    BorderRadius
                        .circular(
                  25,
                ),

                boxShadow: [

                  BoxShadow(

                    color:

                        Colors
                            .black12,

                    blurRadius:
                        12,

                  ),
                ],
              ),

              child: Center(

                child: Text(

                  club,

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(

                    fontSize:
                        18,

                    fontWeight:

                        FontWeight
                            .bold,

                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}