import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'home_screen.dart';
import 'pravartiya_screen.dart';
import 'mahila_karyakarini_screen.dart';
import 'downloads/download_home_screen.dart';
import 'events/mahila_events_screen.dart';
import 'mahila_photo_gallery_screen.dart';

class LayoutScreen extends StatefulWidget {
  final String title;
  final Widget? body; // optional override body

  const LayoutScreen({
    super.key,
    required this.title,
    this.body,
  });

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      MahilaHomeScreen(),
      PravartiyaScreen(),
      MahilaKaryakariniScreen(),
      DownloadHomeScreen(),
      MahilaEventsScreen(),
      MahilaPhotoGalleryScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Breakpoint-based base font + FittedBox for extra safety
    final width = MediaQuery.of(context).size.width;
    double baseTitleSize = 20;
    if (width < 360) {
      baseTitleSize = 16; // very small phones
    } else if (width < 480) {
      baseTitleSize = 18; // typical phones
    } else if (width < 720) {
      baseTitleSize = 20; // large phones/small tablets
    } else {
      baseTitleSize = 22; // tablets+
    }

    return Scaffold(
      extendBody: true,

      // ---------- Common AppBar ----------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF1E3A8A),
          titleSpacing: 12,
          title: Row(
            children: [
              Image.asset("assets/images/mslogo.png", height: 45),
              const SizedBox(width: 12),
              // Title that shrinks if space is tight
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.amita(
                      fontSize: baseTitleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
      ),

      // ---------- Body ----------
      body: widget.body ?? _screens[_selectedIndex],

      // ---------- Bottom Navigation (only when using main tabs) ----------
      bottomNavigationBar: widget.body == null
          ? Container
          (
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
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
                  showUnselectedLabels: true,
                  selectedLabelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w700),
                  unselectedLabelStyle: GoogleFonts.hindSiliguri(),
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
                      icon: Icon(Icons.group),
                      label: 'कार्यकारिणी',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.download),
                      label: 'DOWNLOAD',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.notifications),
                      label: 'गतिविधिया',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.photo_library),
                      label: 'गैलरी',
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
