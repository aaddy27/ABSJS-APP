import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:confetti/confetti.dart';

import 'base_scaffold.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;

  final TextEditingController detailsController = TextEditingController();
  String? selectedField, selectedLevel, selectedType, selectedYear;
  int? editingId;

  List<Map<String, dynamic>> achievements = [];

  final Map<String, String> fieldMap = {
    'Politics': 'राजनीति',
    'Profession': 'पेशेवर',
    'Business': 'व्यवसाय',
    'Education': 'शिक्षा',
    'Social': 'समाज',
    'Sports': 'खेल',
    'Other': 'अन्य',
  };

  final Map<String, String> levelMap = {
    'Local': 'स्थानीय',
    'Regional': 'क्षेत्रीय',
    'National': 'राष्ट्रीय',
    'International': 'अंतरराष्ट्रीय',
    'Other': 'अन्य',
  };

  final Map<String, String> typeMap = {
    'Post': 'पद',
    'Award': 'पुरस्कार',
    'Felicitation': 'सम्मान',
    'Other': 'अन्य',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        _confettiController.play();
      }
    });

    fetchAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  Future<void> fetchAchievements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? memberIdStr = prefs.getString('member_id');

    if (memberIdStr != null) {
      int adjustedId = int.parse(memberIdStr) - 100000;
      String url = 'https://mrmapi.sadhumargi.in/api/achievement/$adjustedId';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          setState(() {
            achievements = List<Map<String, dynamic>>.from(data);
          });
        }
      } catch (e) {
        debugPrint("Exception: $e");
      }
    }
  }

  Future<void> submitAchievement() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? memberIdStr = prefs.getString('member_id');

    if (memberIdStr == null || selectedField == null || selectedLevel == null || selectedType == null || detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया सभी आवश्यक फ़ील्ड भरें')),
      );
      return;
    }

    int adjustedId = int.parse(memberIdStr) - 100000;

    final data = {
      'member_id': adjustedId,
      'achievement_sector': selectedField,
      'achievement_level': selectedLevel,
      'achievement_type': selectedType,
      'achievement_year': selectedYear ?? '',
      'achievement_detail': detailsController.text.trim(),
    };

    final url = editingId == null
        ? 'https://mrmapi.sadhumargi.in/api/achievement'
        : 'https://mrmapi.sadhumargi.in/api/achievement/$editingId';

    final response = await (editingId == null
        ? http.post(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data))
        : http.put(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: jsonEncode(data)));

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(editingId == null ? '✅ उपलब्धि जोड़ी गई' : '✅ उपलब्धि अपडेट की गई'),
        backgroundColor: Colors.green,
      ));
      clearForm();
      await fetchAchievements();
      _tabController.animateTo(1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('❌ प्रक्रिया विफल रही'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> deleteAchievement(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('पुष्टि करें'),
        content: const Text('क्या आप इस उपलब्धि को हटाना चाहते हैं?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('नहीं')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('हाँ')),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await http.delete(Uri.parse('https://mrmapi.sadhumargi.in/api/achievement/$id'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('🗑️ उपलब्धि हटाई गई'),
          backgroundColor: Colors.orange,
        ));
        await fetchAchievements();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('हटाने में त्रुटि'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void editAchievement(Map<String, dynamic> data) {
    setState(() {
      editingId = data['id'];
      selectedField = data['achievement_sector'];
      selectedLevel = data['achievement_level'];
      selectedType = data['achievement_type'];
      selectedYear = data['achievement_year']?.toString();
      detailsController.text = data['achievement_detail'] ?? '';
      _tabController.animateTo(0);
    });
  }

  void clearForm() {
    setState(() {
      selectedField = null;
      selectedLevel = null;
      selectedType = null;
      selectedYear = null;
      detailsController.clear();
      editingId = null;
    });
  }

  Widget buildDropdown(String label, Icon icon, Map<String, String> map, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: map.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget buildTextField(String label, Icon icon, {TextEditingController? controller, Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // important
            children: [
              buildDropdown('क्षेत्र *', const Icon(Icons.category), fieldMap, selectedField, (value) => setState(() => selectedField = value)),
              const SizedBox(height: 12),
              buildDropdown('स्तर *', const Icon(Icons.stairs), levelMap, selectedLevel, (value) => setState(() => selectedLevel = value)),
              const SizedBox(height: 12),
              buildDropdown('प्रकार *', const Icon(Icons.emoji_events), typeMap, selectedType, (value) => setState(() => selectedType = value)),
              const SizedBox(height: 12),
              buildTextField('वर्ष', const Icon(Icons.calendar_today), onChanged: (value) => selectedYear = value),
              const SizedBox(height: 12),
              buildTextField('विवरण *', const Icon(Icons.description), controller: detailsController),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(editingId == null ? Icons.add : Icons.save),
                label: Text(editingId == null ? 'प्रोफ़ाइल में जोड़ें' : 'अपडेट करें'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: submitAchievement,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListTab() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: achievements.isEmpty
          ? const Center(child: Text('😐 कोई उपलब्धि नहीं मिली।'))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final data = achievements[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      fieldMap[data['achievement_sector']] ?? data['achievement_sector'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📍 स्तर: ${levelMap[data['achievement_level']] ?? data['achievement_level']}'),
                        Text('🏆 प्रकार: ${typeMap[data['achievement_type']] ?? data['achievement_type']}'),
                        Text('📅 वर्ष: ${data['achievement_year'] ?? ''}'),
                        Text('📝 विवरण: ${data['achievement_detail'] ?? ''}'),
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editAchievement(data),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteAchievement(data['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use BaseScaffold so global appbar & nav stay consistent
    return BaseScaffold(
      selectedIndex: -1, // no bottom nav highlight here; change if needed
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // local header with TabBar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          Text('📝 उपलब्धियाँ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo.shade700)),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.indigo.shade700,
                        labelColor: Colors.indigo.shade700,
                        unselectedLabelColor: Colors.grey.shade600,
                        tabs: const [
                          Tab(icon: Icon(Icons.add), text: 'जोड़ें'),
                          Tab(icon: Icon(Icons.list), text: 'सूची'),
                        ],
                      ),
                    ],
                  ),
                ),

                // content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(child: buildFormTab()),
                      buildListTab(),
                    ],
                  ),
                ),
              ],
            ),

            // Confetti overlay (top center)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 30,
                emissionFrequency: 0.05,
                maxBlastForce: 20,
                minBlastForce: 10,
                gravity: 0.4,
                colors: const [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple,
                ],
                shouldLoop: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
