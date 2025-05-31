import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sahitya_screen.dart';
import 'login_screen.dart';
import 'mrm_screen.dart';
import 'upcoming_events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  final List<Widget> _screens = [
    const HomeDashboard(),
     UpcomingEventsScreen(),
     SahityaScreen(),
    const Center(child: Text("Shamnopasak Coming Soon")),
    const Center(child: Text("Shivir Coming Soon")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
  padding: const EdgeInsets.only(left: 8.0), // move the entire title slightly left
  child: Row(
    mainAxisSize: MainAxisSize.min,  // shrink to content size
    mainAxisAlignment: MainAxisAlignment.start,
    children: const [
      CircleAvatar(
        backgroundImage: AssetImage('assets/logo.png'),
        radius: 20,
      ),
      SizedBox(width: 8),
      Text(
        "Sadhumargi Jain Sangh",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF1E3A8A),
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
      ),
      body: _screens[_currentIndex],
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
              currentIndex: _currentIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: const Color(0xFF1E3A8A),
              backgroundColor: Colors.transparent,
              elevation: 0,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                _buildNavItem(Icons.home, "Home", 0),
                _buildNavItem(Icons.access_time, "Events", 1),
                _buildNavItem(Icons.menu_book, "Sahitya", 2),
                _buildNavItem(Icons.book, "Shamnopasak", 3),
                _buildNavItem(Icons.event, "Shivir", 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: isSelected ? Colors.white : const Color(0xFF1E3A8A)),
      ),
      label: label,
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  final List<String> imageList = const [
    'assets/images/slider1.jpg',
    'assets/images/slider2.jpg',
    'assets/images/slider3.jpg',
  ];

  final List<String> quotes = const [
    "Truth is the highest religion.",
    "Non-violence is the greatest virtue.",
    "Control your desires, attain liberation.",
    "Right knowledge leads to right conduct.",
    "Live and let live."
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: imageList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imageList[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildCard(context, "Global Card", "assets/images/mrm.jpg", MrmScreen()),
                  _buildCard(context, "Shree Sangh", "assets/logo_11zon.png", null),
                  _buildCard(context, "Mahila Samiti", "assets/images/mslogo.png", null),
                  _buildCard(context, "Yuva Sangh", "assets/images/yuva.png", null),
                  _buildCard(context, "Vihar", "assets/images/vihar_seva.jpg", null),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 80,
              child: PageView.builder(
                itemCount: quotes.length,
                controller: PageController(viewportFraction: 0.9),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(2, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.format_quote, color: Colors.deepOrange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              quotes[index],
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String imagePath, Widget? nextScreen) {
    return InkWell(
      onTap: nextScreen != null
          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => nextScreen))
          : null,
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: Offset(2, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: ClipOval(
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF1E3A8A),
              shadows: [
                Shadow(
                  blurRadius: 1.0,
                  color: Colors.black26,
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
