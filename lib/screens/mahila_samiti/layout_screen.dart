import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'pravartiya_screen.dart'; // ✅ Import Pravartiya Screen

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MahilaHomeScreen(),
    PravartiyaScreen(), // ✅ Ab yaha Pravritti Screen aa gayi
    Center(child: Text("🖼 Gallery", style: TextStyle(fontSize: 20))),
    Center(child: Text("👥 Members", style: TextStyle(fontSize: 20))),
    Center(child: Text("🔔 Notifications", style: TextStyle(fontSize: 20))),
    Center(child: Text("⚙ Settings", style: TextStyle(fontSize: 20))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFFC107),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                "assets/images/mslogo.png",
                height: 75,
              ),
              const SizedBox(width: 12),
              Text(
                "महिला समिति",
                style: GoogleFonts.amita(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.amber[800],
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'होम',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'प्रवृत्ति',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.photo_library),
                label: 'गैलरी',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'सदस्य',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'सूचना',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'सेटिंग्स',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
