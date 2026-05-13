import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'buy_screen.dart';
import 'profile_screen.dart';
import 'sell_screen.dart';
import 'admin_requests_screen.dart';
import 'event_screen.dart';
import 'mess_screen.dart';
import 'clubs_screen.dart';

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "CampusHub",

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "The 2nd most important hub",

                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,

                  crossAxisSpacing: 15,

                  mainAxisSpacing: 15,

                  children: [
                    dashboardCard(
                      context,

                      "Buy",

                      Icons.shopping_bag,

                      const BuyScreen(),
                    ),

                    dashboardCard(
                      context,

                      "Sell",

                      Icons.sell,

                      const SellScreen(),
                    ),

                    dashboardCard(
                      context,

                      "Events",

                      Icons.event,

                      const EventsScreen(),
                    ),

                    dashboardCard(
                      context,

                      "Clubs",

                      Icons.groups,

                      const ClubsScreen(),
                    ),

                    dashboardCard(
                      context,

                      "Mess",

                      Icons.restaurant,

                      const MessScreen(),
                    ),

                    dashboardCard(context, "Lost & Found", Icons.search, null),

                    dashboardCard(
                      context,

                      "Profile",

                      Icons.person,

                      const ProfileScreen(),
                    ),

                    if (currentUid == "81pFdvPilzem9QyYL2fjaaMqtRs2")
                      dashboardCard(
                        context,

                        "Admin Requests",

                        Icons.admin_panel_settings,

                        const AdminRequestsScreen(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(
    BuildContext context,

    String title,

    IconData icon,

    Widget? screen,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),

      onTap: () {
        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        }
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(25),

          boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black12)],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, size: 45),

            const SizedBox(height: 15),

            Text(
              title,

              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
