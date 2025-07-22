import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../base_scaffold.dart';

class ChangeHeadScreen extends StatefulWidget {
  const ChangeHeadScreen({super.key});

  @override
  State<ChangeHeadScreen> createState() => _ChangeHeadScreenState();
}

class _ChangeHeadScreenState extends State<ChangeHeadScreen> {
  String? selectedHeadId;
  String? familyId;
  String? memberId;

  List<dynamic> allMembers = [];
  List<dynamic> relations = [];
  List<Map<String, dynamic>> memberRelations = [];

  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    familyId = prefs.getString('family_id');
    memberId = prefs.getString('member_id');

    if (familyId == null || memberId == null) return;

    try {
      final membersRes = await http.get(
        Uri.parse('https://mrmapi.sadhumargi.in/api/family-members/$familyId'),
        headers: {'member_id': memberId!},
      );
      final relationsRes = await http.get(
        Uri.parse('https://mrmapi.sadhumargi.in/api/relations'),
      );

      if (membersRes.statusCode == 200 && relationsRes.statusCode == 200) {
        final membersJson = jsonDecode(membersRes.body);
        final relationJson = jsonDecode(relationsRes.body);

        List<dynamic> all = [];
        if (membersJson['head'] != null) all.add(membersJson['head']);
        if (membersJson['members'] != null) all.addAll(membersJson['members']);

        setState(() {
          allMembers = all;
          relations = relationJson;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  void showRelationDialog() {
    memberRelations = allMembers
        .where((m) => m['member_id'].toString() != selectedHeadId)
        .map((m) => {
              'member_id': m['member_id'],
              'name':
                  "${m['salution'] ?? ''} ${m['first_name'] ?? ''} ${m['last_name'] ?? ''}".trim(),
              'relation': null,
            })
        .toList();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      "👨‍👩‍👧 नए मुखिया के साथ सदस्यों का रिश्ता सेट करें",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: memberRelations.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, index) {
                    final member = memberRelations[index];
                    return Row(
                      children: [
                        Expanded(child: Text(member['name'] ?? 'Unknown')),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: member['relation'],
                          hint: const Text("रिश्ता"),
                          isDense: true,
                          alignment: Alignment.centerLeft,
                          items: relations.map<DropdownMenuItem<String>>((rel) {
                            return DropdownMenuItem(
                              value: rel['id'].toString(),
                              child: Text(rel['relation_utf8']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              memberRelations[index]['relation'] = value;
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: submitRequest,
                icon: const Icon(Icons.check),
                label: const Text("✅ अपडेट करें"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitRequest() async {
    if (selectedHeadId == null || familyId == null) return;

    bool anyMissing = memberRelations.any((m) => m['relation'] == null);
    if (anyMissing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❗ कृपया सभी सदस्यों के रिश्ते चुनें")),
      );
      return;
    }

    final payload = {
      "family_id": familyId,
      "new_head_id": (int.parse(selectedHeadId!) - 100000).toString(),
      "relations": memberRelations.map((r) {
        return {
          "member_id": (int.parse(r['member_id'].toString()) - 100000).toString(),
          "relation": r['relation'],
        };
      }).toList(),
    };

    setState(() => isSubmitting = true);
    final res = await http.post(
      Uri.parse('https://mrmapi.sadhumargi.in/api/head-change-request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    setState(() => isSubmitting = false);

    Navigator.pop(context); // Close dialog
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ मुखिया सफलतापूर्वक बदल दिया गया")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${body['message']}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ अनुरोध असफल रहा")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedHeadId,
                      hint: const Text("नए परिवार मुखिया का चयन करें"),
                      items: allMembers
                          .where((m) => m['is_head_of_family'] != 1)
                          .map<DropdownMenuItem<String>>((m) {
                        final name =
                            "${m['salution'] ?? ''} ${m['first_name'] ?? ''} ${m['last_name'] ?? ''}".trim();
                        return DropdownMenuItem(
                          value: m['member_id'].toString(),
                          child: Text(name.isEmpty ? "Unknown" : name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => selectedHeadId = val);
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            selectedHeadId == null || isSubmitting ? null : showRelationDialog,
                        child: const Text("परिवर्तन करें"),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
