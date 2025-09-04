import 'package:flutter/material.dart';
import '../base_scaffold.dart';
import 'shree_sangh_notifications_screen.dart';
import 'mahila_samiti_notifications_screen.dart';
import 'yuva_sangh_notifications_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1, // ✅ Isse bottom nav select nahi hoga
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: const Color(0xFF1E3A8A),
              child: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: "Shree Sangh"),
                  Tab(text: "Mahila Samiti"),
                  Tab(text: "Yuva Sangh"),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  ShreeSanghNotificationsScreen(),
                  MahilaSamitiNotificationsScreen(),
                  YuvaSanghNotificationsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
