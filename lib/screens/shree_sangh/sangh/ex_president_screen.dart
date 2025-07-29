import 'package:flutter/material.dart';
import '../../base_scaffold.dart';

class ExPresidentScreen extends StatelessWidget {
  const ExPresidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: const Center(
        child: Text(
          'पूर्व अध्यक्षगण स्क्रीन',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
