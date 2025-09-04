import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'upcoming_events_screen.dart';
import 'sahitya_screen.dart';
import 'shramnopasak_screen.dart';
import 'shivir_screen.dart';
import 'login_screen.dart';
import 'member_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ Import Notifications Screen
import 'notifications/notifications_screen.dart';

class BaseScaffold extends StatelessWidget {
  final int selectedIndex;
  final Widget body;

  const BaseScaffold({
    super.key,
    required this.selectedIndex,
    required this.body,
  });

  void onItemTapped(BuildContext context, int index) async {
    if (index == selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BaseScaffold(
              selectedIndex: 1,
              body: UpcomingEventsScreen(),
            ),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BaseScaffold(
              selectedIndex: 2,
              body: SahityaScreen(),
            ),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BaseScaffold(
              selectedIndex: 3,
              body: ShramnopasakScreen(),
            ),
          ),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BaseScaffold(
              selectedIndex: 4,
              body: ShivirScreen(),
            ),
          ),
        );
        break;
      case 5:
        final prefs = await SharedPreferences.getInstance();
        final memberId = prefs.getString('member_id') ?? '';

        if (memberId.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MemberProfileScreen(memberId: memberId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Member ID not found")),
          );
        }
        break;
    }
  }

  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  toolbarHeight: 56,
  titleSpacing: 0,
  backgroundColor: const Color(0xFF1E3A8A),
  systemOverlayStyle: const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF1E3A8A),
    statusBarIconBrightness: Brightness.light,
  ),

  title: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        flex: 2,
        child: Image.asset(
          'assets/logo.png',
          height: 45,
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 5,
        child: FittedBox(
          fit: BoxFit.scaleDown, // ✅ text screen ke hisaab se shrink hoga
          child: Text(
            "श्री अ.भा.सा जैन संघ",
            style: GoogleFonts.amita(
              fontSize: 26, // base size
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  ),
  centerTitle: true,

  // ✅ Right side bell icon
  actions: [
    IconButton(
      icon: const Icon(Icons.notifications, color: Colors.white, size: 26),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
          ),
        );
      },
    ),
  ],
),

      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex >= 0 ? selectedIndex : 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: const Color(0xFF1E3A8A),
              backgroundColor: Colors.transparent,
              elevation: 0,
              onTap: (index) => onItemTapped(context, index),
              items: [
                _buildNavItem(Icons.home, "Home", 0),
                _buildNavItem(Icons.watch_later_outlined, "Events", 1),
                _buildNavItem(Icons.menu_book, "साहित्य", 2),
                _buildNavItem(Icons.book, "श्रमणोपासक", 3),
                _buildNavItem(Icons.event, "शिविर", 4),
                _buildNavItem(Icons.person, "Profile", 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
        ),
      ),
      label: label,
    );
  }
}
