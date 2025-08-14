import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class SamparkScreen extends StatelessWidget {
  const SamparkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      selectedIndex: -1, // ❌ Bottom nav highlight नहीं होगा
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📞 संपर्क जानकारी",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            SizedBox(height: 10),
            Text("✉️ Email: info@sadhumargi.in"),
            Text("📱 Phone: +91-9876543210"),
            Text("🏢 Address: Sadhumargi Jain Sangh, Rajasthan, India"),
          ],
        ),
      ),
    );
  }
}
