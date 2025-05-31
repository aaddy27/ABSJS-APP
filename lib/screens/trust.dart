import 'package:flutter/material.dart';

class Trust extends StatelessWidget {
  const Trust({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'परिवार द्वारा संचालित चैरिटेबल ट्रस्ट/संस्थान',
            style: TextStyle(fontSize: 18),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add_box), text: 'ट्रस्ट जोड़ें'),
              Tab(icon: Icon(Icons.list_alt), text: 'ट्रस्ट सूची'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddTrustForm(),
            TrustListView(),
          ],
        ),
      ),
    );
  }
}

class AddTrustForm extends StatelessWidget {
  const AddTrustForm({super.key});

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField(label: 'ट्रस्ट का नाम *', icon: Icons.account_balance, hint: 'Enter Trust Name'),
          const SizedBox(height: 12),
          _buildTextField(label: 'वर्ष', icon: Icons.calendar_today, hint: 'Year'),
          const SizedBox(height: 12),
          _buildTextField(label: 'उद्देश्य', icon: Icons.lightbulb_outline, hint: 'Purpose'),
          const SizedBox(height: 12),
          _buildTextField(label: 'पद', icon: Icons.badge, hint: 'Position'),
          const SizedBox(height: 12),
          _buildTextField(label: 'संपर्क सूत्र', icon: Icons.person, hint: 'Contact Name'),
          const SizedBox(height: 12),
          _buildTextField(label: 'मोबाइल', icon: Icons.phone_android, hint: 'Mobile Number'),
          const SizedBox(height: 12),
          _buildTextField(label: 'ईमेल', icon: Icons.email, hint: 'Email'),
          const SizedBox(height: 12),
          _buildTextField(label: 'वेबसाइट', icon: Icons.language, hint: 'Website'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("प्रोफाइल में जोड़ें"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

class TrustListView extends StatelessWidget {
  const TrustListView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> dummyTrusts = [
      {
        'name': 'CIS (2024)',
        'position': 'Director',
        'contact': '9549813229',
        'mobile': '9549813220'
      },
      {
        'name': 'Demo (2021)',
        'position': 'Director',
        'contact': '9549813228',
        'mobile': '9549813228'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dummyTrusts.length,
      itemBuilder: (context, index) {
        final trust = dummyTrusts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(trust['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('पद: ${trust['position']}'),
                Text('संपर्क: ${trust['contact']}'),
                Text('मोबाइल: ${trust['mobile']}'),
              ],
            ),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
