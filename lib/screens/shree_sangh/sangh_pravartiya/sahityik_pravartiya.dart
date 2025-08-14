import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

// Import target screens
import '../../sahitya_screen.dart';
import '../../shramnopasak_screen.dart';

class SahityikPravartiyaScreen extends StatelessWidget {
  const SahityikPravartiyaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSection(
              context,
              titleEmoji: "📚",
              title: "साहित्य",
              subtitle:
                  "संघ की सभी पुस्तकों का संग्रह — ज्ञानवर्धक, प्रेरणादायक और उपयोगी साहित्य।",
              icon: Icons.menu_book_rounded,
              colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BaseScaffold(
                      selectedIndex: 2, // change index as per your nav order
                      body:  SahityaScreen(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            _buildSection(
              context,
              titleEmoji: "📰",
              title: "श्रमणोपासक",
              subtitle:
                  "मासिक पत्रिका जिसमें पूरे महीने की प्रमुख खबरें, गतिविधियाँ और लेख शामिल होते हैं।",
              icon: Icons.people_alt_rounded,
              colors: [Colors.deepOrange.shade400, Colors.red.shade600],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BaseScaffold(
                      selectedIndex: 3, // change index as per your nav order
                      body: const ShramnopasakScreen(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String titleEmoji,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Text(
          "$titleEmoji $title",
          style: GoogleFonts.hindSiliguri(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.deepOrange,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.hindSiliguri(
            fontSize: 15,
            color: Colors.black87,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        _buildNavCard(
          title: title,
          icon: icon,
          gradientColors: colors,
          onTap: onTap,
        ),
      ],
    );
  }

  Widget _buildNavCard({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.hindSiliguri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
