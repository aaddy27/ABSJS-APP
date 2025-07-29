import 'package:flutter/material.dart';
import '../../base_scaffold.dart';

class VivarnikaScreen extends StatelessWidget {
  const VivarnikaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: const Center(
        child: Text(
          'विवरणिका स्क्रीन',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
