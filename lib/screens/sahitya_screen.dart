import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import category screens
import 'sahitya/naneshvani.dart';
import 'sahitya/ram_uvach.dart';
import 'sahitya/shri_ram_dhwani.dart';
import 'sahitya/ram_darshan.dart';
import 'sahitya/samta_katha_mala.dart';
import 'sahitya/anya.dart';
import 'sahitya/agam.dart';

class SahityaScreen extends StatelessWidget {
  const SahityaScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'name': 'नानेशवाणी साहित्य',
      'icon': Icons.menu_book_rounded,
      'color': Colors.deepPurple,
      'screen': NaneshvaniScreen()
    },
    {
      'name': 'राम उवाच साहित्य',
      'icon': Icons.auto_stories_rounded,
      'color': Colors.teal,
      'screen': RamUvachScreen()
    },
    {
      'name': 'श्री राम ध्वनि',
      'icon': Icons.library_books_rounded,
      'color': Colors.orange,
      'screen': ShriRamDhwaniScreen()
    },
    {
      'name': 'राम दर्शन',
      'icon': Icons.menu_book_rounded,
      'color': Colors.blue,
      'screen': RamDarshanScreen()
    },
    {
      'name': 'समता कथा माला',
      'icon': Icons.collections_bookmark_rounded,
      'color': Colors.green,
      'screen': SamtaKathaMalaScreen()
    },
    {
      'name': 'आगम, अहिंसा-समता एवं प्राकृत संस्थान',
      'icon': Icons.book_rounded,
      'color': Colors.pink,
      'screen': AgamScreen()
    },
    {
      'name': 'अन्य प्रकाशित साहित्य',
      'icon': Icons.bookmark_rounded,
      'color': Colors.indigo,
      'screen': AnyaScreen()
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Gradient Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF47A833), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Text(
              'साधुमार्गी पब्लिकेशन साहित्य',
              textAlign: TextAlign.center,
              style: GoogleFonts.amita(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Category List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final Color iconColor =
                    category['color'] ?? Colors.grey; // Fallback color

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => category['screen']),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: iconColor.withOpacity(0.2),
                        radius: 28,
                        child: Icon(
                          category['icon'],
                          color: iconColor,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        category['name'],
                        style: GoogleFonts.hind(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
