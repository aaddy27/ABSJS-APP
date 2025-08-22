import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'karyakarini/mahila_ex_president_screen.dart';
import 'karyakarini/mahila_pst_screen.dart';
import 'karyakarini/mahila_vp_sec_screen.dart';
import 'karyakarini/mahila_pravarti_sanyojak_screen.dart';
import 'karyakarini/mahila_ksm_members_screen.dart';

class MahilaKaryakariniScreen extends StatelessWidget {
  const MahilaKaryakariniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Centered Heading
            Center(
              child: Column(
                children: [
                  Text(
                    "महिला समिति कार्यकारिणी",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amita(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 3,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.pink.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // List of Cards
           Expanded(
  child: ListView(
    children: [
      _buildCard(
        context,
        "वर्तमान कार्यकारिणी",
        Icons.emoji_events_rounded,
        Colors.orangeAccent,
        const MahilaPstScreen(),
      ),
      _buildCard(
        context,
        "गौरवमयी अध्यक्षाएँ",
        Icons.star_border_rounded,
        Colors.deepPurpleAccent,
        const MahilaExPresidentScreen(),
      ),
      _buildCard(
        context,
        "VP / Secretary",
        Icons.people_alt_rounded,
        Colors.teal,
        const MahilaVpSecScreen(),
      ),
      _buildCard(
        context,
        "प्रवर्ति संयोजिकाएं",
        Icons.event_note_rounded,
        Colors.indigo,
        const MahilaPravartiSanyojakScreen(),
      ),
      _buildCard(
        context,
        "KSM Members",
        Icons.group_rounded,
        Colors.pink,
        const MahilaKsmMembersScreen(),
      ),
    ],
  ),
),

          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, Color color, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 28, color: color),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
