import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PravartiyaScreen extends StatelessWidget {
  const PravartiyaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 8, // 8 cards
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.brown.shade200, width: 1),
          ),
          color: Colors.brown.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pravartiya ${index + 1}",
                  style: GoogleFonts.amita(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                  "Praesent vitae eros eget tellus tristique bibendum. "
                  "Donec rutrum sed sem quis venenatis. "
                  "Proin viverra risus a eros volutpat tempor. "
                  "In quis arcu et eros porta lobortis sit amet at magna.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
