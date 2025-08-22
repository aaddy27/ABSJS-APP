import 'package:flutter/material.dart';
import 'dart:ui';
import 'mahila_aavedan_patra.dart';
import 'mahila_prativedan.dart';

class DownloadHomeScreen extends StatelessWidget {
  const DownloadHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Heading
              const Text(
                "📥 डाउनलोड्स",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "आवेदन पत्र और प्रतिवेदन यहाँ से डाउनलोड करें",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildCard(
                      context,
                      title: "आवेदन पत्र",
                      subtitle: "फॉर्म और डॉक्यूमेंट डाउनलोड करें",
                      icon: Icons.description,
                      color1: Colors.orange,
                      color2: Colors.deepOrangeAccent,
                      screen: const MahilaAavedanPatraScreen(),
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      context,
                      title: "प्रतिवेदन",
                      subtitle: "सभी प्रतिवेदन डाउनलोड करें",
                      icon: Icons.assignment,
                      color1: Colors.blue,
                      color2: Colors.lightBlueAccent,
                      screen: const MahilaPrativedanScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color1,
      required Color color2,
      required Widget screen}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Card(
          elevation: 8,
          shadowColor: color1.withOpacity(0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color1.withOpacity(0.95), color2.withOpacity(0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
                  child: Row(
                    children: [
                      // 🔹 Icon
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 30, color: Colors.white),
                      ),
                      const SizedBox(width: 20),

                      // 🔹 Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
