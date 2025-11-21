// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ---- Your existing screens ----
import 'package:laravel_auth_flutter/screens/shree_sangh/home_screen.dart' as shree;
import 'package:laravel_auth_flutter/screens/spf/home_screen.dart' as spf;
import 'arth_sahyog.dart';
import 'chaturmas_suchi_screen.dart';
import 'login_screen.dart';
import 'mahila_samiti/layout_screen.dart';
import 'member_profile_screen.dart';
import 'mrm_screen.dart';
import 'pakhi_ka_paana_screen.dart';
import 'sahitya_screen.dart';
import 'sampark_screen.dart';
import 'shivir_screen.dart';
import 'shramnopasak_screen.dart';
import 'upcoming_events_screen.dart';
import 'vihar_screen.dart';
import 'yuva_sangh/layout.dart';
import 'notifications/notifications_screen.dart';

// ---- Split widgets (new files) ----
import 'home_screen/home_grid_cards.dart';
import 'home_screen/home_info_cards.dart';

/// -----------------------
/// Design System
/// -----------------------
class AppStyle {
  static const Color blue = Color(0xFF1E3A8A);
  static const Color bg = Color(0xFFF7F9FC);
  static const Color text = Color(0xFF0F172A);
  static const Color subtle = Color(0xFF64748B);

  static const double rXl = 20;
  static const double rLg = 18;
  static const double rMd = 14;

