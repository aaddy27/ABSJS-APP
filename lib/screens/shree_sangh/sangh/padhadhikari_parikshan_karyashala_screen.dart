import 'package:flutter/material.dart';
import '../../base_scaffold.dart';

class PadhadhikariParikshanKaryashalaScreen extends StatelessWidget {
  const PadhadhikariParikshanKaryashalaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: const Center(
        child: Text(
          'पदाधिकारी प्रशिक्षण कार्यशाला स्क्रीन',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
