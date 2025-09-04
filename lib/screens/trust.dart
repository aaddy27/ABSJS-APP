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

  // State Variables
  List<dynamic> trustList = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
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

  // --- DATA & API LOGIC ---
  Future<int> getComputedMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    int rawId = int.tryParse(prefs.getString('member_id') ?? '0') ?? 0;
    return rawId > 100000 ? rawId - 100000 : rawId;
  }

  Future<void> fetchTrustList() async {
    setState(() => _isLoading = true);
    try {
      final memberId = await getComputedMemberId();
      final url = 'https://mrmapi.sadhumargi.in/api/trust/$memberId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() => trustList = result);
      } else {
        _showSnackBar('Failed to load trust list: ${response.statusCode}', isError: true);
        setState(() => trustList = []);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    try {
      final memberId = await getComputedMemberId();
      final body = {
        "trust_name": nameController.text, "trust_year": yearController.text,
        "trust_purpose": purposeController.text, "trust_role": positionController.text,
        "trust_contact_name": contactController.text, "trust_contact_number": mobileController.text,
        "trust_email": emailController.text, "trust_website": websiteController.text,
        "member_id": memberId,
      };

      final url = editId != null
          ? 'https://mrmapi.sadhumargi.in/api/trust/$editId'
          : 'https://mrmapi.sadhumargi.in/api/trust';
      final response = await (editId != null
          ? http.put(Uri.parse(url), body: json.encode(body), headers: {'Content-Type': 'application/json'})
          : http.post(Uri.parse(url), body: json.encode(body), headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(editId != null ? 'ट्रस्ट सफलतापूर्वक अपडेट हुआ!' : 'ट्रस्ट सफलतापूर्वक जोड़ा गया!');
        clearForm();
        await fetchTrustList();
        _tabController.animateTo(1);
      } else {
        _showSnackBar('Failed to save: ${response.body}', isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
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
    
    setState(() => _isLoading = true);
    try {
      final url = 'https://mrmapi.sadhumargi.in/api/trust/$id';
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        _showSnackBar('ट्रस्ट सफलतापूर्वक हटाया गया');
        await fetchTrustList();
      } else {
        _showSnackBar('Delete failed: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', isError: true);
    } finally {
       setState(() => _isLoading = false);
    }
  }
  
  // --- UI LOGIC & HELPERS ---
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
      _tabController.animateTo(0);
    });
  }

  void clearForm() {
    _formKey.currentState?.reset();
    nameController.clear();
    yearController.clear();
    purposeController.clear();
    positionController.clear();
    contactController.clear();
    mobileController.clear();
    emailController.clear();
    websiteController.clear();
    setState(() => editId = null);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }
  
  // --- BUILD METHOD & WIDGETS ---
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D47A1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('चैरिटेबल ट्रस्ट/संस्थान', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amberAccent,
          tabs: const [
            Tab(icon: Icon(Icons.add_box), text: 'ट्रस्ट जोड़ें'),
            Tab(icon: Icon(Icons.list_alt), text: 'ट्रस्ट सूची'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormTab(primaryColor),
          _buildTrustListTab(),
        ],
      ),
    );
  }

  Widget _buildFormTab(Color primaryColor) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildTextField(label: 'ट्रस्ट का नाम *', icon: Icons.account_balance, controller: nameController, isRequired: true),
          buildTextField(label: 'स्थापना वर्ष', icon: Icons.calendar_today, controller: yearController, keyboardType: TextInputType.number),
          buildTextField(label: 'उद्देश्य', icon: Icons.lightbulb_outline, controller: purposeController),
          buildTextField(label: 'पद', icon: Icons.badge_outlined, controller: positionController),
          buildTextField(label: 'संपर्क सूत्र', icon: Icons.person_outline, controller: contactController),
          buildTextField(label: 'मोबाइल', icon: Icons.phone_android_outlined, controller: mobileController, keyboardType: TextInputType.phone),
          buildTextField(label: 'ईमेल', icon: Icons.email_outlined, controller: emailController, keyboardType: TextInputType.emailAddress, isEmail: true),
          buildTextField(label: 'वेबसाइट', icon: Icons.language_outlined, controller: websiteController),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : submitForm,
            icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : Icon(editId != null ? Icons.save_as_outlined : Icons.add_task_outlined),
            label: Text(editId != null ? 'अपडेट करें' : 'प्रोफाइल में जोड़ें'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustListTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (trustList.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: trustList.length,
      itemBuilder: (context, index) {
        final trust = trustList[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(backgroundColor: Colors.blue.shade100, child: const Icon(Icons.account_balance, color: Color(0xFF0D47A1))),
                title: Text(trust['trust_name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text('स्थापना वर्ष: ${trust['trust_year'] ?? 'N/A'}'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.lightbulb_outline, 'उद्देश्य', trust['trust_purpose']),
                    _buildInfoRow(Icons.badge_outlined, 'पद', trust['trust_role']),
                    _buildInfoRow(Icons.person_outline, 'संपर्क सूत्र', trust['trust_contact_name']),
                    _buildInfoRow(Icons.phone_android_outlined, 'मोबाइल', trust['trust_contact_number']),
                    _buildInfoRow(Icons.email_outlined, 'ईमेल', trust['trust_email']),
                  ],
                ),
              ),
              Container(
                 decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(icon: const Icon(Icons.edit, color: Colors.blueAccent), label: const Text('Edit'), onPressed: () => loadForEdit(trust)),
                    TextButton.icon(icon: const Icon(Icons.delete, color: Colors.redAccent), label: const Text('Delete'), onPressed: () => deleteTrust(trust['id'])),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
  
  // --- HELPER WIDGETS ---
  Widget buildTextField({required String label, required IconData icon, required TextEditingController controller, bool isRequired = false, bool isEmail = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) return 'यह फ़ील्ड आवश्यक है';
          if (isEmail && value!.isNotEmpty && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'कृपया एक वैध ईमेल दर्ज करें';
          return null;
        },
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true, fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    final displayValue = (value == null || value.toString().isEmpty) ? 'Not Provided' : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(displayValue)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No Trusts Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Add a new trust to see it here.', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}