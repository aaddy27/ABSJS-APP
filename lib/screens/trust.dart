import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Trust extends StatefulWidget {
  const Trust({super.key});

  @override
  State<Trust> createState() => _TrustState();
}

class _TrustState extends State<Trust> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  List<dynamic> trustList = [];
  bool loading = false;
  int? editId;

  // Controllers
  final nameController = TextEditingController();
  final yearController = TextEditingController();
  final purposeController = TextEditingController();
  final positionController = TextEditingController();
  final contactController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchTrustList();
  }

  Future<int> getComputedMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    int rawId = int.tryParse(prefs.getString('member_id') ?? '0') ?? 0;
    return rawId - 100000;
  }

  Future<void> fetchTrustList() async {
    setState(() => loading = true);
    final memberId = await getComputedMemberId();
    final url = 'https://mrmapi.sadhumargi.in/api/trust/$memberId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() => trustList = result);
    } else {
      setState(() => trustList = []);
    }
    setState(() => loading = false);
  }

Future<void> submitForm() async {
  if (nameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ट्रस्ट का नाम आवश्यक है')));
    return;
  }

  final memberId = await getComputedMemberId();

  final body = {
    "trust_name": nameController.text,
    "trust_year": yearController.text.isEmpty ? null : int.tryParse(yearController.text),
    "trust_purpose": purposeController.text.isEmpty ? null : purposeController.text,
    "trust_role": positionController.text.isEmpty ? null : positionController.text,
    "trust_contact_name": contactController.text.isEmpty ? null : contactController.text,
    "trust_contact_number": mobileController.text.isEmpty ? null : mobileController.text,
    "trust_email": emailController.text.isEmpty ? null : emailController.text,
    "trust_website": websiteController.text.isEmpty ? null : websiteController.text,
    "member_id": memberId,
  };

  final url = editId != null
      ? 'https://mrmapi.sadhumargi.in/api/trust/$editId'
      : 'https://mrmapi.sadhumargi.in/api/trust';

  final response = await (editId != null
      ? http.put(Uri.parse(url), body: json.encode(body), headers: {'Content-Type': 'application/json'})
      : http.post(Uri.parse(url), body: json.encode(body), headers: {'Content-Type': 'application/json'}));

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Success')));
    clearForm();
    fetchTrustList();
    _tabController.index = 1;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed')));
  }
}


  Future<void> deleteTrust(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('क्या आप वाकई इस ट्रस्ट को हटाना चाहते हैं?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    final url = 'https://mrmapi.sadhumargi.in/api/trust/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      fetchTrustList();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete failed')));
    }
  }

  void loadForEdit(Map<String, dynamic> trust) {
    setState(() {
      editId = trust['id'];
      nameController.text = trust['trust_name'] ?? '';
      yearController.text = trust['trust_year']?.toString() ?? '';
      purposeController.text = trust['trust_purpose'] ?? '';
      positionController.text = trust['trust_role'] ?? '';
      contactController.text = trust['trust_contact_name'] ?? '';
      mobileController.text = trust['trust_contact_number'] ?? '';
      emailController.text = trust['trust_email'] ?? '';
      websiteController.text = trust['trust_website'] ?? '';
      _tabController.index = 0;
    });
  }

  void clearForm() {
    nameController.clear();
    yearController.clear();
    purposeController.clear();
    positionController.clear();
    contactController.clear();
    mobileController.clear();
    emailController.clear();
    websiteController.clear();
    editId = null;
  }

  Widget buildTextField({
  required String label,
  required IconData icon,
  required TextEditingController controller,
  bool isRequired = false,
  bool isEmail = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) return 'Required';
        if (isEmail && value!.isNotEmpty && !value.contains('@')) return 'Valid Email चाहिए';
        return null;
      },
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('परिवार द्वारा संचालित चैरिटेबल ट्रस्ट/संस्थान', style: TextStyle(fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_box), text: 'ट्रस्ट जोड़ें'),
            Tab(icon: Icon(Icons.list_alt), text: 'ट्रस्ट सूची'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Add/Edit Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  buildTextField(label: 'ट्रस्ट का नाम *', icon: Icons.account_balance, controller: nameController, isRequired: true),
buildTextField(label: 'वर्ष', icon: Icons.calendar_today, controller: yearController),
buildTextField(label: 'उद्देश्य', icon: Icons.lightbulb_outline, controller: purposeController),
buildTextField(label: 'पद', icon: Icons.badge, controller: positionController),
buildTextField(label: 'संपर्क सूत्र', icon: Icons.person, controller: contactController),
buildTextField(label: 'मोबाइल', icon: Icons.phone_android, controller: mobileController),
buildTextField(label: 'ईमेल', icon: Icons.email, controller: emailController, isEmail: true),
buildTextField(label: 'वेबसाइट', icon: Icons.language, controller: websiteController),

                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: submitForm,
                    icon: Icon(editId != null ? Icons.save : Icons.add),
                    label: Text(editId != null ? 'अपडेट करें' : 'प्रोफाइल में जोड़ें'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Trust List View
          loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trustList.length,
                  itemBuilder: (context, index) {
                    final trust = trustList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text('${trust['trust_name']} (${trust['trust_year'] ?? ''})'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('उद्देश्य: ${trust['trust_purpose'] ?? ''}'),
                            Text('पद: ${trust['trust_role'] ?? ''}'),
                            Text('संपर्क: ${trust['trust_contact_name'] ?? ''}'),
                            Text('मोबाइल: ${trust['trust_contact_number'] ?? ''}'),
                            Text('ईमेल: ${trust['trust_email'] ?? ''}'),
                          ],
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => loadForEdit(trust),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteTrust(trust['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
