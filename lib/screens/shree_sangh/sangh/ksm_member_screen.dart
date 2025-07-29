import 'package:flutter/material.dart';
import '../../base_scaffold.dart';

class KsmMemberScreen extends StatelessWidget {
  const KsmMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: const Center(
        child: Text(
          'कार्यसमिति सदस्य स्क्रीन',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
