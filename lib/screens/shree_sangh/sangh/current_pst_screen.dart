import 'package:flutter/material.dart';
import '../../base_scaffold.dart';

class CurrentPstScreen extends StatelessWidget {
  const CurrentPstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: const Center(
        child: Text(
          'वर्तमान कार्यकारिणी स्क्रीन',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
