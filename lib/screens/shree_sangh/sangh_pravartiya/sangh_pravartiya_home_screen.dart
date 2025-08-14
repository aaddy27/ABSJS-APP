import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

// Screens import
import 'dharmik_pravartiya.dart';
import 'sheshnik_pravartiya.dart';
import 'sahityik_pravartiya.dart';
import 'samajik_pravartiya.dart';
import 'sangh_samridhi_yojna.dart';

class SanghPravartiyaHomeScreen extends StatelessWidget {
  const SanghPravartiyaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        "title": "धार्मिक प्रवृत्तियाँ",
        "icon": Icons.temple_hindu,
        "screen": const DharmikPravartiyaScreen(),
        "color1": Colors.orange.shade300,
        "color2": Colors.orange.shade600
      },
      {
        "title": "शैक्षणिक प्रवृत्तियाँ",
        "icon": Icons.school,
        "screen": const SheshnikPravartiyaScreen(),
        "color1": Colors.green.shade300,
        "color2": Colors.green.shade600
      },
      {
        "title": "साहित्यिक प्रवृत्तियाँ",
        "icon": Icons.menu_book,
        "screen": const SahityikPravartiyaScreen(),
        "color1": Colors.blue.shade300,
        "color2": Colors.blue.shade600
      },
      {
        "title": "सामाजिक प्रवृत्तियाँ",
        "icon": Icons.groups,
        "screen": const SamajikPravartiyaScreen(),
        "color1": Colors.purple.shade300,
        "color2": Colors.purple.shade600
      },
      {
        "title": "संघ समृद्धि योजना",
        "icon": Icons.account_balance_wallet,
        "screen": const SanghSamridhiYojnaScreen(),
        "color1": Colors.red.shade300,
        "color2": Colors.red.shade600
      },
    ];

    return BaseScaffold(
      selectedIndex: -1,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Heading Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                "संघ प्रवृत्तियाँ",
                style: GoogleFonts.hindSiliguri(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),

            // Decorative Line
            Container(
              height: 4,
              width: 110,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepOrange, Colors.orangeAccent],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            // Cards Grid with animations
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.05,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.9, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeOutBack,
                    builder: (context, double scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => items[index]["screen"]),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  items[index]["color1"],
                                  items[index]["color2"],
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      items[index]["color2"].withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(2, 4),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    items[index]["icon"],
                                    size: 46,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    items[index]["title"],
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
