import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class ViewDashboard extends StatelessWidget {
  const ViewDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: 1, // 1 = "SAHITYA" tab in BottomNavigationBar
      body: Center(
        child: Text(
          "View Dashboard Content",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
