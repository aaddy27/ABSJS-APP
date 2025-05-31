import 'package:flutter/material.dart';

class ShivirScreen extends StatelessWidget {
  const ShivirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "कार्य प्रगति पर है, सहयोग बनाए रखें। धन्यवाद!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
