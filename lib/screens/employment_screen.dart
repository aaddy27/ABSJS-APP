import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmploymentScreen extends StatefulWidget {
  const EmploymentScreen({super.key});

  @override
  State<EmploymentScreen> createState() => _EmploymentScreenState();
}

class _EmploymentScreenState extends State<EmploymentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController startYearController = TextEditingController();
  final TextEditingController endYearController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String selectedOccupation = '';
  String selectedIndustry = '';
  String selectedBusinessType = '';

  final Map<String, String> occupationsMap = {
    'Student': 'विद्यार्थी',
    'Govt. Job': 'सरकारी नौकरी',
    'Private Job': 'प्राइवेट नौकरी',
    'Teacher': 'शिक्षक',
    'Business': 'व्यापार',
    'Industry': 'उद्योग',
    'Profession': 'प्रोफेशन',
    'Housewife': 'गृहिणी',
    'Retired': 'रिटायर्ड',
    'Other': 'अन्य',
  };

  final List<String> industryCategories = [
    'S.I. -Below 5 cr. (Turnover)',
    'M.I.-5-30Cr (Turnover)',
    'L.I.-Above 30 cr (Turnover)',
  ];

  final List<String> businessTypes = [
    'S.I. -Below 5 cr. (Turnover)',
    'M.I.-5-30Cr (Turnover)',
    'L.I.-Above 30 cr (Turnover)',
  ];

  List<Map<String, dynamic>> employmentData = [];
  bool isEditing = false;
  int? editingIndex;
  int? editingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchBusinessData();
  }

  Future<void> fetchBusinessData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? memberIdStr = prefs.getString('member_id');

    if (memberIdStr != null) {
      int memberId = int.parse(memberIdStr);
      int adjustedId = memberId - 100000;
      String apiUrl = 'https://mrmapi.sadhumargi.in/api/business/$adjustedId';

      try {
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          setState(() {
            employmentData = List<Map<String, dynamic>>.from(data);
          });
        } else {
          print('❌ API Error: ${response.statusCode}');
        }
      } catch (e) {
        print('❗ Exception: $e');
      }
    }
  }

  void clearForm() {
    nameController.clear();
    roleController.clear();
    startYearController.clear();
    endYearController.clear();
    locationController.clear();
    selectedOccupation = '';
    selectedIndustry = '';
    selectedBusinessType = '';
    isEditing = false;
    editingIndex = null;
    editingId = null;
  }

  String normalizeDropdownValue(String value, List<String> options) {
    return options.firstWhere(
      (option) => option.trim().toLowerCase() == value.trim().toLowerCase(),
      orElse: () => '',
    );
  }

  void addOrUpdateProfile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? memberIdStr = prefs.getString('member_id');

  if (memberIdStr == null || selectedOccupation.isEmpty || nameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('कृपया सभी आवश्यक फ़ील्ड भरें')),
    );
    return;
  }

  int memberId = int.parse(memberIdStr);
  int adjustedId = memberId - 100000;

  final Map<String, dynamic> data = {
    'member_id': adjustedId,
    'business_type': selectedOccupation,
    'business_name': nameController.text,
    'business_role': roleController.text,
    'business_start_year': startYearController.text,
    'business_end_year': endYearController.text,
    'business_location': locationController.text,
    'industry_category': selectedIndustry,
    'business_category': selectedBusinessType,
  };

  final String url = editingId != null
      ? 'https://mrmapi.sadhumargi.in/api/business/$editingId'
      : 'https://mrmapi.sadhumargi.in/api/business';

  final response = await (editingId != null
      ? http.put(Uri.parse(url), body: jsonEncode(data), headers: {'Content-Type': 'application/json'})
      : http.post(Uri.parse(url), body: jsonEncode(data), headers: {'Content-Type': 'application/json'}));

  if (response.statusCode == 200 || response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(editingId != null ? 'पेशा अपडेट हुआ!' : 'पेशा जोड़ा गया!'),
    ));
    clearForm();
    fetchBusinessData(); // Reload the list
    _tabController.animateTo(1); // Switch to list tab
  } else {
    print('❌ Error: ${response.statusCode} - ${response.body}');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('पेशा सहेजने में त्रुटि!'),
    ));
  }
}


  void editProfile(int index) {
  final data = employmentData[index];
  setState(() {
    selectedOccupation = data['business_type'] ?? '';
    nameController.text = data['business_name'] ?? '';
    roleController.text = data['business_role'] ?? '';
    startYearController.text = data['business_start_year'].toString();
    endYearController.text = data['business_end_year'].toString();
    locationController.text = data['business_location'] ?? '';

    // Safely normalize dropdown values
    selectedIndustry = normalizeDropdownValue(data['industry_category'] ?? '', industryCategories);
    selectedBusinessType = normalizeDropdownValue(data['business_category'] ?? '', businessTypes);

    isEditing = true;
    editingIndex = index;
    editingId = data['id'];
    _tabController.animateTo(0);
  });
}


  Future<void> deleteProfile(int id) async {
    String deleteUrl = 'https://mrmapi.sadhumargi.in/api/business/$id';

    try {
      final response = await http.delete(Uri.parse(deleteUrl));
      if (response.statusCode == 200) {
        setState(() {
          employmentData.removeWhere((element) => element['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('डेटा सफलतापूर्वक हटाया गया')),
        );
      } else {
        print('❌ Delete failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❗ Delete Exception: $e');
    }
  }

  void confirmAndDeleteProfile(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('पुष्टि करें'),
        content: const Text('क्या आप वाकई इस प्रोफ़ाइल को हटाना चाहते हैं?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('नहीं'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('हाँ, हटाएं'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      deleteProfile(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('व्यवसाय प्रोफ़ाइल'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'प्रोफ़ाइल जोड़ें'),
            Tab(text: 'सूची'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedOccupation.isEmpty ? null : selectedOccupation,
                  items: occupationsMap.entries.map((entry) {
                    return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedOccupation = value!),
                  decoration: const InputDecoration(labelText: '🛠 पेशा *'),
                ),
                const SizedBox(height: 10),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: '👤 नाम')),
                const SizedBox(height: 10),
                TextField(controller: roleController, decoration: const InputDecoration(labelText: '📌 भूमिका')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: startYearController, decoration: const InputDecoration(labelText: '🔰 आरंभ वर्ष'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: endYearController, decoration: const InputDecoration(labelText: '🏁 समाप्ति वर्ष'))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: '📍 स्थान')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
  value: industryCategories.contains(selectedIndustry) ? selectedIndustry : null,
  items: industryCategories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
  onChanged: (value) => setState(() => selectedIndustry = value!),
  decoration: const InputDecoration(labelText: '🏭 औद्योगिक श्रेणी'),
),

                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
  value: businessTypes.contains(selectedBusinessType) ? selectedBusinessType : null,
  items: businessTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
  onChanged: (value) => setState(() => selectedBusinessType = value!),
  decoration: const InputDecoration(labelText: '🏢 व्यापार वर्ग'),
),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: addOrUpdateProfile,
                  child: Text(isEditing ? 'अपडेट करें' : 'प्रोफ़ाइल जोड़ें'),
                ),
              ],
            ),
          ),

          // Tab 2: List
          Padding(
            padding: const EdgeInsets.all(12),
            child: employmentData.isEmpty
                ? const Center(child: Text('कोई डेटा उपलब्ध नहीं है'))
                : ListView.builder(
                    itemCount: employmentData.length,
                    itemBuilder: (context, index) {
                      final data = employmentData[index];
                      return Card(
                        child: ListTile(
                          title: Text(occupationsMap[data['business_type']] ?? data['business_type'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('नाम: ${data['business_name']}'),
                              Text('भूमिका: ${data['business_role']}'),
                              Text('कार्यकाल: ${data['business_start_year']} से ${data['business_end_year']}'),
                              Text('स्थान: ${data['business_location']}'),
                              Text('औद्योगिक श्रेणी: ${data['industry_category']}'),
                              Text('व्यापार वर्ग: ${data['business_category']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit), onPressed: () => editProfile(index)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => confirmAndDeleteProfile(data['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
