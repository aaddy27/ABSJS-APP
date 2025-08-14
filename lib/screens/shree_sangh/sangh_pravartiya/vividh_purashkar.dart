import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

class VividhPurashkarScreen extends StatelessWidget {
  const VividhPurashkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Center(
        child: Text(
          'विविध पुरस्कार कंटेंट यहाँ होगा',
          style: GoogleFonts.hindSiliguri(fontSize: 18),
        ),
      ),
    );
  }
}
