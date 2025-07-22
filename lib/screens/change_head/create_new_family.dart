import 'package:flutter/material.dart';

class CreateNewFamilyScreen extends StatelessWidget {
  const CreateNewFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("नया परिवार बनाएँ")),
      body: const Center(child: Text("नया परिवार बनाने का फॉर्म")),
    );
  }
}
