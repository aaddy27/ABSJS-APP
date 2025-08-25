// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'base_scaffold.dart';


//------------------------------------FAMILY MEMBERS--------------------------------------

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  List<dynamic> familyMembers = [];
  bool isLoading = true;
  bool isHead = false;

  String? memberId;
  String? familyId;

  @override
  void initState() {
    super.initState();
    loadFamilyInfo();
  }

  Future<void> loadFamilyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    memberId = prefs.getString('member_id');
    familyId = prefs.getString('family_id');
    isHead = prefs.getBool('is_head_of_family') ?? false;

    if (familyId != null && memberId != null) {
      await fetchFamilyMembers();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchFamilyMembers() async {
    final url = Uri.parse("https://mrmapi.sadhumargi.in/api/family-members/$familyId");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'member_id': memberId!,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        List<dynamic> allMembers = [];
        if (jsonResponse['head'] != null) {
          allMembers.add(jsonResponse['head']);
        }
        if (jsonResponse['members'] != null) {
          allMembers.addAll(jsonResponse['members']);
        }

        setState(() {
          familyMembers = allMembers;
          isLoading = false;
        });
      } else {
        debugPrint("API Error: ${response.statusCode} - ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Exception: $e");
      setState(() => isLoading = false);
    }
  }

  Widget buildMemberCard(member, index) {
    final bool isFamilyHead = member['is_head_of_family'] == 1;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isFamilyHead ? Colors.green.shade50 : Colors.orange.shade50,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: isFamilyHead ? Colors.green : Colors.orange,
          child: Icon(
            isFamilyHead ? Icons.verified_user : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          "${member['salution'] ?? ''} ${member['first_name'] ?? ''} ${member['last_name'] ?? ''}".trim(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isFamilyHead ? Colors.green.shade800 : Colors.orange.shade800,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("M_ID: ${member['member_id'] ?? 'N/A'}"),
            Text("जन्मतिथि: ${member['birth_day'] ?? 'N/A'}"),
            Text("मोबाइल: ${member['mobile'] ?? 'N/A'}"),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isFamilyHead ? Colors.green : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isFamilyHead ? '👑 मुखिया' : 'सदस्य',
            style: TextStyle(
              color: isFamilyHead ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      itemCount: familyMembers.length,
      itemBuilder: (context, index) {
        final member = familyMembers[index];
        return buildMemberCard(member, index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Tab> tabs = [
      const Tab(text: '👨‍👩‍👧‍👦 परिवार'),
    ];

    List<Widget> tabViews = [
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : familyMembers.isEmpty
              ? const Center(child: Text("📭 कोई सदस्य नहीं मिला।", style: TextStyle(fontSize: 18)))
              : buildListView(),
    ];

    if (isHead && memberId != null) {
      tabs.addAll(const [
        Tab(text: '📋 सामान्य जानकारी'),
        Tab(text: '➕  परिवारांजलि'),
        Tab(text: '✅ वीर परिवार'),
        Tab(text: '⬇️ डाउनलोड'),
      ]);

      tabViews.addAll([
        MemberInfoForm(memberId: memberId!),
        ParivaranjaliScreen(memberId: memberId!),
        VirPariwarScreen(familyId: familyId!),
        const Center(child: Text("⬇️ डाउनलोड स्क्रीन")),
      ]);
    }

    return BaseScaffold(
      selectedIndex: -1,
      body: DefaultTabController(
        length: tabs.length,
        child: Column(
          children: [
            Material(
              color: Colors.blue.shade50,
              child: TabBar(
                isScrollable: true,
                labelColor: Colors.blue.shade900,
                indicatorColor: Colors.blue,
                tabs: tabs,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: tabViews,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//------------------------------------FAMILY MEMBERS--------------------------------------

class VirPariwarScreen extends StatefulWidget {
  final String familyId;
  const VirPariwarScreen({super.key, required this.familyId});

  @override
  State<VirPariwarScreen> createState() => _VirPariwarScreenState();
}

class _VirPariwarScreenState extends State<VirPariwarScreen> {
  List<dynamic> dikshaMembers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDikshaMembers();
  }

  Future<void> fetchDikshaMembers() async {
    final url = Uri.parse("https://mrmapi.sadhumargi.in/api/family-diksha/${widget.familyId}");

    try {
      final response = await http.get(url);
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        setState(() {
          dikshaMembers = jsonData['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching diksha data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddDikshaScreen(familyId: widget.familyId),
                ),
              ).then((_) => fetchDikshaMembers());
            },
            icon: const Icon(Icons.add),
            label: const Text("दीक्षा जोड़ें"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: dikshaMembers.isEmpty
                ? const Text("कोई दीक्षा जानकारी उपलब्ध नहीं है।")
                : ListView.builder(
                    itemCount: dikshaMembers.length,
                    itemBuilder: (context, index) {
                      final m = dikshaMembers[index];
return Card(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  elevation: 6,
  margin: const EdgeInsets.symmetric(vertical: 10),
  child: Column(
    children: [
      // Top Gradient Header
      Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: const Text(
          "दीक्षा जानकारी",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _infoTile("संत का नाम", m['name']),
                _infoTile("सदस्य का नाम", m['member_name']),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _infoTile("पूर्व रिश्ता", m['relation']),
                _infoTile("धार्मिक मान्यता", m['religious_belief']),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _infoTile("दीक्षा तिथि", m['dikhsa_date']),
                _infoTile("शहर", m['dikhsa_city']),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _infoTile("राज्य", m['dikhsa_state']),
                const Spacer(),
                Tooltip(
                  message: "डिलीट करें",
                  child: IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("पुष्टि करें"),
                          content: const Text("क्या आप वाकई इसे हटाना चाहते हैं?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("नहीं")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("हाँ")),
                          ],
                        ),
                      );

                      if (confirm == true) {
                    final url = Uri.parse("https://mrmapi.sadhumargi.in/api/delete-diksha/${m['id']}");
try {
  final response = await http.delete(url); // <-- ✅ सही method

                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("✅ डिलीट हो गया")),
                            );
                            await fetchDikshaMembers();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("❌ डिलीट नहीं हुआ")),
                            );
                          }
                        } catch (e) {
                          debugPrint("❌ Error deleting: $e");
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
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

Widget _infoTile(String title, dynamic value) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8, bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(
            value?.toString() ?? '-',
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    ),
  );
}


class AddDikshaScreen extends StatefulWidget {
  final String familyId;
  const AddDikshaScreen({super.key, required this.familyId});

  @override
  State<AddDikshaScreen> createState() => _AddDikshaScreenState();
}

class _AddDikshaScreenState extends State<AddDikshaScreen> {
  final _formKey = GlobalKey<FormState>();
  List<dynamic> members = [];
  List<dynamic> dikshaList = [];

  String? selectedMemberId;
  String? selectedMemberName;
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final dateController = TextEditingController();
  String? selectedRelation;
  String? selectedBelief;

  bool isSubmitting = false;

  final List<String> beliefs = [
    'साधुमार्गी',
    'स्थानकवासी',
    'मूर्तिपूजक',
    'तेरापंथ',
    'श्रवक संघ',
    'ज्ञान गच्छ',
    'अन्य'
  ];

  final List<String> relations = [
    'वीर माता',
    'वीर पिता',
    'वीर भ्राता',
    'वीर बहन',
    'वीर पुत्र',
    'वीर पुत्री',
  ];

  @override
  void initState() {
    super.initState();
    fetchFamilyMembers();
    fetchDikshaList();
  }

  Future<void> fetchFamilyMembers() async {
    final String familyId = widget.familyId;
    final prefs = await SharedPreferences.getInstance();
    final String? memberId = prefs.getString('member_id');

    final url = Uri.parse("https://mrmapi.sadhumargi.in/api/family-members/$familyId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "member_id": memberId ?? "",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> all = [];
        if (data['head'] != null) all.add(data['head']);
        if (data['members'] != null) all.addAll(data['members']);

        setState(() {
          members = all;
        });
      } else {
        debugPrint("❌ Failed to fetch members: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❗ Error: $e");
    }
  }

  Future<void> fetchDikshaList() async {
    final url = Uri.parse("https://mrmapi.sadhumargi.in/api/get-diksha/${widget.familyId}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          dikshaList = json.decode(response.body)['data'] ?? [];
        });
      } else {
        debugPrint("Failed to fetch diksha list");
      }
    } catch (e) {
      debugPrint("❗ Error fetching diksha list: $e");
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate() || selectedMemberId == null || selectedRelation == null) return;
    setState(() => isSubmitting = true);

    final body = {
      "member_id": selectedMemberId,
      "member_name": selectedMemberName,
      "name": nameController.text,
      "dikhsa_date": dateController.text,
      "dikhsa_city": cityController.text,
      "dikhsa_state": stateController.text,
      "relation": selectedRelation,
      "religious_belief": selectedBelief ?? "अन्य",
    };

    final url = Uri.parse("https://mrmapi.sadhumargi.in/api/save-diksha");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      final jsonRes = json.decode(response.body);
      if (jsonRes['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ सफलतापूर्वक सेव हो गया")),
        );
        await fetchDikshaList();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ सेव नहीं हुआ")),
        );
      }
    } catch (e) {
      debugPrint("Error saving diksha: $e");
    }

    setState(() => isSubmitting = false);
  }

Future<void> deleteDiksha(String id) async {
  final url = Uri.parse("https://mrmapi.sadhumargi.in/api/delete-diksha/$id");

  try {
    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    print("===== DELETE RESPONSE START =====");
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    print("===== DELETE RESPONSE END =====");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      print("✅ RECORD DELETED SUCCESSFULLY");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ डिलीट हो गया")),
      );
      await fetchDikshaList(); // or setState, if needed
    } else {
      print("❌ DELETE FAILED INSIDE 'if'");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ डिलीट नहीं हुआ: ${data['message'] ?? 'Unknown error'}")),
      );
    }
  } catch (e) {
    print("❌ DELETE FAILED IN CATCH BLOCK: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ डिलीट करते समय एरर: $e")),
    );
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("दीक्षा जोड़ें"),
      backgroundColor: Colors.deepPurple,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              const Text(
                "दीक्षा फ़ॉर्म",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const Divider(thickness: 1.5, height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: "पारिवारिक सदस्य का चयन करें",
                        prefixIcon: Icon(Icons.group),
                        border: OutlineInputBorder(),
                      ),
                      value: selectedMemberId,
                      items: members.map((m) {
                        return DropdownMenuItem(
                          value: m['member_id'].toString(),
                          child: Text(
                            "${m['salution'] ?? ''} ${m['first_name'] ?? ''} ${m['last_name'] ?? ''}".trim(),
                          ),
                          onTap: () {
                            selectedMemberName = "${m['first_name']} ${m['last_name']}";
                          },
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedMemberId = val),
                      validator: (val) => val == null ? 'कृपया सदस्य चुनें' : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "संत/सती म.सा. का नाम",
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val!.isEmpty ? "आवश्यक" : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: "दीक्षा तिथि",
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          dateController.text = picked.toIso8601String().split("T").first;
                        }
                      },
                      validator: (val) => val!.isEmpty ? "आवश्यक" : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: "दीक्षा शहर",
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: stateController,
                      decoration: const InputDecoration(
                        labelText: "दीक्षा राज्य",
                        prefixIcon: Icon(Icons.map),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "संबंध",
                        prefixIcon: Icon(Icons.people_alt),
                        border: OutlineInputBorder(),
                      ),
                      value: selectedRelation,
                      items: relations.map((r) {
                        return DropdownMenuItem(
                          value: r,
                          child: Text(r),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedRelation = val),
                      validator: (val) => val == null ? 'कृपया संबंध चुनें' : null,
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "धार्मिक मान्यता",
                        prefixIcon: Icon(Icons.book),
                        border: OutlineInputBorder(),
                      ),
                      value: selectedBelief,
                      items: beliefs.map((belief) {
                        return DropdownMenuItem(
                          value: belief,
                          child: Text(belief),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedBelief = val),
                    ),
                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting ? null : submitForm,
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check_circle),
                        label: const Text("सबमिट करें"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}




//------------------------------------PARIWAR AANJALI--------------------------------------

class ParivaranjaliScreen extends StatefulWidget {
  final String memberId;
  const ParivaranjaliScreen({super.key, required this.memberId});

  @override
  State<ParivaranjaliScreen> createState() => _ParivaranjaliScreenState();
}

class _ParivaranjaliScreenState extends State<ParivaranjaliScreen> {
  bool isLoading = true;
  bool isSaving = false;
  Map<String, bool> fields = {
    "ratri_bhoj": false,
    "sachit_jal": false,
    "gyan": false,
    "poshad": false,
    "sanvar": false,
    "sudh_bhiksha": false,
    "sankalp": false,
    "sewa": false,
    "sant_bhakti": false,
    "vihaar_bhakti": false,
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final int apiMemberId = int.tryParse(widget.memberId) ?? 0;
    if (apiMemberId < 100000) return;

    final url = Uri.parse("https://mrmapi.sadhumargi.in/api/parivaranjali/${apiMemberId - 100000}");
    try {
      final resp = await http.get(url);
      final jsonResp = json.decode(resp.body);
      if (jsonResp['success'] == true && jsonResp['data'] != null) {
        final Map<String, dynamic> data = jsonResp['data'];
        setState(() {
          fields = fields.map((key, _) => MapEntry(key, data[key] == 1));
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    setState(() => isLoading = false);
  }

 Future<void> updateData() async {
  setState(() => isSaving = true);

  final int actualId = int.tryParse(widget.memberId) ?? 0;
  final int apiMemberId = actualId - 100000;  // ✅ FIXED

  final url = Uri.parse("https://mrmapi.sadhumargi.in/api/parivaranjali");

  final body = {
    "member_id": apiMemberId,
    for (final e in fields.entries) e.key: e.value
  };

  try {
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    final jsonResp = json.decode(resp.body);
    if (resp.statusCode == 200 && jsonResp["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ सफलतापूर्वक सेव हो गया!")),
      );
      fetchData();
    } else {
      debugPrint("Update Error: ${resp.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: ${resp.body}")),
      );
    }
  } catch (e) {
    debugPrint("Exception: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ अपवाद: $e")),
    );
  }

  setState(() => isSaving = false);
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          Text(
            "🌸 परिवारांजलि संकल्प",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple),
          ),
          const Divider(),
          const SizedBox(height: 5),
          Expanded(
            child: ListView(
              children: fields.entries.map((entry) {
                return buildSwitch(_getHindiLabel(entry.key), entry.key);
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
         SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: isSaving
        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
        : const Icon(Icons.check),
    label: const Text(
      "परिवारांजलि सेव करें",
      style: TextStyle(color: Colors.white), // ✅ TEXT COLOR WHITE
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.purple,
      padding: const EdgeInsets.symmetric(vertical: 13),
      foregroundColor: Colors.white, // ✅ ICON COLOR + OVERLAY
    ),
    onPressed: isSaving ? null : updateData,
  ),
)

        ],
      ),
    );
  }

  Widget buildSwitch(String title, String key) {
    return SwitchListTile(
      value: fields[key] ?? false,
      onChanged: (val) => setState(() => fields[key] = val),
      title: Text(title),
      activeColor: Colors.purple,
    );
  }

  String _getHindiLabel(String key) {
    switch (key) {
      case 'ratri_bhoj':
        return "रात्रिभोज का त्याग";
      case 'sachit_jal':
        return "सचित जल";
      case 'gyan':
        return "ज्ञान";
      case 'poshad':
        return "पोषद";
      case 'sanvar':
        return "संवर";
      case 'sudh_bhiksha':
        return "शुद्ध भिक्षा";
      case 'sankalp':
        return "संकल्प";
      case 'sewa':
        return "सेवा";
      case 'sant_bhakti':
        return "संत-भक्ति";
      case 'vihaar_bhakti':
        return "विहार-भक्ति";
      default:
        return key;
    }
  }
}

//------------------------------------PARIWAR AANJALI--------------------------------------








//------------------------------------samanya jankari--------------------------------------

class MemberInfoForm extends StatefulWidget {
  final String memberId;
  const MemberInfoForm({super.key, required this.memberId});

  @override
  State<MemberInfoForm> createState() => _MemberInfoFormState();
}

class _MemberInfoFormState extends State<MemberInfoForm> {
  final _formKey = GlobalKey<FormState>();
  String selectedIntro = '1';
  TextEditingController distanceController = TextEditingController();
  bool isLoading = true;

  final List<Map<String, String>> sanghIntroOptions = [
    {'value': '1', 'label': 'अभी अभी'},
    {'value': '2', 'label': 'कुछ वर्षों से'},
    {'value': '3', 'label': 'पूर्वाचार्य भगवान के समय से'},
    {'value': '4', 'label': 'जन्म से'},
  ];



  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

Future<void> fetchInitialData() async {
  final url = Uri.parse("https://mrmapi.sadhumargi.in/api/members-family-details/${widget.memberId}");
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'];
      setState(() {
        selectedIntro = data['sangh_intro'] ?? '1';
        distanceController.text = data['samtabhawan_distance'] ?? '';
        isLoading = false;
      });
    } else {
      debugPrint("Fetch Error: ${response.body}");
      setState(() => isLoading = false);
    }
  } catch (e) {
    debugPrint("Exception: $e");
    setState(() => isLoading = false);
  }
}


  Future<void> updateMemberDetails() async {
    final url = Uri.parse("https://mrmapi.sadhumargi.in/api/members-family-details");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'member_id': widget.memberId,
          'sangh_intro': selectedIntro,
          'samtabhawan_distance': distanceController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ जानकारी सफलतापूर्वक अपडेट हो गई।')),
        );
      } else {
        debugPrint("Update Error: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ अपडेट में समस्या: ${response.body}')),
        );
      }
    } catch (e) {
      debugPrint("Exception during update: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ अपवाद: $e')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return Padding(
    padding: const EdgeInsets.all(16),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ✅ डेटा प्रीव्यू कार्ड
          Card(
            color: Colors.indigo.shade50,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.visibility, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        ' जानकारी ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1.2),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, color: Colors.black87),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "श्री साधुमार्गी संघ से परिचय: ${sanghIntroOptions.firstWhere((opt) => opt['value'] == selectedIntro)['label']}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.map, color: Colors.black87),
                      const SizedBox(width: 8),
                      Text(
                        "समता भवन दूरी: ${distanceController.text} कि.मी.",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          /// ✏️ एडिट फॉर्म सेक्शन
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.edit, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          'जानकारी में परिवर्तन करें',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    /// Dropdown Field
                    DropdownButtonFormField<String>(
                      value: selectedIntro,
                      decoration: InputDecoration(
                        labelText: '🔹 श्री साधुमार्गी संघ से परिचय',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: sanghIntroOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option['value'],
                          child: Text(option['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedIntro = value ?? '1');
                      },
                    ),

                    const SizedBox(height: 20),

                    /// Distance Field
                    TextFormField(
                      controller: distanceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '📍 समता भवन की अनुमानित दूरी (कि.मी.)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'कृपया दूरी दर्ज करें';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    /// Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updateMemberDetails();
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'परिवर्तन करें',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



}

//------------------------------------samanya jankari--------------------------------------
