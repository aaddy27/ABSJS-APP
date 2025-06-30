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

  final formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    'address1': TextEditingController(),
    'address2': TextEditingController(),
    'post': TextEditingController(),
    'city': TextEditingController(),
    'district': TextEditingController(),
    'pincode': TextEditingController(),
  };

  String selectedCountry = '';
  String selectedState = '';
  String selectedOriginState = '';
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

  Future<void> loadMemberIdAndData() async {
  final prefs = await SharedPreferences.getInstance(); // ✅ this line is REQUIRED
  final rawMemberId = prefs.getString('member_id');
  print("SharedPreferences से मिला member_id: $rawMemberId");

  if (rawMemberId != null && int.tryParse(rawMemberId) != null) {
    final actualId = int.parse(rawMemberId) - 100000;
    memberId = actualId.toString(); // Save the adjusted ID to use in API calls
    print("API में भेजा जा रहा adjusted member_id: $memberId");

    setState(() {}); // Refresh UI
    loadPrimaryAddress();
    loadSavedAddresses();
  }
}


  Future<void> loadPrimaryAddress() async {
    final url = 'https://mrmapi.sadhumargi.in/api/primary-address/$memberId';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      setState(() => primaryAddress = jsonDecode(res.body));
    }
  }

  Future<void> loadSavedAddresses() async {
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
      final stateNames = data.map<String>((s) => s['name'].toString()).toList();
      setState(() => states = stateNames);
    }
  }

  Future<void> saveOrUpdateAddress() async {
    if (!formKey.currentState!.validate() || memberId == null) return;

    final payload = {
      "member_id": memberId,
      "address1": controllers['address1']!.text,
      "address2": controllers['address2']!.text,
      "post": controllers['post']!.text,
      "city": controllers['city']!.text,
      "district": controllers['district']!.text,
      "pincode": controllers['pincode']!.text,
      "country": selectedCountry.split('|').first,
      "state": selectedState,
      "address_type": selectedAddressType,
      "is_primary": 0,
      "is_enabled": 1,
    };

    final isUpdate = editId != null;
    final url = Uri.parse(isUpdate
        ? 'https://mrmapi.sadhumargi.in/api/update-address/$editId'
        : 'https://mrmapi.sadhumargi.in/api/save-address');

    try {
      final res = await (isUpdate
          ? http.put(url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload))
          : http.post(url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload)));

      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isUpdate ? 'Address updated successfully!' : 'Address saved successfully!')));
        resetForm();
        loadSavedAddresses();
        loadPrimaryAddress();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${res.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  void resetForm() {
    controllers.forEach((_, c) => c.clear());
    selectedCountry = '';
    selectedState = '';
    selectedOriginState = '';
    selectedAddressType = 'Factory';
    editId = null;
    setState(() {});
  }

  Future<void> deleteAddress(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this address?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
        ],
      ),
    );
    if (confirmed != true) return;

    final url = 'https://mrmapi.sadhumargi.in/api/delete-address/$id';
    final res = await http.delete(Uri.parse(url));
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted successfully')));
      loadSavedAddresses();
      loadPrimaryAddress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('पता प्रबंधन')),
      body: Column(
        children: [
          // if (memberId != null)
          //   Container(
          //     width: double.infinity,
          //     color: Colors.grey.shade300,
          //     padding: const EdgeInsets.all(8),
          //     child: Text(
          //       'Logged-in Member ID: $memberId',
          //       style: const TextStyle(fontWeight: FontWeight.bold),
          //     ),
          //   ),
          Container(
            color: Colors.blue[100],
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Primary Address'),
                Tab(text: 'Add / Update Address'),
                Tab(text: 'Saved Addresses'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
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
// primary address tab 
Widget buildPrimaryAddressView() {
  if (primaryAddress == null) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade100,
      child: const Center(
        child: Text(
          "📭 कोई प्राथमिक पता उपलब्ध नहीं है।",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  return Container(
    width: double.infinity,
    height: double.infinity,
    color: Colors.green.shade50,
    child: Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 300, // 👈 This keeps it portrait-style
          minHeight: 300,
        ),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "🏡 प्राथमिक पता",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "📍 ${primaryAddress!['address1']}, ${primaryAddress!['address2']}\n"
                  "🏤 ${primaryAddress!['post']}, ${primaryAddress!['city']}, ${primaryAddress!['district']} - ${primaryAddress!['pincode']}\n"
                  "🌐 ${primaryAddress!['state']}, ${primaryAddress!['country']}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}


// form for add and edit tab 

  Widget buildAddressForm() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: formKey,
      child: ListView(
        children: [
          const Text("📋 पता फॉर्म", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          ...[
            ['address1', '🏠 पता 1 *'],
            ['address2', '🏠 पता 2'],
            ['post', '🏤 पोस्ट *'],
            ['city', '🏙️ शहर *'],
            ['district', '🗺️ जिला *'],
            ['pincode', '🔢 पिन कोड *'],
          ].map((field) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextFormField(
              controller: controllers[field[0]]!,
              decoration: InputDecoration(
                labelText: field[1],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                fillColor: Colors.blue.shade50,
                filled: true,
              ),
              validator: (v) => field[1].contains('*') && (v == null || v.isEmpty) ? 'Required' : null,
            ),
          )),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedCountry.isNotEmpty ? selectedCountry : null,
            items: countries.map((c) {
              final parts = c.split('|');
              return DropdownMenuItem(value: c, child: Text("🌍 ${parts[0]}"));
            }).toList(),
            onChanged: (v) {
              setState(() {
                selectedCountry = v!;
                loadStates(v);
              });
            },
            decoration: const InputDecoration(labelText: '🌐 देश'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedState.isNotEmpty ? selectedState : null,
            items: states.map((s) => DropdownMenuItem(value: s, child: Text("🏞️ $s"))).toList(),
            onChanged: (v) => setState(() => selectedState = v!),
            decoration: const InputDecoration(labelText: '🗺️ राज्य'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedAddressType,
            items: ['Factory', 'Residential', 'Office/Business', 'Other'].map(
              (s) => DropdownMenuItem(value: s, child: Text("🏷️ $s")),
            ).toList(),
            onChanged: (v) => setState(() => selectedAddressType = v!),
            decoration: const InputDecoration(labelText: '🏢 पता प्रकार'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(editId == null ? "✅ पता सेव करें" : "✏️ पता अपडेट करें"),
            onPressed: saveOrUpdateAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    ),
  );
}

//tab 3 saved address 
  Widget buildSavedAddressList() {
  if (savedAddresses.isEmpty) {
    return const Center(child: Text("📭 कोई पता उपलब्ध नहीं है।", style: TextStyle(fontSize: 18)));
  }

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: savedAddresses.length,
    itemBuilder: (_, i) {
      final a = savedAddresses[i];
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: ListTile(
          title: Text("📍 ${a['address1']}, ${a['address2']}"),
          subtitle: Text("🏙️ ${a['city']}, ${a['district']} - ${a['pincode']}"),
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("🏠 पता विवरण", style: TextStyle(color: Colors.deepPurple)),
              content: Text(
                "${a['address1']}, ${a['address2']},\n📮 ${a['post']}, ${a['city']}, ${a['district']} - ${a['pincode']},\n🌐 ${a['state']}, ${a['country']}",
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("❌ बंद करें"),
                ),
              ],
            ),
          ),
          trailing: Wrap(
            spacing: 8,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  for (final k in controllers.keys) {
                    controllers[k]?.text = a[k]?.toString() ?? '';
                  }
                  setState(() {
                    selectedCountry = a['country'] ?? '';
                    selectedState = a['state'] ?? '';
                    selectedOriginState = a['origin_state'] ?? '';
                    selectedAddressType = a['address_type'] ?? 'Factory';
                    editId = a['id'];
                  });
                  _tabController.animateTo(1);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteAddress(a['id']),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}
