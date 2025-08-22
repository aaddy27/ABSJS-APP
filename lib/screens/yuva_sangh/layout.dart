import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'pravartiya_screen.dart';
import 'news_screen.dart';
import 'photo_gallery_screen.dart';


enum YuvaTab { news, pravartiya, home, members, gallery }

class YuvaSanghLayout extends StatefulWidget {
  const YuvaSanghLayout({super.key, this.initialIndex = 0});

  /// 0: Home, 1: News, 2: Pravartiya, 3: Members, 4: Photo Gallery
  final int initialIndex;

  @override
  State<YuvaSanghLayout> createState() => _YuvaSanghLayoutState();
}

class _YuvaSanghLayoutState extends State<YuvaSanghLayout> {
  late int _currentIndex;

  // Brown palette
  static const Color _brown = Color(0xFF6D4C41); // AppBar, selected
  static const Color _brownDark = Color(0xFF5D4037); // FAB
  static const Color _brownLight = Color(0xFFBCAAA4); // unselected hint

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _goTo(int index) => setState(() => _currentIndex = index);

PreferredSizeWidget _buildAppBar() {
  final canPop = Navigator.of(context).canPop(); // check if back possible
  return AppBar(
    backgroundColor: _brown,
    elevation: 2,
    centerTitle: true,
    leadingWidth: canPop ? 100 : 72, // back + logo ke liye thoda width zyada
    leading: Row(
      children: [
        if (canPop) // back button tabhi dikhe jab back possible ho
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Image.asset(
            'assets/images/yuva-r.png',
            height: 45,  // 🔼 size badhaya
            width: 45,
            fit: BoxFit.contain,
          ),
        ),
      ],
    ),
    title: Text(
      'समता युवा संघ',
      style: GoogleFonts.amita(
        fontSize: 32, // thoda bada
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.1,
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),

      // IndexedStack keeps state of each tab
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          YuvaHomeScreen(),
          NewsScreen(),
           PravartiyaScreen(), 
          _PlaceholderScreen(title: 'Members'),
          PhotoGalleryScreen(),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _brownDark,
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () => _goTo(0), // Home center FAB
        child: const Icon(Icons.home),
      ),

      // 👇 Overflow fix: wrap BottomAppBar content in SafeArea + reduce paddings
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60, // a little tighter than 64
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side (2)
                Row(
                  children: [
                    _NavItem(
                      icon: Icons.article_outlined,
                      label: 'News',
                      selected: _currentIndex == 1,
                      onTap: () => _goTo(1),
                      selectedColor: _brown,
                      unselectedColor: _brownLight,
                    ),
                    _NavItem(
                      icon: Icons.campaign_outlined,
                      label: 'Pravartiya',
                      selected: _currentIndex == 2,
                      onTap: () => _goTo(2),
                      selectedColor: _brown,
                      unselectedColor: _brownLight,
                    ),
                  ],
                ),
                // Right side (2)
                Row(
                  children: [
                    _NavItem(
                      icon: Icons.group_outlined,
                      label: 'Members',
                      selected: _currentIndex == 3,
                      onTap: () => _goTo(3),
                      selectedColor: _brown,
                      unselectedColor: _brownLight,
                    ),
                    _NavItem(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      selected: _currentIndex == 4,
                      onTap: () => _goTo(4),
                      selectedColor: _brown,
                      unselectedColor: _brownLight,
                    ),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        // tighter vertical padding avoids overflow with large text scales
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.amita(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
                height: 1.0, // compact line-height
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Temporary placeholders for other tabs
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title Screen (Coming Soon)',
        style: GoogleFonts.amita(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          height: 1.1,
        ),
      ),
    );
  }
}
