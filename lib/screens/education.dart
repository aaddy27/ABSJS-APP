import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'base_scaffold.dart';

class Education extends StatefulWidget {
  const Education({super.key});

  @override
  State<Education> createState() => _EducationState();
}

class _EducationState extends State<Education> with SingleTickerProviderStateMixin {
  List<dynamic> educationList = [];
  bool isLoading = true;
  String? error;
  TabController? _tabController;

  // Form fields
  final _descriptionController = TextEditingController();
  final _scoreController = TextEditingController();
  final _instituteController = TextEditingController();
  final _yearController = TextEditingController();
  String? selectedEducation;
  int? editingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchEducationData();
  }

  Future<int?> getComputedMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    final rawId = prefs.get('member_id');
    final memberId = int.tryParse(rawId.toString());
    return memberId != null ? memberId - 100000 : null;
  }

  Future<void> fetchEducationData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final computedId = await getComputedMemberId();
      if (computedId == null) {
        setState(() {
          error = "❌ Member ID not found.";
          isLoading = false;
        });
        return;
      }

      final url = 'https://mrmapi.sadhumargi.in/api/educations/$computedId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          educationList = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = '⚠️ API Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = '🔴 Network Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _saveEducation() async {
    final computedId = await getComputedMemberId();
    if (computedId == null || selectedEducation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ कृपया सभी फ़ील्ड भरें')),
      );
      return;
    }

    final isEdit = editingId != null;
    final url = isEdit
        ? Uri.parse('https://mrmapi.sadhumargi.in/api/update-education/$editingId')
        : Uri.parse('https://mrmapi.sadhumargi.in/api/save-education');

    final Map<String, dynamic> body = {
      'member_id': computedId.toString(),
      'education_name': selectedEducation,
      'education_description': _descriptionController.text,
      'education_score': _scoreController.text,
      'education_institute': _instituteController.text,
      'education_year': _yearController.text,
    };

    try {
      final response = await (isEdit
    ? http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // ✅ Add this line
        },
        body: json.encode(body),
      )
    : http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // ✅ Add here also for safety
        },
        body: json.encode(body),
      ));


      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? '✏️ संशोधन सफल' : '✅ शिक्षा सफलतापूर्वक जोड़ी गई')),
        );
        _resetForm();
        fetchEducationData();
        _tabController?.animateTo(1); // switch to list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🔴 नेटवर्क त्रुटि: $e')),
      );
    }
  }

  void _resetForm() {
    _descriptionController.clear();
    _scoreController.clear();
    _instituteController.clear();
    _yearController.clear();
    setState(() {
      selectedEducation = null;
      editingId = null;
    });
  }

  Future<void> _deleteEducation(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("पुष्टि करें"),
        content: const Text("क्या आप वाकई इस शिक्षा को हटाना चाहते हैं?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("नहीं")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("हाँ")),
        ],
      ),
    );

    if (confirmed != true) return;

    final url = Uri.parse('https://mrmapi.sadhumargi.in/api/delete-education/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ शिक्षा हटाई गई')),
        );
        fetchEducationData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Deletion Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🔴 नेटवर्क त्रुटि: $e')),
      );
    }
  }

  void _startEdit(Map edu) {
    setState(() {
      editingId = edu['id'];
      selectedEducation = edu['education_name'];
      _descriptionController.text = edu['education_description'] ?? '';
      _scoreController.text = edu['education_score'].toString();
      _instituteController.text = edu['education_institute'] ?? '';
      _yearController.text = edu['education_year'].toString();
    });
    _tabController?.animateTo(0);
  }

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
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.green,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black54,
                tabs: const [
                  Tab(text: '📝 शिक्षा फ़ॉर्म'),
                  Tab(text: '📚 शिक्षा सूची'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
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

  Widget _buildEducationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 5,
        color: Colors.green.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: '🎓 शिक्षा *'),
                value: _dropdownItems.any((e) => e.value == selectedEducation) ? selectedEducation : null,
                items: _dropdownItems,
                onChanged: (value) => setState(() => selectedEducation = value),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '🗒️ विवरण'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _scoreController,
                decoration: const InputDecoration(labelText: '🔢 अंक'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _instituteController,
                decoration: const InputDecoration(labelText: '🏫 संस्थान'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: '📅 वर्ष'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveEducation,
                icon: const Icon(Icons.save),
                label: Text(editingId == null ? "प्रोफाइल में जोड़ें" : "अपडेट करें"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEducationList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
    }
    if (educationList.isEmpty) {
      return const Center(child: Text("📭 कोई शिक्षा डेटा उपलब्ध नहीं है।"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: educationList.length,
      itemBuilder: (context, index) {
        final edu = educationList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('क्रमांक: ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('🎓 शिक्षा: ${edu['education_name']}'),
                Text('🗒️ विवरण: ${edu['education_description']}'),
                Text('🔢 अंक: ${edu['education_score']}'),
                Text('🏫 संस्थान: ${edu['education_institute']}'),
                Text('📅 वर्ष: ${edu['education_year']}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _startEdit(edu),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEducation(edu['id']),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  final List<DropdownMenuItem<String>> _dropdownItems = [
    const DropdownMenuItem(enabled: false, child: Text('🧒 Pre School', style: TextStyle(fontWeight: FontWeight.bold))),
    const DropdownMenuItem(value: 'Play School', child: Text('Play School')),
    const DropdownMenuItem(enabled: false, child: Text('📘 Primary', style: TextStyle(fontWeight: FontWeight.bold))),
    DropdownMenuItem(value: 'Nursery', child: Text('Nursery')),
    DropdownMenuItem(value: 'KG (LKG/UKG)', child: Text('KG (LKG/UKG)')),
    DropdownMenuItem(value: '1st', child: Text('1st')),
    DropdownMenuItem(value: '2nd', child: Text('2nd')),
    DropdownMenuItem(value: '3rd', child: Text('3rd')),
    DropdownMenuItem(value: '4th', child: Text('4th')),
    DropdownMenuItem(value: '5th', child: Text('5th')),
    const DropdownMenuItem(enabled: false, child: Text('📗 Middle / Pre SSC', style: TextStyle(fontWeight: FontWeight.bold))),
    DropdownMenuItem(value: '6th', child: Text('6th')),
    DropdownMenuItem(value: '7th', child: Text('7th')),
    DropdownMenuItem(value: '8th', child: Text('8th')),
    DropdownMenuItem(value: '9th', child: Text('9th')),
    const DropdownMenuItem(enabled: false, child: Text('🎓 SSC / HSC', style: TextStyle(fontWeight: FontWeight.bold))),
    DropdownMenuItem(value: 'SSC', child: Text('SSC')),
    DropdownMenuItem(value: 'HSC', child: Text('HSC')),
    const DropdownMenuItem(enabled: false, child: Text('🎓 Graduation', style: TextStyle(fontWeight: FontWeight.bold))),
    DropdownMenuItem(value: 'BBA', child: Text('BBA')),
    DropdownMenuItem(value: 'BPHARMA', child: Text('BPHARMA')),
    DropdownMenuItem(value: 'B.Arc', child: Text('B.Arc')),
    DropdownMenuItem(value: 'BSW', child: Text('BSW')),
    DropdownMenuItem(value: 'BCA', child: Text('BCA')),
    DropdownMenuItem(value: 'BTECH', child: Text('BTECH')),
    DropdownMenuItem(value: 'BSC', child: Text('BSC')),
    DropdownMenuItem(value: 'BCOM', child: Text('BCOM')),
    DropdownMenuItem(value: 'BA', child: Text('BA')),
    DropdownMenuItem(value: 'BEd', child: Text('BEd')),
    DropdownMenuItem(value: 'BAMS', child: Text('BAMS')),
    DropdownMenuItem(value: 'BDS', child: Text('BDS')),
    DropdownMenuItem(value: 'BE', child: Text('BE')),
    DropdownMenuItem(value: 'LLB', child: Text('LLB')),
    const DropdownMenuItem(enabled: false, child: Text('🎓 Post Graduation', style: TextStyle(fontWeight: FontWeight.bold))),
    DropdownMenuItem(value: 'MPHARMA', child: Text('MPHARMA')),
    DropdownMenuItem(value: 'MSW', child: Text('MSW')),
    DropdownMenuItem(value: 'MCA', child: Text('MCA')),
    DropdownMenuItem(value: 'MTECH', child: Text('MTECH')),
    DropdownMenuItem(value: 'MSC', child: Text('MSC')),
    DropdownMenuItem(value: 'MCOM', child: Text('MCOM')),
    DropdownMenuItem(value: 'MCM', child: Text('MCM')),
    DropdownMenuItem(value: 'MA', child: Text('MA')),
    DropdownMenuItem(value: 'MBBS', child: Text('MBBS')),
    DropdownMenuItem(value: 'MBA', child: Text('MBA')),
    const DropdownMenuItem(enabled: false, child: Text('🎓 Post PG', style: TextStyle(fontWeight: FontWeight.bold))),
    DropdownMenuItem(value: 'LLM', child: Text('LLM')),
    DropdownMenuItem(value: 'PHD', child: Text('PHD')),
    DropdownMenuItem(value: 'MPHIL', child: Text('MPHIL')),
    const DropdownMenuItem(enabled: false, child: Text('💼 Professional Studies', style: TextStyle(fontWeight: FontWeight.bold))),
    DropdownMenuItem(value: 'ITI', child: Text('ITI')),
    DropdownMenuItem(value: 'CA', child: Text('CA')),
    DropdownMenuItem(value: 'CS', child: Text('CS')),
    DropdownMenuItem(value: 'ICWA', child: Text('ICWA')),
    DropdownMenuItem(value: 'DIPLOMA', child: Text('DIPLOMA')),
    const DropdownMenuItem(enabled: false, child: Text('🧩 Others', style: TextStyle(fontWeight: FontWeight.bold))),
    DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
  ];
}