  static const List<BoxShadow> shadow = [
    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4)),
  ];

  static TextStyle get titleSm => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: text,
      );

  static TextStyle get titleMd => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: blue,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14.5,
        height: 1.35,
        color: text,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12.5,
        color: subtle,
        fontWeight: FontWeight.w600,
      );
}

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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  final List<Widget> _screens = const [
    HomeDashboard(),
    UpcomingEventsScreen(),
    SahityaScreen(),
    ShramnopasakScreen(),
    ShivirScreen(),
    Center(child: CircularProgressIndicator()),
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final clampedTextScaler = media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);

    return MediaQuery(
      data: media.copyWith(textScaler: clampedTextScaler),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: AppStyle.bg,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1E3A8A),
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Color(0xFF1E3A8A),
              statusBarIconBrightness: Brightness.light,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: Image.asset('assets/logo.png', height: 50, fit: BoxFit.contain),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "श्री अ.भा.सा जैन संघ",
                      style: GoogleFonts.amita(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                },
              ),
            ],
          ),
          body: SafeArea(
            top: false, // AppBar already manages top
            child: _screens[_currentIndex],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
              ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentIndex,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: AppStyle.blue,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onTap: (index) async {
                    if (index == 5) {
                      final prefs = await SharedPreferences.getInstance();
                      final memberId = prefs.getString('member_id') ?? '';
                      if (memberId.isNotEmpty) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => MemberProfileScreen(memberId: memberId)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Member ID not found")));
                      }
                    } else {
                      setState(() => _currentIndex = index);
                    }
                  },
                  items: [
                    _buildNavItem(Icons.home, "Home", 0),
                    _buildNavItem(Icons.access_time, "Events", 1),
                    _buildNavItem(Icons.menu_book, "साहित्य", 2),
                    _buildNavItem(Icons.book, "श्रमणोपासक", 3),
                    _buildNavItem(Icons.event, "शिविर", 4),
                    _buildNavItem(Icons.person, "Profile", 5),
                  ],
                ),
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
        decoration: BoxDecoration(color: isSelected ? AppStyle.blue : Colors.transparent, shape: BoxShape.circle),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: isSelected ? Colors.white : AppStyle.blue),
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
  static const Color kBlue = AppStyle.blue;

  String? memberId;

  String? thoughtDate;
  String? thoughtText;
  bool isThoughtLoading = true;

  String? viharDate;
  String? viharThana;
  String? viharLocation;
  bool isViharLoading = true;

  bool isSliderLoading = true;
  List<String> imageList = [];

  final PageController _pageController = PageController(viewportFraction: 1);
  Timer? _sliderTimer;
  int _currentSlide = 0;

  @override
  void initState() {
    super.initState();
    _loadMemberId();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    await Future.wait([
      _fetchSliderImages(),
      _fetchLatestThought(),
      _fetchLatestVihar(),
    ]);
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startSliderAutoplay() {
    _sliderTimer?.cancel();
    if (imageList.isEmpty) return;
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || imageList.isEmpty) return;
      _currentSlide = (_currentSlide + 1) % imageList.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(_currentSlide, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      }
    });
  }

  Future<void> _fetchSliderImages() async {
  try {
    final response = await http.get(Uri.parse('https://website.sadhumargi.in/api/mobile-slider'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final urls = List<String>.from(data.map((item) => "https://website.sadhumargi.in${item['image']}"));

      setState(() {
        imageList = urls;
        isSliderLoading = false;
      });

      // Precache all images (non-blocking, but helps render fast)
      for (final url in imageList) {
        precacheImage(NetworkImage(url), context).catchError((_) {
          // ignore any single-image precache failure
        });
      }

      _startSliderAutoplay();
    } else {
      setState(() => isSliderLoading = false);
    }
  } catch (_) {
    setState(() => isSliderLoading = false);
  }
}


  // Replace your existing _fetchLatestThought() with this:
Future<void> _fetchLatestThought() async {
  try {
    final response = await http.get(Uri.parse('https://website.sadhumargi.in/api/latest-thought'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String? createdAt = data['created_at'] as String?;
      final String? thought = data['thought'] as String?;

      debugPrint('fetchLatestThought -> created_at: $createdAt, thought: $thought');

      if (mounted) {
        setState(() {
          // keep null if not present, else full ISO string
          thoughtDate = (createdAt != null && createdAt.trim().isNotEmpty) ? createdAt.trim() : null;
          thoughtText = (thought != null && thought.trim().isNotEmpty) ? thought.trim() : '-';
          isThoughtLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => isThoughtLoading = false);
    }
  } catch (e) {
    debugPrint('fetchLatestThought error: $e');
    if (mounted) setState(() => isThoughtLoading = false);
  }
}

  Future<void> _fetchLatestVihar() async {
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
        setState(() => isViharLoading = false);
      }
    } catch (_) {
      setState(() => isViharLoading = false);
    }
  }

  Future<void> _loadMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => memberId = prefs.getString('member_id'));
  }

  @override
  Widget build(BuildContext context) {
    if (memberId == null) return const Center(child: CircularProgressIndicator());

    final width = MediaQuery.of(context).size.width;

    // ✅ Responsive breakpoints for columns
    final int columns = width >= 1000
        ? 4
        : width >= 720
            ? 3
            : 2;

    // ✅ Slider height responsive
    final double sliderHeight = width >= 900
        ? 320
        : width >= 720
            ? 280
            : math.max(180, width * 0.48);

    // --- DASHBOARD ITEMS (6 grid cards) ---
    final List<Map<String, dynamic>> dashboardItems = [
      {"title": "ग्लोबल कार्ड", "image": "assets/images/mrm.jpg", "screen": MrmScreen(memberId: memberId!)},
      {"title": "श्री संघ", "image": "assets/11zon_resized.png", "screen": const shree.HomeScreen()},
      {"title": "महिला समिति", "image": "assets/images/mslogo.png", "screen": const LayoutScreen(title: "श्री अ.भा.सा. जैन महिला समिति")},      
      {"title": "युवा संघ", "image": "assets/images/yuva.png", "screen": const YuvaSanghLayout(initialIndex: 0)},
      {"title": "SPF", "image": "assets/images/spf.jpg", "screen": const spf.HomeScreen()},
      {"title": "विहार", "image": "assets/images/vihar_seva.jpg", "screen": const ViharScreen()},
      {"title": "अर्थ सहयोग", "image": "assets/images/donation.webp", "screen": const ArthSahyogScreen()},
    ];

    return RefreshIndicator(
      onRefresh: _fetchAll,
      color: AppStyle.blue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),

              /// ---- Slider (Yahi file me रहेगा) ----
              SizedBox(
                height: sliderHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppStyle.rXl),
                  child: Stack(
                    children: [
                      if (isSliderLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (imageList.isEmpty)
                        Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        )
                      else
                        Listener(
                          onPointerDown: (_) => _sliderTimer?.cancel(),
                          onPointerUp: (_) => _startSliderAutoplay(),
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (i) => setState(() => _currentSlide = i),
                            itemCount: imageList.length,
                            itemBuilder: (_, index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      imageList[index],
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) =>
                                          progress == null ? child : const Center(child: CircularProgressIndicator()),
                                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 50)),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.transparent, Colors.black26],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Dots
                      if (!isSliderLoading && imageList.isNotEmpty)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              imageList.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                height: 8,
                                width: _currentSlide == i ? 18 : 8,
                                decoration: BoxDecoration(
                                  color: _currentSlide == i ? Colors.white : Colors.white70,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white, width: 0.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ---- 6 Grid Cards (Split widget/file) ----
              HomeGridCards(
                columns: columns,
                dashboardItems: dashboardItems,
              ),

              const SizedBox(height: 20),

              /// ---- Action Tiles + Info Cards (Split widget/file) ----
              HomeInfoCards(
                onTapSampark: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SamparkScreen())),
                onTapPakhi: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PakhiKaPaanaScreen())),
                onTapChaturmas: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChaturmasSuchiScreen())),
                thoughtDate: thoughtDate,
                thoughtText: thoughtText,
                isThoughtLoading: isThoughtLoading,
                viharDate: viharDate,
                viharThana: viharThana,
                viharLocation: viharLocation,
                isViharLoading: isViharLoading,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
