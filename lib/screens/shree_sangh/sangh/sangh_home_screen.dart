// lib/screens/shree_sangh/sangh/sangh_home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

// ✅ Import 6 destination screens (added vp_sec_screen)
import 'vivarnika_screen.dart';
import 'ex_president_screen.dart';
import 'current_pst_screen.dart';
import 'vp_sec_screen.dart';
import 'ksm_member_screen.dart';
import 'padhadhikari_parikshan_karyashala_screen.dart';

class SanghHomeScreen extends StatelessWidget {
  const SanghHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFDE7), Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 20),

            // ✅ Logo and optional heading
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 90,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'श्री संघ',
                    style: GoogleFonts.kalam(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Grid of Options
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                OptionCard(
                  title: 'विवरणिका',
                  icon: Icons.menu_book,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VivarnikaScreen(),
                      ),
                    );
                  },
                ),
                OptionCard(
                  title: 'पूर्व अध्यक्षगण',
                  icon: Icons.verified_user,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExPresidentScreen(),
                      ),
                    );
                  },
                ),
                OptionCard(
                  title: 'वर्तमान कार्यकारिणी',
                  icon: Icons.groups,
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CurrentPstScreen(),
                      ),
                    );
                  },
                ),

                // --- NEW: VP SEC card (placed after वर्तमान कार्यकारिणी) ---
                OptionCard(
                  title: 'VP Sec',
                  icon: Icons.how_to_reg,
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VpSecScreen(),
                      ),
                    );
                  },
                ),

                OptionCard(
                  title: 'कार्यसमिति सदस्य',
                  icon: Icons.account_tree_outlined,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KsmMemberScreen(),
                      ),
                    );
                  },
                ),
                OptionCard(
                  title: 'पदाधिकारी प्रशिक्षण कार्यशाला',
                  icon: Icons.school,
                  color: Colors.brown,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PadhadhikariParikshanKaryashalaScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.4), width: 1),
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
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
