import 'package:flutter/material.dart';

class MessScreen
    extends StatelessWidget {

  const MessScreen({
    super.key,
  });

  final hostels = const [

    "Hostel 1",

    "Hostel 2",

    "Hostel 3",

    "Hostel 4",

    "Hostel 5",

  ];

  @override
  Widget build(
    BuildContext context,
  ) {

    return DefaultTabController(

      length:
          hostels.length,

      child: Scaffold(

        backgroundColor:

            Colors.grey[100],

        appBar: AppBar(

          title:
              const Text(
            "Mess Menu",
          ),

          bottom: TabBar(

            isScrollable:
                true,

            tabs:

                hostels

                    .map(

                      (e) =>

                          Tab(
                        text:
                            e,
                      ),

                    )

                    .toList(),
          ),
        ),

        body: TabBarView(

  children:

      hostels

          .map(

            (hostel) =>

                DefaultTabController(

              length: 2,

              child: Column(

                children: [

                  const TabBar(

                    tabs: [

                      Tab(
                        text:
                            "Mess A",
                      ),

                      Tab(
                        text:
                            "Mess B",
                      ),
                    ],
                  ),

                  Expanded(

                    child:
                        TabBarView(

                      children: [

                        menuCard(
                          hostel,

                          "Mess A",
                        ),

                        menuCard(
                          hostel,

                          "Mess B",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          )

          .toList(),
),
      ),
    );
  }

  Widget menuCard(
    String hostel, String mess,
  ) {

    return Padding(

      padding:
          const EdgeInsets
              .all(
        20,
      ),

      child: Card(

        shape:

            RoundedRectangleBorder(

          borderRadius:

              BorderRadius
                  .circular(
            25,
          ),
        ),

        child: Padding(

          padding:

              const EdgeInsets
                  .all(
            20,
          ),

          child: Column(

            crossAxisAlignment:

                CrossAxisAlignment
                    .start,

            children: [

              Column(

  crossAxisAlignment:
      CrossAxisAlignment
          .start,

  children: [

    Text(

      hostel,

      style:
          const TextStyle(

        fontSize: 24,

        fontWeight:
            FontWeight.bold,

      ),
    ),

    const SizedBox(
      height: 8,
    ),

    Text(
      mess,
    ),

  ],
),

              const SizedBox(
                height: 30,
              ),

              mealTile(
                "Breakfast",
                "Loading...",
              ),

              mealTile(
                "Lunch",
                "Loading...",
              ),

              mealTile(
                "Dinner",
                "Loading...",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mealTile(

    String meal,

    String menu,

  ) {

    return Padding(

      padding:

          const EdgeInsets
              .only(
        bottom: 25,
      ),

      child: Column(

        crossAxisAlignment:

            CrossAxisAlignment
                .start,

        children: [

          Text(

            meal,

            style:
                const TextStyle(

              fontSize: 18,

              fontWeight:

                  FontWeight.bold,

            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            menu,
          ),
        ],
      ),
    );
  }
}