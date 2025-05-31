import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> fields = ['Politics', 'Profession'];
  final List<String> levels = ['International', 'Local'];
  final List<String> types = ['Felicitation', 'Award'];

  String? selectedField, selectedLevel, selectedType, selectedYear;
  final TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: 0,
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📝 उल्लेखनीय उपलब्धियाँ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.add), text: 'Add Achievement'),
                Tab(icon: Icon(Icons.list_alt), text: 'View Achievements'),
              ],
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.deepPurple,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildFormTab(),
                buildListTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          buildDropdown("क्षेत्र *", fields, selectedField,
              (value) => setState(() => selectedField = value), Icons.public),
          buildDropdown("स्तर *", levels, selectedLevel,
              (value) => setState(() => selectedLevel = value), Icons.star),
          buildDropdown("प्रकार *", types, selectedType,
              (value) => setState(() => selectedType = value), Icons.label),
          buildTextField("वर्ष", (value) => selectedYear = value,
              icon: Icons.calendar_today),
          buildTextField("विवरण *", null,
              controller: detailsController, icon: Icons.description),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Achievement added (dummy)!')),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text("प्रोफाइल में जोड़ें"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListTab() {
    final dummyData = [
      {
        "field": "Politics",
        "level": "International",
        "type": "Felicitation",
        "details": "MLA",
        "year": "2022"
      },
      {
        "field": "Profession",
        "level": "Local",
        "type": "Award",
        "details": "Good Work kiya tha",
        "year": "2005"
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        final item = dummyData[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      "क्रमांक: ${index + 1}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                infoRow(Icons.public, "क्षेत्र", item["field"]),
                infoRow(Icons.star, "स्तर", item["level"]),
                infoRow(Icons.label, "प्रकार", item["type"]),
                infoRow(Icons.description, "विवरण", item["details"]),
                infoRow(Icons.calendar_month, "वर्ष", item["year"]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {},
                      tooltip: "Edit",
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {},
                      tooltip: "Delete",
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget infoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value ?? "")),
        ],
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, String? selected,
      Function(String?) onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        value: selected,
        items:
            items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildTextField(String label, Function(String)? onChanged,
      {TextEditingController? controller, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
