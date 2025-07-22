import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_scaffold.dart';
import 'family_screen.dart';
import 'address.dart';
import 'education.dart';
import 'employment_screen.dart';
import 'achievements_screen.dart';
import 'general_details.dart';
import 'trust.dart';
import 'sadasyata_screen.dart';

class MrmScreen extends StatefulWidget {
  final String memberId;

  const MrmScreen({super.key, required this.memberId});

  @override
  State<MrmScreen> createState() => _MrmScreenState();
}

class _MrmScreenState extends State<MrmScreen> {
  String userName = '';
  bool isDarkMode = false;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final name = prefs.getString('user_name') ?? "User";
    isDarkMode = prefs.getBool('dark_mode') ?? false;

    if (token == null) {
      setState(() {
        userName = "Guest";
      });
      return;
    }

    setState(() {
      userName = name;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void navigateTo(int index) {
    Widget targetScreen;
    switch (index) {
      case 0:
        targetScreen = FamilyScreen();
        break;
      case 1:
        targetScreen = const AddressScreen();
        break;
      case 2:
        targetScreen = Education();
        break;
      case 3:
        targetScreen = EmploymentScreen();
        break;
      case 4:
        targetScreen = AchievementsScreen();
        break;
      case 5:
        targetScreen = GeneralDetails();
        break;
      case 6:
        targetScreen = Trust();
        break;
     case 7:
  targetScreen = const ActivitiesScreen();
  break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen));
  }

  Widget buildCard(String title, IconData icon, int index) {
    return GestureDetector(
      onTap: () => navigateTo(index),
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) - 24,
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              offset: const Offset(5, 5),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.deepPurple.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              icon,
              size: 32,
              color: Colors.deepPurple.shade700,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: 0,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      'assets/images/Global-Card.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.8,
                  children: [
                    buildCard("सामान्य विवरण", Icons.person, 5),
                    buildCard("परिवार", Icons.family_restroom, 0),
                    buildCard("पता", Icons.location_on, 1),
                    buildCard("शिक्षा", Icons.school, 2),
                    buildCard("पेशा", Icons.work, 3),
                    buildCard("उपलब्धियाँ", Icons.emoji_events, 4),
                    buildCard("न्यास-ट्रस्ट", Icons.home_work, 6),
                    buildCard("सदस्यता", Icons.badge, 7),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
