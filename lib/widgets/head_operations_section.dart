import 'package:flutter/material.dart';

class HeadOperationsSection extends StatelessWidget {
  const HeadOperationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.yellow.shade100,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("मुखिया विशेष विकल्प", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text("Add Member"),
                  onPressed: () {
                    // Navigate to Add Member Screen
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.family_restroom),
                  label: const Text("New Family"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () {
                    // Create New Family logic
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: "मुखिया चयन करें"),
                    items: [
                      DropdownMenuItem(value: "100072", child: Text("Rajendra Golchha")),
                      DropdownMenuItem(value: "100108", child: Text("Pankaj Golchha")),
                    ],
                    onChanged: (value) {
                      // Handle change head
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Call API to change head
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("परिवर्तन करें"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
