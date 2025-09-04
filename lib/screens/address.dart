import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? primaryAddress;
  List<dynamic> savedAddresses = [];
  List<String> countries = [];
  List<String> states = [];

  bool _isLoading = true; // For showing a loading indicator

  final formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    'address1': TextEditingController(),
    'address2': TextEditingController(),
    'post': TextEditingController(),
    'city': TextEditingController(),
    'district': TextEditingController(),
    'pincode': TextEditingController(),
    'landmark': TextEditingController(),
    'contact_number': TextEditingController(),
  };

  String selectedCountry = '';
  String selectedState = '';
  String selectedAddressType = 'Factory';
  int? editId;
  String? memberId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadMemberIdAndData();
    loadCountries();
  }

  // --- API and Data Functions (No major changes here, just loading state management) ---

  Future<void> markAsPrimary(String addressId) async {
    final url = Uri.parse("https://mrmapi.sadhumargi.in/api/mark-primary/$addressId");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      showToast("❌ Token not found", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        showToast("✅ ${data['message']}");
        await loadSavedAddresses();
        await loadPrimaryAddress();
      } else {
        showToast("❌ ${data['message'] ?? 'Server Error'}", isError: true);
      }
    } catch (e) {
      showToast("❌ Network error: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> loadMemberIdAndData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawMemberId = prefs.getString('member_id');
      if (rawMemberId != null && int.tryParse(rawMemberId) != null) {
        final actualId = int.parse(rawMemberId) - 100000;
        memberId = actualId.toString();
        await loadPrimaryAddress();
        await loadSavedAddresses();
      }
    } catch (e) {
      showToast("Failed to load user data: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> loadPrimaryAddress() async {
    if (memberId == null) return;
    final url = 'https://mrmapi.sadhumargi.in/api/primary-address/$memberId';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      setState(() => primaryAddress = jsonDecode(res.body));
    }
  }

  Future<void> loadSavedAddresses() async {
    if (memberId == null) return;
    final url = 'https://mrmapi.sadhumargi.in/api/addresses/$memberId';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      setState(() => savedAddresses = jsonDecode(res.body));
    }
  }

  Future<void> loadCountries() async {
    final url = Uri.parse('https://api.countrystatecity.in/v1/countries');
    final response = await http.get(
      url,
      headers: {
        'X-CSCAPI-KEY': 'S2dBYnJldWtmRFM4U2VUdG9Fd0hiRXp2RjhpTm81YlhVVThiWEdiTA==',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final names = data.map<String>((c) => "${c['name']}|${c['iso2']}").toList();
      names.sort();
      setState(() => countries = names);
    }
  }

  Future<void> loadStates(String selectedCountryValue) async {
    final parts = selectedCountryValue.split('|');
    final isoCode = parts.length > 1 ? parts[1] : '';
    if (isoCode.isEmpty) return;

    final url = Uri.parse('https://api.countrystatecity.in/v1/countries/$isoCode/states');
    final response = await http.get(
      url,
      headers: {
        'X-CSCAPI-KEY': 'S2dBYnJldWtmRFM4U2VUdG9Fd0hiRXp2RjhpTm81YlhVVThiWEdiTA==',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final stateNames = data.map<String>((s) => "${s['name']}|${s['id']}").toList();
      setState(() => states = stateNames);
    }
  }
  
  Future<void> saveOrUpdateAddress() async {
    if (!formKey.currentState!.validate() || memberId == null) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final isUpdate = editId != null;
    final url = Uri.parse(
      isUpdate
          ? 'https://mrmapi.sadhumargi.in/api/update-address/$editId'
          : 'https://mrmapi.sadhumargi.in/api/save-address',
    );

    final data = {
      "member_id": memberId,
      "address1": controllers['address1']!.text,
      "address2": controllers['address2']!.text,
      "post": controllers['post']!.text,
      "city": controllers['city']!.text,
      "district": controllers['district']!.text,
      "pincode": controllers['pincode']!.text,
      "landmark": controllers['landmark']!.text,
      "contact_number": controllers['contact_number']!.text,
      "country": selectedCountry.split('|').first,
      "state": int.tryParse(selectedState.split('|').last) ?? 0,
      "address_type": selectedAddressType,
      "is_primary": 0,
      "is_enabled": 1,
    };

    try {
      final res = await (isUpdate
          ? http.put(
              url,
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
              body: jsonEncode(data),
            )
          : http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
              body: jsonEncode(data),
            ));

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        showToast(body['message'] ?? (isUpdate ? '✅ Address updated.' : '✅ Address saved.'));
        resetForm();
        await loadSavedAddresses();
        await loadPrimaryAddress();
        _tabController.animateTo(2);
      } else {
        showToast("❌ Error: ${body['message'] ?? 'Unknown error'}", isError: true);
      }
    } catch (e) {
      showToast("❌ Network error: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> deleteAddress(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this address?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    
    setState(() => _isLoading = true);
    final url = 'https://mrmapi.sadhumargi.in/api/delete-address/$id';
    try {
      final res = await http.delete(Uri.parse(url));
      if (res.statusCode == 200) {
        showToast('✅ Deleted successfully');
        await loadSavedAddresses();
        await loadPrimaryAddress();
      } else {
        showToast('❌ Failed to delete', isError: true);
      }
    } catch (e) {
      showToast("❌ Network error: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void resetForm() {
    formKey.currentState?.reset();
    controllers.forEach((_, c) => c.clear());
    setState(() {
      selectedCountry = '';
      selectedState = '';
      states = [];
      selectedAddressType = 'Factory';
      editId = null;
    });
  }
  
  void showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  // --- UI Build Methods ---
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D47A1); // A professional deep blue

    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Management'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Column(
        children: [
          Container(
            color: primaryColor.withOpacity(0.1),
            child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: primaryColor,
              indicatorWeight: 3.0,
              tabs: const [
                Tab(icon: Icon(Icons.star), text: 'Primary'),
                Tab(icon: Icon(Icons.add_location_alt), text: 'Add/Update'),
                Tab(icon: Icon(Icons.list_alt), text: 'Saved'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      buildPrimaryAddressView(),
                      buildAddressForm(),
                      buildSavedAddressList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // Tab 1: Primary Address View
  Widget buildPrimaryAddressView() {
    if (primaryAddress == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              "No Primary Address Set",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              "You can set one from your saved addresses.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.home, color: Colors.white, size: 30),
                  SizedBox(width: 12),
                  Text(
                    "Primary Address",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              const Divider(color: Colors.white54, height: 30),
              Text(
                "${primaryAddress!['address1']}, ${primaryAddress!['address2']}",
                style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                "${primaryAddress!['city']}, ${primaryAddress!['district']} - ${primaryAddress!['pincode']}",
                style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                "${primaryAddress!['state']}, ${primaryAddress!['country']}",
                style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab 2: Add/Update Form View
  Widget buildAddressForm() {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTextField(
              controller: controllers['address1']!,
              label: 'Address Line 1 *',
              icon: Icons.home_work_outlined),
          _buildTextField(
              controller: controllers['address2']!,
              label: 'Address Line 2',
              icon: Icons.add_road_outlined,
              isRequired: false),
          _buildTextField(
              controller: controllers['post']!,
              label: 'Post Office *',
              icon: Icons.local_post_office_outlined),
          _buildTextField(
              controller: controllers['city']!,
              label: 'City *',
              icon: Icons.location_city_outlined),
          _buildTextField(
              controller: controllers['district']!,
              label: 'District *',
              icon: Icons.map_outlined),
          _buildTextField(
              controller: controllers['pincode']!,
              label: 'Pincode *',
              icon: Icons.pin_outlined,
              keyboardType: TextInputType.number),
          
          const SizedBox(height: 12),
          // Country Dropdown
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: countries.contains(selectedCountry) ? selectedCountry : null,
            items: countries.map((c) {
              final parts = c.split('|');
              return DropdownMenuItem(value: c, child: Text(parts[0], overflow: TextOverflow.ellipsis));
            }).toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                selectedCountry = v;
                selectedState = '';
                states = [];
                loadStates(v);
              });
            },
            decoration: _inputDecoration('Country *', Icons.public_outlined),
            validator: (v) => v == null || v.isEmpty ? 'Please select a country' : null,
          ),
          const SizedBox(height: 12),
          // State Dropdown
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: states.contains(selectedState) ? selectedState : null,
            items: states.map((s) {
              final parts = s.split('|');
              return DropdownMenuItem(value: s, child: Text(parts[0], overflow: TextOverflow.ellipsis));
            }).toList(),
            onChanged: (v) => setState(() => selectedState = v!),
            decoration: _inputDecoration('State *', Icons.landscape_outlined),
             validator: (v) => v == null || v.isEmpty ? 'Please select a state' : null,
          ),
          const SizedBox(height: 12),
          // Address Type Dropdown
          DropdownButtonFormField<String>(
            value: selectedAddressType,
            items: ['Factory', 'Residential', 'Office/Business', 'Other']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => selectedAddressType = v!),
            decoration: _inputDecoration('Address Type', Icons.category_outlined),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(editId == null ? Icons.save_alt : Icons.edit),
            label: Text(editId == null ? "Save Address" : "Update Address"),
            onPressed: saveOrUpdateAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
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

  // Tab 3: Saved Address List
  Widget buildSavedAddressList() {
    if (savedAddresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_location_alt_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              "No Saved Addresses",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
             const SizedBox(height: 8),
            const Text(
              "Addresses you add will appear here.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: savedAddresses.length,
      itemBuilder: (_, i) {
        final a = savedAddresses[i];
        final bool isPrimary = a['is_primary'] == 1;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isPrimary ? Colors.amber.shade700 : Colors.grey.shade300,
              width: isPrimary ? 1.5 : 1,
            ),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  title: Text(
                    "${a['address1']}, ${a['address2']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${a['city']}, ${a['state']} - ${a['pincode']}"),
                  leading: Icon(
                    Icons.location_on,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isPrimary)
                        const Chip(
                          avatar: Icon(Icons.star, color: Colors.white, size: 16),
                          label: Text('Primary'),
                          backgroundColor: Colors.amber,
                          labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        )
                      else
                        const SizedBox(), // To maintain space
                      
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                            tooltip: 'Edit',
                            onPressed: () async {
                              // Pre-fill controllers
                              for (final k in controllers.keys) {
                                controllers[k]?.text = a[k]?.toString() ?? '';
                              }

                              // Pre-select country
                              final countryString = countries.firstWhere(
                                (c) => c.split('|').first == a['country'],
                                orElse: () => '',
                              );
                              
                              setState(() {
                                selectedCountry = countryString;
                                editId = a['id'];
                                selectedAddressType = a['address_type'] ?? 'Factory';
                              });

                              // Load states for the country and then select the state
                              if (countryString.isNotEmpty) {
                                await loadStates(countryString);
                                setState(() {
                                  selectedState = states.firstWhere(
                                    (s) => s.split('|').last == a['state'].toString(),
                                    orElse: () => '',
                                  );
                                });
                              }
                              _tabController.animateTo(1);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            tooltip: 'Delete',
                            onPressed: () => deleteAddress(a['id']),
                          ),
                          if (!isPrimary)
                            IconButton(
                              icon: const Icon(Icons.star_border, color: Colors.orangeAccent),
                              tooltip: 'Mark as Primary',
                              onPressed: () => markAsPrimary(a['id'].toString()),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Helper Widgets for Cleaner Code ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label, icon),
        validator: (v) => isRequired && (v == null || v.isEmpty) ? 'This field is required' : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }
}