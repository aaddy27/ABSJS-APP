import 'package:flutter/material.dart';

class GeneralDetailsCard extends StatelessWidget {
  const GeneralDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("सामान्य जानकारी", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("श्री साधुमार्गी संघ से परिचय: अभी अभी"),
            Text("घर से नजदीकी संघ भवन की दूरी: 5 कि.मी."),
            // You can replace with dynamic data from API if needed
          ],
        ),
      ),
    );
  }
}
