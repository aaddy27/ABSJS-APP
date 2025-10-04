import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Use your existing BaseScaffold (adjust path if needed)
import 'base_scaffold.dart';

class EmploymentScreen extends StatefulWidget {
  const EmploymentScreen({super.key});

  @override
  State<EmploymentScreen> createState() => _EmploymentScreenState();
}

class _EmploymentScreenState extends State<EmploymentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- State Variables ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController startYearController = TextEditingController();
  final TextEditingController endYearController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String? selectedOccupation;
  String? selectedIndustry;
  String? selectedBusinessType;

  List<Map<String, dynamic>> employmentData = [];
  bool _isLoading = true;
  int? editingId;

  DateTime? _lastUpdated;

  // --- Data Maps & Lists ---
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchBusinessData();
  }

  // --- API Functions ---
  Future<void> fetchBusinessData() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? memberIdStr = prefs.getString('member_id');
      if (memberIdStr == null) {
        _showSnackBar('Member ID not found!', isError: true);
        setState(() => _isLoading = false);
        return;
      }
      int memberId = int.parse(memberIdStr);
      int adjustedId = memberId - 100000;
      String apiUrl = 'https://mrmapi.sadhumargi.in/api/business/$adjustedId';

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          employmentData = List<Map<String, dynamic>>.from(data);
          _lastUpdated = DateTime.now();
        });
      } else {
        _showSnackBar('API Error: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> addOrUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? memberIdStr = prefs.getString('member_id');
      if (memberIdStr == null) {
        _showSnackBar('Member ID not found!', isError: true);
        setState(() => _isLoading = false);
        return;
      }
      int adjustedId = int.parse(memberIdStr) - 100000;

      final Map<String, dynamic> data = {
        'member_id': adjustedId,
        'business_type': selectedOccupation,
        'business_name': nameController.text,
        'business_role': roleController.text,
        'business_start_year': startYearController.text,
        'business_end_year': endYearController.text,
        'business_location': locationController.text,
        'industry_category': selectedIndustry ?? '',
        'business_category': selectedBusinessType ?? '',
      };

      final String url = editingId != null
          ? 'https://mrmapi.sadhumargi.in/api/business/$editingId'
          : 'https://mrmapi.sadhumargi.in/api/business';

      final response = await (editingId != null
          ? http.put(Uri.parse(url), body: jsonEncode(data), headers: {'Content-Type': 'application/json'})
          : http.post(Uri.parse(url), body: jsonEncode(data), headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(editingId != null ? 'प्रोफ़ाइल सफलतापूर्वक अपडेट हुई!' : 'प्रोफ़ाइल सफलतापूर्वक जोड़ी गई!');
        clearForm();
        await fetchBusinessData();
        _tabController.animateTo(1);
      } else {
        _showSnackBar('Error: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> deleteProfile(int id) async {
    setState(() => _isLoading = true);
    try {
      String deleteUrl = 'https://mrmapi.sadhumargi.in/api/business/$id';
      final response = await http.delete(Uri.parse(deleteUrl));
      if (response.statusCode == 200) {
        _showSnackBar('प्रोफ़ाइल सफलतापूर्वक हटाई गई');
        await fetchBusinessData();
      } else {
        _showSnackBar('Failed to delete: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- Helper & UI Logic Functions ---
  void clearForm() {
    _formKey.currentState?.reset();
    nameController.clear();
    roleController.clear();
    startYearController.clear();
    endYearController.clear();
    locationController.clear();
    setState(() {
      selectedOccupation = null;
      selectedIndustry = null;
      selectedBusinessType = null;
      editingId = null;
    });
  }

  void editProfile(Map<String, dynamic> data) {
    setState(() {
      editingId = data['id'];
      selectedOccupation = data['business_type'];
      nameController.text = data['business_name'] ?? '';
      roleController.text = data['business_role'] ?? '';
      startYearController.text = data['business_start_year']?.toString() ?? '';
      endYearController.text = data['business_end_year']?.toString() ?? '';
      locationController.text = data['business_location'] ?? '';
      selectedIndustry = industryCategories.contains(data['industry_category']) ? data['industry_category'] : null;
      selectedBusinessType = businessTypes.contains(data['business_category']) ? data['business_category'] : null;
      _tabController.animateTo(0);
    });
  }

  void confirmAndDeleteProfile(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('क्या आप वाकई इस प्रोफ़ाइल को हटाना चाहते हैं?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('नहीं')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('हाँ, हटाएं', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      deleteProfile(id);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D47A1);

    // Use BaseScaffold so AppBar + bottom nav remain consistent
    return BaseScaffold(
      selectedIndex: -1, // Profile tab (adjust if employment belongs to another tab)
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header card with tabs & last-updated stamp
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: Colors.white,
                    child: Column(
                      children: [
                        if (_lastUpdated != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Last updated: ${_formatDate(_lastUpdated!)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TabBar(
                          controller: _tabController,
                          labelColor: primaryColor,
                          unselectedLabelColor: Colors.grey.shade600,
                          indicatorColor: primaryColor,
                          indicatorWeight: 3.0,
                          tabs: const [
                            Tab(icon: Icon(Icons.add_circle_outline), text: 'Add / Update'),
                            Tab(icon: Icon(Icons.view_list_outlined), text: 'Saved'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Padding(padding: const EdgeInsets.all(12.0), child: _buildFormTab()),
                        Padding(padding: const EdgeInsets.all(12.0), child: _buildListTab()),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // --- UI Builder Widgets ---
  Widget _buildFormTab() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildDropdownField(
              value: selectedOccupation,
              label: 'पेशा (Occupation) *',
              icon: Icons.work_outline,
              items: occupationsMap.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (value) => setState(() => selectedOccupation = value),
              validator: (value) => value == null || value.isEmpty ? 'कृपया एक पेशा चुनें' : null,
            ),
            _buildTextField(controller: nameController, label: 'नाम (Name) *', icon: Icons.business_center_outlined, validator: (v) => v!.isEmpty ? 'नाम आवश्यक है' : null),
            _buildTextField(controller: roleController, label: 'भूमिका (Role)', icon: Icons.person_pin_outlined, isRequired: false),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: startYearController, label: 'आरंभ वर्ष', icon: Icons.calendar_today_outlined, keyboardType: TextInputType.number, isRequired: false)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(controller: endYearController, label: 'समाप्ति वर्ष', icon: Icons.calendar_month_outlined, keyboardType: TextInputType.number, isRequired: false)),
              ],
            ),
            _buildTextField(controller: locationController, label: 'स्थान (Location)', icon: Icons.location_on_outlined, isRequired: false),
            _buildDropdownField(
              value: selectedIndustry,
              label: 'औद्योगिक श्रेणी (Industry)',
              icon: Icons.factory_outlined,
              items: industryCategories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => selectedIndustry = value),
            ),
            _buildDropdownField(
              value: selectedBusinessType,
              label: 'व्यापार वर्ग (Business Type)',
              icon: Icons.store_mall_directory_outlined,
              items: businessTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => selectedBusinessType = value),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(editingId == null ? Icons.add_task : Icons.save_as),
                    label: Text(editingId == null ? 'प्रोफ़ाइल जोड़ें' : 'प्रोफ़ाइल अपडेट करें'),
                    onPressed: addOrUpdateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (editingId != null) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: clearForm,
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTab() {
    if (employmentData.isEmpty) {
      return _buildEmptyState();
    }
    return RefreshIndicator(
      onRefresh: fetchBusinessData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: employmentData.length,
        itemBuilder: (context, index) {
          final data = employmentData[index];
          final tenure = (data['business_start_year'] != null && data['business_end_year'] != null && data['business_start_year'].toString().isNotEmpty)
              ? '${data['business_start_year']} - ${data['business_end_year']}'
              : (data['business_start_year'] != null ? '${data['business_start_year']} - Present' : 'N/A');

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.work, color: const Color(0xFF0D47A1)),
                  ),
                  title: Text(
                    occupationsMap[data['business_type']] ?? (data['business_type'] ?? 'N/A'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(data['business_name'] ?? 'N/A', style: TextStyle(color: Colors.grey.shade700)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.person_pin_outlined, 'Role', data['business_role']),
                      _buildInfoRow(Icons.timeline_outlined, 'Tenure', tenure),
                      _buildInfoRow(Icons.location_on_outlined, 'Location', data['business_location']),
                      _buildInfoRow(Icons.factory_outlined, 'Industry', data['industry_category']),
                      _buildInfoRow(Icons.store_mall_directory_outlined, 'Business Type', data['business_category']),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        label: const Text('Edit'),
                        onPressed: () => editProfile(data),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        label: const Text('Delete'),
                        onPressed: () => confirmAndDeleteProfile(data['id']),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Helper Widgets for UI ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = true,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        validator: isRequired ? (validator ?? (v) => (v == null || v.isEmpty) ? 'यह फ़ील्ड आवश्यक है' : null) : validator,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    void Function(T?)? onChanged,
    String? Function(T?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    final displayValue = (value == null || value.toString().isEmpty) ? 'Not Provided' : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
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
          Icon(Icons.work_off_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No Employment Profiles Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          const SizedBox(height: 8),
          const Text('Add a new profile to get started.', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Profile'),
            onPressed: () => _tabController.animateTo(0),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameController.dispose();
    roleController.dispose();
    startYearController.dispose();
    endYearController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
