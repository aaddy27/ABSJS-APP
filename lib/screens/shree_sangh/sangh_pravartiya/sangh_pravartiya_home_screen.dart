import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

class SanghPravartiyaHomeScreen extends StatelessWidget {
  const SanghPravartiyaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Center(
        child: Text(
          'संघ प्रवृत्तियाँ कंटेंट यहाँ होगा',
          style: GoogleFonts.hindSiliguri(fontSize: 18),
        ),
      ),
    );
  }
}
