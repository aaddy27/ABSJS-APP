import 'package:flutter/material.dart';

class AddNewMemberScreen extends StatelessWidget {
  const AddNewMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("नया सदस्य जोड़ें")),
      body: const Center(child: Text("नया सदस्य जोड़ने का फॉर्म")),
    );
  }
}
