import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class Education extends StatelessWidget {
  const Education({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: 3,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.green.shade100,
              child: const TabBar(
                indicatorColor: Colors.green,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(text: 'शिक्षा फ़ॉर्म'),
                  Tab(text: 'शिक्षा सूची'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildEducationForm(),
                  _buildEducationList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Education Form Tab ----------
  Widget _buildEducationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 5,
        color: Colors.green.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'शिक्षा फ़ॉर्म',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade800),
              ),
              const SizedBox(height: 20),

              // First Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'शिक्षा *'),
                      items: ['Nursery', 'High School', 'PHD']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'विवरण'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Second Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'अंक'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'संस्थान'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Year Row
              TextFormField(
                decoration: const InputDecoration(labelText: 'वर्ष'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Submit Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("प्रोफाइल में जोड़ें"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Education List Tab ----------
  Widget _buildEducationList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 5,
        color: Colors.orange.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'शिक्षा सूची',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _buildEducationCard(1, 'Nursery (2000)', 'RSV', '89%', 'RSV School Bikaner'),
                  const SizedBox(height: 12),
                  _buildEducationCard(2, 'PHD (2009)', 'Software Developement', '89%', 'IIT Delhi'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Education Card Widget ----------
  Widget _buildEducationCard(
    int index, String education, String desc, String marks, String institute) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('क्रमांक: $index', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('शिक्षा: $education'),
            Text('विवरण: $desc'),
            Text('अंक: $marks'),
            Text('संस्थान: $institute'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
          ],
        ),
      ),
    );
  }
}
