import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // <-- for Clipboard

// Import your BaseScaffold
import 'base_scaffold.dart';

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

  // Cache keys
  static const _kCachePrimary = 'cache_primaryAddress';
  static const _kCacheSaved = 'cache_savedAddresses';
  static const _kCacheCountries = 'cache_countries';
  static const _kCacheStatesPrefix = 'cache_states_'; // + isoCode

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCachedThenRefresh();
  }

  /// Load cached values first (if any), then call network refresh in background.
  Future<void> _loadCachedThenRefresh() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load memberId first (still needed to fetch API)
      final rawMemberId = prefs.getString('member_id');
      if (rawMemberId != null && int.tryParse(rawMemberId) != null) {
        final actualId = int.parse(rawMemberId) - 100000;
        memberId = actualId.toString();
      }

      // Load cached primary
      final primaryJson = prefs.getString(_kCachePrimary);
      if (primaryJson != null) {
        try {
          final decoded = jsonDecode(primaryJson);
          setState(() => primaryAddress = decoded);
        } catch (_) {}
      }

      // Load cached saved addresses
      final savedJson = prefs.getString(_kCacheSaved);
      if (savedJson != null) {
        try {
          final decoded = jsonDecode(savedJson);
          if (decoded is List) setState(() => savedAddresses = decoded);
        } catch (_) {}
      }

      // Load cached countries
      final countriesJson = prefs.getString(_kCacheCountries);
      if (countriesJson != null) {
        try {
          final decoded = jsonDecode(countriesJson);
          if (decoded is List) setState(() => countries = List<String>.from(decoded));
        } catch (_) {}
      }

      // Now trigger background refreshes (do not block UI)
      _refreshAllFromNetwork();
    } catch (e) {
      // On any cache read error, still try to refresh network
      _refreshAllFromNetwork();
    } finally {
      // Keep loading indicator only until first background refresh completes
      setState(() {});
    }
  }

  Future<void> _refreshAllFromNetwork() async {
    setState(() => _isLoading = true);
    try {
      if (memberId == null) {
        final prefs = await SharedPreferences.getInstance();
        final rawMemberId = prefs.getString('member_id');
        if (rawMemberId != null && int.tryParse(rawMemberId) != null) {
          final actualId = int.parse(rawMemberId) - 100000;
          memberId = actualId.toString();
        }
      }

      final futures = <Future>[];
      futures.add(loadCountries());
      if (memberId != null) {
        futures.add(loadPrimaryAddress());
        futures.add(loadSavedAddresses());
      }
      await Future.wait(futures);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Helper to extract ISO code from "Name|ISO"
  String _countryIso(String countryValue) {
    final parts = countryValue.split('|');
    return parts.length > 1 ? parts[1] : '';
  }

  // --- API and Data Functions (modified to save cache) ---

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

  Future<void> loadPrimaryAddress() async {
    if (memberId == null) return;
    final url = 'https://mrmapi.sadhumargi.in/api/primary-address/$memberId';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        setState(() => primaryAddress = decoded);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(_kCachePrimary, jsonEncode(decoded));
      }
    } catch (e) {
      // keep cached value
    }
  }

  Future<void> loadSavedAddresses() async {
    if (memberId == null) return;
    final url = 'https://mrmapi.sadhumargi.in/api/addresses/$memberId';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          setState(() => savedAddresses = decoded);
          final prefs = await SharedPreferences.getInstance();
          prefs.setString(_kCacheSaved, jsonEncode(decoded));
        }
      }
    } catch (e) {
      // keep cached savedAddresses
    }
  }

  Future<void> loadCountries() async {
    final url = Uri.parse('https://api.countrystatecity.in/v1/countries');
    try {
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
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(_kCacheCountries, jsonEncode(names));
      }
    } catch (e) {
      // keep cached countries if present
    }
  }

  Future<void> loadStates(String selectedCountryValue) async {
    final parts = selectedCountryValue.split('|');
    final isoCode = parts.length > 1 ? parts[1] : '';
    if (isoCode.isEmpty) return;

    final url = Uri.parse('https://api.countrystatecity.in/v1/countries/$isoCode/states');
    try {
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
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('$_kCacheStatesPrefix$isoCode', jsonEncode(stateNames));
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_kCacheStatesPrefix$isoCode');
      if (cached != null) {
        try {
          final decoded = jsonDecode(cached);
          if (decoded is List) setState(() => states = List<String>.from(decoded));
        } catch (_) {}
      }
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
    // Use BaseScaffold here, index 5 (Profile) so bottom nav highlights Profile
    return BaseScaffold(
      selectedIndex: 5,
      body: Column(
        children: [
          // TabBar only, no refresh button
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue.shade800,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.blue.shade800,
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

  // Tab 1: Primary Address View (UI/UX improved, Call button removed)
  Widget buildPrimaryAddressView() {
    // If no primary address, show friendly CTA to add one
    if (primaryAddress == null || (primaryAddress!.isEmpty)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off, size: 88, color: Colors.grey.shade400),
              const SizedBox(height: 18),
              const Text(
                "No Primary Address",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                "You don't have a primary address yet. Add one so it's quick to access for calls or directions.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text("Add Address"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color(0xFF0D47A1),
                ),
                onPressed: () {
                  // switch to Add/Update tab
                  _tabController.animateTo(1);
                },
              ),
            ],
          ),
        ),
      );
    }

    // Build the improved card
    final addr = primaryAddress!;
    final addressLines = [
      addr['address1'] ?? '',
      addr['address2'] ?? '',
      if ((addr['landmark'] ?? '').toString().isNotEmpty) 'Landmark: ${addr['landmark']}',
      '${addr['city'] ?? ''}, ${addr['district'] ?? ''} - ${addr['pincode'] ?? ''}',
      '${addr['state'] ?? ''}, ${addr['country'] ?? ''}',
    ].where((s) => s.trim().isNotEmpty).join('\n');

    final contact = addr['contact_number']?.toString() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF0D47A1)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 12, offset: const Offset(0, 8))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: Title + Address Type badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.home, color: Colors.white, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Primary Address",
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              addr['address_type']?.toString() ?? '',
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // small badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 6),
                            Text("Primary", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Address text (tappable to copy)
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: addressLines));
                      showToast("Copied address to clipboard");
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            addressLines,
                            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Contact chip & small meta row
                  Row(
                    children: [
                      if (contact.isNotEmpty)
                        ActionChip(
                          avatar: const Icon(Icons.phone, size: 18, color: Colors.white),
                          label: Text(contact, style: const TextStyle(color: Colors.white)),
                          onPressed: () {
                            // open edit tab with details filled
                            for (final k in controllers.keys) {
                              controllers[k]?.text = addr[k]?.toString() ?? '';
                            }
                            setState(() {
                              selectedCountry = countries.firstWhere(
                                (c) => c.split('|').first == (addr['country'] ?? ''),
                                orElse: () => '',
                              );
                              editId = addr['id'];
                              selectedAddressType = addr['address_type'] ?? 'Factory';
                            });
                            _tabController.animateTo(1);
                          },
                          backgroundColor: Colors.white24,
                        ),
                      const Spacer(),
                      // Small hint
                      Text(
                        "Tap address to copy",
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action buttons row (Call removed)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text("Edit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade800,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          // pre-fill controllers and go to edit tab
                          for (final k in controllers.keys) {
                            controllers[k]?.text = addr[k]?.toString() ?? '';
                          }

                          final countryString = countries.firstWhere(
                            (c) => c.split('|').first == (addr['country'] ?? ''),
                            orElse: () => '',
                          );

                          setState(() {
                            selectedCountry = countryString;
                            editId = addr['id'];
                            selectedAddressType = addr['address_type'] ?? 'Factory';
                          });

                          if (countryString.isNotEmpty) {
                            final iso = _countryIso(countryString);
                            _tryLoadCachedStates(iso).then((_) => loadStates(countryString)).then((_) {
                              setState(() {
                                selectedState = states.firstWhere(
                                  (s) => s.split('|').last == (addr['state']?.toString() ?? ''),
                                  orElse: () => '',
                                );
                              });
                            });
                          }
                          _tabController.animateTo(1);
                        },
                      ),

                      const SizedBox(width: 8),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text("Copy"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: addressLines));
                          showToast("Copied address to clipboard");
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Small helper card suggesting "Saved Addresses" quick access
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.black54),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Want to change which address is primary? Go to Saved tab and tap the star on an address to mark it primary.",
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(2),
                  child: const Text("Open Saved"),
                ),
              ],
            ),
          ),
        ],
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
                final iso = _countryIso(v);
                _tryLoadCachedStates(iso);
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

  // Try to load cached states for an iso code (fast)
  Future<void> _tryLoadCachedStates(String isoCode) async {
    if (isoCode.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_kCacheStatesPrefix$isoCode');
    if (cached != null) {
      try {
        final decoded = jsonDecode(cached);
        if (decoded is List) {
          setState(() => states = List<String>.from(decoded));
        }
      } catch (_) {}
    }
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
                    "${a['address1'] ?? ''}, ${a['address2'] ?? ''}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${a['city'] ?? ''}, ${a['state'] ?? ''} - ${a['pincode'] ?? ''}"),
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
                              for (final k in controllers.keys) {
                                controllers[k]?.text = a[k]?.toString() ?? '';
                              }

                              final countryString = countries.firstWhere(
                                (c) => c.split('|').first == (a['country'] ?? ''),
                                orElse: () => '',
                              );

                              setState(() {
                                selectedCountry = countryString;
                                editId = a['id'];
                                selectedAddressType = a['address_type'] ?? 'Factory';
                              });

                              if (countryString.isNotEmpty) {
                                final iso = _countryIso(countryString);
                                await _tryLoadCachedStates(iso);
                                await loadStates(countryString);
                                setState(() {
                                  selectedState = states.firstWhere(
                                    (s) => s.split('|').last == (a['state']?.toString() ?? ''),
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
