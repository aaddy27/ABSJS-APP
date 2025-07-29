import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sahitya_screen.dart';
import 'login_screen.dart';
import 'mrm_screen.dart';
import 'upcoming_events_screen.dart';
import 'member_profile_screen.dart';
import 'vihar_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:laravel_auth_flutter/screens/shree_sangh/home_screen.dart' as shree;


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
  String? thoughtDate;
String? thoughtText;
bool isThoughtLoading = true;
String? viharDate;
String? viharThana;
String? viharLocation;
bool isViharLoading = true;

 final List<String> imageList = const [
    'assets/images/slider1.jpg',
    'assets/images/slider2.jpg',
    'assets/images/slider3.jpg',
  ];


  @override
void initState() {
  super.initState();
  loadMemberId();
  fetchLatestThought();
  fetchLatestVihar();
}

Future<void> fetchLatestThought() async {
  try {
    final response = await http.get(Uri.parse('https://website.sadhumargi.in/api/latest-thought'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        thoughtDate = data['date'];
        thoughtText = data['thought'];
        isThoughtLoading = false;
      });
    } else {
      setState(() {
        isThoughtLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      isThoughtLoading = false;
    });
  }
}
Future<void> fetchLatestVihar() async {
  try {
    final response = await http.get(Uri.parse('https://website.sadhumargi.in/api/vihar/latest'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        viharDate = data['formatted_date'];
        viharThana = data['aadi_thana'];
        viharLocation = data['location'];
        isViharLoading = false;
      });
    } else {
      setState(() {
        isViharLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      isViharLoading = false;
    });
  }
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
{
  "title": "श्री संघ",
  "image": "assets/logo_11zon.png",
  "screen": const shree.HomeScreen(), // ✅ corrected
},

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
           isThoughtLoading
  ? const Center(child: CircularProgressIndicator())
  : Container(
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
            "🧠 आज का विचार",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 12),
          if (thoughtDate != null)
            Text(
              "📅 $thoughtDate",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          const SizedBox(height: 6),
          if (thoughtText != null)
            Text(
              thoughtText!,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
        ],
      ),
    ),

           const SizedBox(height: 30),

isViharLoading
    ? const Center(child: CircularProgressIndicator())
    : Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFF4CAF50), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🔔 आज की विहार जानकारी",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text("तारीख: $viharDate", style: const TextStyle(color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.place, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text("आदि थाना: $viharThana", style: const TextStyle(color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.hotel, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text("रात्रि विश्राम हेतु: $viharLocation", style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),

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
