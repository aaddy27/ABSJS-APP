import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

class PhotoGalleryHomeScreen extends StatelessWidget {
  const PhotoGalleryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Center(
        child: Text(
          'फोटो गैलरी कंटेंट यहाँ होगा',
          style: GoogleFonts.hindSiliguri(fontSize: 18),
        ),
      ),
    );
  }
}
