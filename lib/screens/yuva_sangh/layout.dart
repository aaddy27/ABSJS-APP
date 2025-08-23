import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'pravartiya_screen.dart';
import 'news_screen.dart';
import 'photo_gallery_screen.dart';
import 'karyakarini_sadasya_screen.dart';

enum YuvaTab { news, pravartiya, home, members, gallery }

class YuvaSanghLayout extends StatefulWidget {
  const YuvaSanghLayout({
    super.key,
    this.initialIndex = 0,
    this.customChild,
    this.customTitle,
  });

  /// 0: Home, 1: News, 2: Pravartiya, 3: Members, 4: Photo Gallery
  final int initialIndex;
  final Widget? customChild;
  final String? customTitle;

  @override
  State<YuvaSanghLayout> createState() => _YuvaSanghLayoutState();
}

class _YuvaSanghLayoutState extends State<YuvaSanghLayout> {
  late int _currentIndex;
  late bool _showCustom;

  // Brown palette
  static const Color _brown = Color(0xFF6D4C41);
  static const Color _brownDark = Color(0xFF5D4037);
  static const Color _brownLight = Color(0xFFBCAAA4);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
    _showCustom = widget.customChild != null; // ✅ custom page initially visible if provided
  }

  void _goTo(int index) {
    setState(() {
      _currentIndex = index.clamp(0, 4);
      _showCustom = false; // ✅ switch away from custom page to tab layout
    });
  }

  PreferredSizeWidget _buildAppBar() {
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      backgroundColor: _brown,
      elevation: 2,
      centerTitle: true,
      leadingWidth: canPop ? 100 : 56,
      leading: Row(
        children: [
          if (canPop)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          Padding(
            padding: EdgeInsets.only(left: canPop ? 0 : 8.0),
            child: Image.asset(
              'assets/images/yuva-r.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      title: Text(
        widget.customTitle ?? 'समता युवा संघ',
        style: GoogleFonts.amita(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildBody() {
    // ✅ custom page दिखाओ जब तक _showCustom true है
    if (_showCustom && widget.customChild != null) {
      return widget.customChild!;
    }

    // ✅ अब normal tabbed layout
    return IndexedStack(
      index: _currentIndex,
      children: const [
        YuvaHomeScreen(),
        NewsScreen(),
        PravartiyaScreen(),
        KaryakariniSadasyaScreen(),
        PhotoGalleryScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showTabs = !_showCustom; // bottom nav तभी जब custom view hide हो

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _brownDark,
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () => _goTo(0), // ✅ Home दबाते ही custom से बाहर और Home tab
        child: const Icon(Icons.home),
      ),

      bottomNavigationBar: showTabs
          ? BottomAppBar(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 8,
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
            )
          : null, // ❌ custom page में bottom nav hidden
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
                height: 1.0,
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
