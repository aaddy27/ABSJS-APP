import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sahitya_screen.dart';
import 'login_screen.dart';
import 'mrm_screen.dart';
import 'upcoming_events_screen.dart';
import 'member_profile_screen.dart';
import 'vihar_screen.dart';

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
  const Center(child: CircularProgressIndicator()), // temporary while loading profile
];


@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async => false,  // 👈 disables back button
    child: Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 75,
                width: 75,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              const Text(
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
        backgroundColor: const Color(0xFF1E3A8A),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF1E3A8A),
          statusBarIconBrightness: Brightness.light,
        ),
        
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
              onTap: (index) async {
  if (index == 5) {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getString('member_id') ?? '';

    if (memberId.isNotEmpty) {
      Navigator.push(
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
  } else {
    setState(() {
      _currentIndex = index;
    });
  }
},

             items: [
  _buildNavItem(Icons.home, "Home", 0),
  _buildNavItem(Icons.access_time, "Events", 1),
  _buildNavItem(Icons.menu_book, "Sahitya", 2),
  _buildNavItem(Icons.book, "Shamnopasak", 3),
  _buildNavItem(Icons.event, "Shivir", 4),
  _buildNavItem(Icons.person, "Profile", 5), // ✅ New
],
            ),
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

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  String? memberId;

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
  void initState() {
    super.initState();
    loadMemberId();
  }

  Future<void> loadMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      memberId = prefs.getString('member_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (memberId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<Map<String, dynamic>> dashboardItems = [
      {
        "title": "ग्लोबल कार्ड",
        "image": "assets/images/mrm.jpg",
        "screen": MrmScreen(memberId: memberId!), // 👈 Pass memberId here
      },
      {"title": "श्री संघ", "image": "assets/logo_11zon.png", "screen": null},
      {"title": "महिला समिति", "image": "assets/images/mslogo.png", "screen": null},
      {"title": "युवा संघ", "image": "assets/images/yuva.png", "screen": null},
      {"title": "विहार", "image": "assets/images/vihar_seva.jpg", "screen": const ViharScreen()},
    ];

    double width = MediaQuery.of(context).size.width;
    double itemWidth = (width - 48) / 2;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 30),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dashboardItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                //card ke bich ke gap ko km yada krne ke liye 
                crossAxisSpacing: 6,
                mainAxisSpacing: 8,
                childAspectRatio: 0.90,
              ),
              itemBuilder: (context, index) {
                final item = dashboardItems[index];
                return _buildSquareCard(
                  context,
                  item["title"],
                  item["image"],
                  item["screen"],
                  width: itemWidth,
                );
              },
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  ),
                ],
                border: Border.all(color: Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📜 Quotes of the Day",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: PageView.builder(
                      itemCount: quotes.length,
                      controller: PageController(viewportFraction: 0.9),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade50,
                                  Colors.orange.shade100
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(Icons.format_quote,
                                    color: Colors.deepOrange),
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
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareCard(
    BuildContext context,
    String title,
    String imagePath,
    Widget? nextScreen, {
    required double width,
  }) {
    return InkWell(
      onTap: nextScreen != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => nextScreen),
              )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 120,
            width: 120,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFF1E3A8A), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(2, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: width,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A8A),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
