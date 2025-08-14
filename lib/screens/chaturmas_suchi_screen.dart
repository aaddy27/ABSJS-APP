import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class ChaturmasSuchiScreen extends StatelessWidget {
  const ChaturmasSuchiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      selectedIndex: -1, // No bottom navigation item selected
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📜 चातुर्मास सूची",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "यहां आप आचार्य एवं मुनि श्री का चातुर्मास स्थल देख सकते हैं।",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Example static list items
            _ChaturmasCard(
              title: "आचार्य श्री XYZ",
              subtitle: "स्थान: जयपुर, राजस्थान",
            ),
            _ChaturmasCard(
              title: "मुनि श्री ABC",
              subtitle: "स्थान: दिल्ली",
            ),
            _ChaturmasCard(
              title: "मुनि श्री DEF",
              subtitle: "स्थान: अहमदाबाद",
            ),
          ],
        ),
      ),
    );
  }
}

class _ChaturmasCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ChaturmasCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.menu_book, color: Color(0xFF1E3A8A)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
