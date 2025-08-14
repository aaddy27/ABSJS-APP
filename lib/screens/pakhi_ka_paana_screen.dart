import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class PakhiKaPaanaScreen extends StatelessWidget {
  const PakhiKaPaanaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      selectedIndex: -1,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🕊️ पाखी का पाना",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "यहां आप पक्षियों की सेवा और संबंधित गतिविधियों की जानकारी देख सकते हैं।",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
