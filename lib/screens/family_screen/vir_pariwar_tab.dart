import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VirPariwarTab extends StatefulWidget {
  final String familyId;
  const VirPariwarTab({super.key, required this.familyId});

  @override
  State<VirPariwarTab> createState() => _VirPariwarTabState();
}

class _VirPariwarTabState extends State<VirPariwarTab> {
  List<dynamic> dikshaMembers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDikshaMembers();
  }

  Future<void> _fetchDikshaMembers() async {
    final url = Uri.parse(
        "https://mrmapi.sadhumargi.in/api/family-diksha/${widget.familyId}");

    try {
      final response = await http.get(url);
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        setState(() {
          dikshaMembers = jsonData['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteDiksha(String id) async {
    final url =
        Uri.parse("https://mrmapi.sadhumargi.in/api/delete-diksha/$id");
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ डिलीट हो गया")),
        );
        await _fetchDikshaMembers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ डिलीट नहीं हुआ")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
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
              ).then((_) => _fetchDikshaMembers());
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
                      return _DikshaCard(
                        data: m,
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("पुष्टि करें"),
                              content: const Text(
                                  "क्या आप वाकई इसे हटाना चाहते हैं?"),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("नहीं")),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("हाँ")),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _deleteDiksha(m['id'].toString());
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DikshaCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onDelete;
  const _DikshaCard({required this.data, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(children: [
                  _infoTile("संत का नाम", data['name']),
                  _infoTile("सदस्य का नाम", data['member_name']),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _infoTile("पूर्व रिश्ता", data['relation']),
                  _infoTile("धार्मिक मान्यता", data['religious_belief']),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _infoTile("दीक्षा तिथि", data['dikhsa_date']),
                  _infoTile("शहर", data['dikhsa_city']),
                ]),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _infoTile("राज्य", data['dikhsa_state']),
                    const Spacer(),
                    Tooltip(
                      message: "डिलीट करें",
                      child: IconButton(
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.red, size: 28),
                        onPressed: onDelete,
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
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87)),
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
    _fetchFamilyMembers();
    _fetchDikshaList();
  }

  Future<void> _fetchFamilyMembers() async {
    final url = Uri.parse(
        "https://mrmapi.sadhumargi.in/api/family-members/${widget.familyId}");

    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> all = [];
        if (data['head'] != null) all.add(data['head']);
        if (data['members'] != null) all.addAll(data['members']);
        setState(() => members = all);
      }
    } catch (_) {}
  }

  Future<void> _fetchDikshaList() async {
    final url =
        Uri.parse("https://mrmapi.sadhumargi.in/api/get-diksha/${widget.familyId}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          dikshaList = json.decode(response.body)['data'] ?? [];
        });
      }
    } catch (_) {}
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        selectedMemberId == null ||
        selectedRelation == null) return;
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
        await _fetchDikshaList();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ सेव नहीं हुआ")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("दीक्षा जोड़ें"), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                const Text("दीक्षा फ़ॉर्म",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple)),
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
                              "${m['salution'] ?? ''} ${m['first_name'] ?? ''} ${m['last_name'] ?? ''}"
                                  .trim(),
                            ),
                            onTap: () {
                              selectedMemberName =
                                  "${m['first_name'] ?? ''} ${m['last_name'] ?? ''}"
                                      .trim();
                            },
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedMemberId = val),
                        validator: (val) =>
                            val == null ? 'कृपया सदस्य चुनें' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "संत/सती म.सा. का नाम",
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => (val == null || val.isEmpty)
                            ? "आवश्यक"
                            : null,
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
                            dateController.text =
                                picked.toIso8601String().split("T").first;
                          }
                        },
                        validator: (val) => (val == null || val.isEmpty)
                            ? "आवश्यक"
                            : null,
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
                        items: relations
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedRelation = val),
                        validator: (val) =>
                            val == null ? 'कृपया संबंध चुनें' : null,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "धार्मिक मान्यता",
                          prefixIcon: Icon(Icons.book),
                          border: OutlineInputBorder(),
                        ),
                        value: selectedBelief,
                        items: beliefs
                            .map((b) =>
                                DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedBelief = val),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isSubmitting ? null : _submitForm,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check_circle),
                          label: const Text("सबमिट करें"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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
