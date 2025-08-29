import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'pravartiya_screen.dart';
import 'mahila_karyakarini_screen.dart';
import 'downloads/download_home_screen.dart';
import 'events/mahila_events_screen.dart';
import 'mahila_photo_gallery_screen.dart';

class LayoutScreen extends StatefulWidget {
  final String title;
  final Widget? body; // ✅ optional

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
    return Scaffold(
      extendBody: true,

      // ✅ Common AppBar (हर जगह रहेगा)
    appBar: PreferredSize(
  preferredSize: const Size.fromHeight(60),
  child: AppBar(
    elevation: 0,
    backgroundColor: const Color(0xFF1E3A8A), // 🔵 Solid color set
    title: Row(
      children: [
        Image.asset("assets/images/mslogo.png", height: 45),
        const SizedBox(width: 12),
        Text(
          widget.title,
          style: GoogleFonts.amita(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // ✅ Text ko white rakha
          ),
        ),
      ],
    ),
    centerTitle: false,
  ),
),


      // ✅ अगर custom body मिला तो वही दिखाओ, वरना nav वाला screen
      body: widget.body ?? _screens[_selectedIndex],

      // ✅ BottomNavigationBar सिर्फ main tabs में दिखेगा
      bottomNavigationBar: widget.body == null
          ? Container(
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
      label: 'गलेरी',
    ),
  ],
                ),
              ),
            )
          : null,
    );
  }
}
