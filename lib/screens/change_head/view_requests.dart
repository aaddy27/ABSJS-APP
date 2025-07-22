import 'package:flutter/material.dart';

class ViewRequestsScreen extends StatelessWidget {
  const ViewRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("अनुरोध देखें")),
      body: const Center(child: Text("मुखिया परिवर्तन के अनुरोधों की सूची")),
    );
  }
}
