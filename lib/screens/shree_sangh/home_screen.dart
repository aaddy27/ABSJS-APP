import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../base_scaffold.dart';

// 🟠 Relative imports from the same `shree_sangh` folder
import 'sangh/sangh_home_screen.dart';
import 'sangh_pravartiya/sangh_pravartiya_home_screen.dart';
import 'aavedan_patra/aavedan_patra_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A cleaner way to manage menu items
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'संघ', 'icon': Icons.public, 'color': Colors.orange.shade700, 'screen': const SanghHomeScreen()},
      {'title': 'संघ प्रवृत्तियाँ', 'icon': Icons.campaign, 'color': Colors.green.shade700, 'screen': const SanghPravartiyaHomeScreen()},
      {'title': 'आवेदन पत्र', 'icon': Icons.description, 'color': Colors.indigo.shade600, 'screen': AavedanPatraHomeScreen()},
      // Add more items here easily in the future
      // {'title': 'फोटो गैलरी', 'icon': Icons.photo_library, 'color': Colors.deepPurple, 'screen': const PhotoGalleryHomeScreen()},
    ];

    return BaseScaffold(
      selectedIndex: -1, // No item selected on the bottom bar for home
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFFFF8E1).withOpacity(0.4), const Color(0xFFE0F2F1).withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildAnimatedGridView(menuItems),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset('assets/logo.png', height: 90),
        const SizedBox(height: 8),
        Text(
          '🙏 जय जिनेन्द्र 🙏',
          style: GoogleFonts.amita( // Using Amita font as requested
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedGridView(List<Map<String, dynamic>> items) {
    return AnimationLimiter(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.95, // Adjusted for better look
        ),
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = items[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildMenuCard(
                  context,
                  item['title'],
                  item['icon'],
                  item['color'],
                  item['screen'],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, Widget destinationScreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationScreen),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amita( // Using Amita font as requested
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      const Shadow(blurRadius: 1.0, color: Colors.black26, offset: Offset(1, 1))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
}