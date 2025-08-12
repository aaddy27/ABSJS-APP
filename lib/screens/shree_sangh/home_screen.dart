import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../base_scaffold.dart';

// 🟠 Relative imports from the same `shree_sangh` folder
import 'sangh/sangh_home_screen.dart';
import 'sangh_pravartiya/sangh_pravartiya_home_screen.dart';
import 'photo_gallery/photo_gallery_home_screen.dart';
import 'aavedan_patra/aavedan_patra_home_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFE0F2F1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', height: 90),
                      const SizedBox(height: 8),
                      Text(
                        '🙏 जय जिनेन्द्र 🙏',
                        style: GoogleFonts.kalam(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 30,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildMenuCard(context, 'संघ', Icons.public, Colors.orange),
                    _buildMenuCard(context, 'संघ प्रवृत्तियाँ', Icons.campaign, Colors.green.shade700),
                    _buildMenuCard(context, 'फोटो गैलरी', Icons.photo_library, Colors.deepPurple),
                    _buildMenuCard(context, 'आवेदन पत्र', Icons.description, Colors.indigo),
                    _buildMenuCard(context, 'OPTION 5', Icons.event, Colors.teal),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  '',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        if (title.trim() == 'संघ') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SanghHomeScreen()),
          );
        } else if (title.trim() == 'संघ प्रवृत्तियाँ') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SanghPravartiyaHomeScreen()),
          );
        } else if (title.trim() == 'फोटो गैलरी') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PhotoGalleryHomeScreen()),
          );
        } else if (title.trim() == 'आवेदन पत्र') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AavedanPatraHomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title tapped')),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
