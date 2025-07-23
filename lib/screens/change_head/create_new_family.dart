import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateNewFamilyScreen extends StatefulWidget {
  const CreateNewFamilyScreen({super.key});

  @override
  State<CreateNewFamilyScreen> createState() => _CreateNewFamilyScreenState();
}

class _CreateNewFamilyScreenState extends State<CreateNewFamilyScreen> {
  String familyId = '';
  String memberId = '';

  List members = [];
  List relations = [];
  List anchals = [];
  List branches = [];

  List<int> selectedMemberIds = [];
  int? selectedHeadId;
  Map<int, int?> memberRelations = {}; // member_id : relation_id

  int? selectedAnchalId;
  int? selectedBranchId;
  String pinCode = '';
  String address = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFamilyId = prefs.getString('family_id');
    final savedMemberId = prefs.getString('member_id');

    if (savedFamilyId != null && savedMemberId != null) {
      setState(() {
        familyId = savedFamilyId;
        memberId = savedMemberId;
      });
      fetchInitialData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("यूज़र जानकारी नहीं मिली (Login करें)")),
      );
      Navigator.pop(context);
    }
  }

 Future<void> fetchInitialData() async {
  try {
    final memberRes = await http.get(
      Uri.parse("https://mrmapi.sadhumargi.in/api/family-members/$familyId"),
      headers: {"member_id": memberId},
    );
    final relationRes = await http.get(Uri.parse("https://mrmapi.sadhumargi.in/api/relations"));
    final anchalRes = await http.get(Uri.parse("http://mrmapi.sadhumargi.in/api/branches-anchals"));

    final memberData = json.decode(memberRes.body);
    final relationData = json.decode(relationRes.body);
    final anchalData = json.decode(anchalRes.body);

    // Parse members
    final parsedMembers = (memberData["members"] ?? []).map((m) {
      m["member_id"] = int.tryParse(m["member_id"].toString()) ?? 0;
      return m;
    }).toList();

    // Parse relations
    final parsedRelations = (relationData ?? []).map((r) {
      r["id"] = int.tryParse(r["id"].toString()) ?? 0;
      return r;
    }).toList();

    // Parse anchals (from Map)
    final anchalsMap = anchalData["anchals"] ?? {};
    final parsedAnchals = anchalsMap.entries.map((entry) {
      return {
        "id": int.tryParse(entry.key.toString()) ?? 0,
        "name": entry.value["name"]
      };
    }).toList();

    // Parse branches
    final parsedBranches = (anchalData["branches"] ?? []).map((b) {
      b["id"] = int.tryParse(b["id"].toString()) ?? 0;
      b["anchal_id"] = int.tryParse(b["anchal_id"].toString()) ?? 0;
      return b;
    }).toList();

    setState(() {
      members = parsedMembers;
      relations = parsedRelations;
      anchals = parsedAnchals;
      branches = parsedBranches;
      isLoading = false;
    });
  } catch (e) {
    print("Error: $e");
    setState(() => isLoading = false);
  }
}

  void submit() async {
    if (selectedMemberIds.isEmpty || selectedHeadId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("सभी जानकारी भरें")));
      return;
    }

    List<int> nonHeadMembers = selectedMemberIds.where((id) => id != selectedHeadId).toList();

    final payload = {
      "members": selectedMemberIds,
      "new_head_id": selectedHeadId,
      "relations": nonHeadMembers.map((id) {
        return {
          "member_id": id,
          "relation_id": memberRelations[id],
        };
      }).toList(),
      "anchal_id": selectedAnchalId,
      "branch_id": selectedBranchId,
      "pincode": pinCode,
      "address": address,
    };

    final res = await http.post(
      Uri.parse("https://mrmapi.sadhumargi.in/api/split-family"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ नया परिवार सफलतापूर्वक बनाया गया")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ त्रुटि: परिवार नहीं बन पाया\n${res.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("👪 नया परिवार बनाएँ")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("❗ जिन सदस्यों को विभाजित करना है, उनका चयन करें:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...members.map((member) {
                  final id = int.tryParse(member["member_id"].toString()) ?? 0;
                  final fullName = member["full_name"] ?? "${member["first_name"] ?? ''} ${member["last_name"] ?? ''}";
                  return CheckboxListTile(
                    title: Text(fullName),
                    value: selectedMemberIds.contains(id),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedMemberIds.add(id);
                        } else {
                          selectedMemberIds.remove(id);
                          if (selectedHeadId == id) selectedHeadId = null;
                          memberRelations.remove(id);
                        }
                      });
                    },
                  );
                }),

                const SizedBox(height: 10),
                const Text("🧑 नए परिवार का मुखिया चुनें:"),
                DropdownButtonFormField<int>(
                  value: selectedHeadId,
                  hint: const Text("मुखिया चुनें"),
                  items: selectedMemberIds
                      .map((id) {
                        final member = members.firstWhere((m) => m["member_id"] == id, orElse: () => {});
                        final fullName = member["full_name"] ?? "${member["first_name"] ?? ''} ${member["last_name"] ?? ''}";
                        return DropdownMenuItem(value: id, child: Text(fullName));
                      })
                      .toList(),
                  onChanged: (val) => setState(() => selectedHeadId = val),
                ),

                const SizedBox(height: 10),
                ...selectedMemberIds
                    .where((id) => id != selectedHeadId)
                    .map((id) {
                      final member = members.firstWhere((m) => m["member_id"] == id, orElse: () => {});
                      final fullName = member["full_name"] ?? "${member["first_name"] ?? ''} ${member["last_name"] ?? ''}";
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text("$fullName के लिए मुखिया से रिश्ता:"),
                          DropdownButtonFormField<int>(
                            value: memberRelations[id],
                            items: relations
                                .map<DropdownMenuItem<int>>(
                                  (rel) => DropdownMenuItem(
                                    value: rel['id'],
                                    child: Text(rel['relation_utf8']),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => setState(() => memberRelations[id] = val),
                          ),
                        ],
                      );
                    }),
const Divider(height: 30),

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text("Select Anchal"),
DropdownButtonFormField<int>(
  value: selectedAnchalId,
  isExpanded: true,
  hint: const Text("Select Anchal"),
  decoration: const InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    border: UnderlineInputBorder(), // optional: can style if needed
  ),
  items: anchals.map<DropdownMenuItem<int>>((a) {
    return DropdownMenuItem(
      value: a["id"],
      child: SizedBox(
        width: double.infinity,
        child: Text(
          a["name"],
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }).toList(),
  onChanged: (val) {
    setState(() {
      selectedAnchalId = val;
      selectedBranchId = null;
    });
  },
),


    const SizedBox(height: 16),

    const Text("Select Branch"),
    DropdownButtonFormField<int>(
      value: selectedBranchId,
      hint: const Text("Select Branch"),
      isExpanded: true, // <-- ensures full width
      items: branches
          .where((b) => b["anchal_id"] == selectedAnchalId)
          .map<DropdownMenuItem<int>>(
            (b) => DropdownMenuItem(
              value: b["id"],
              child: Text(
                b["branch_name"],
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          )
          .toList(),
      onChanged: (val) => setState(() => selectedBranchId = val),
    ),
  ],
),


                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(labelText: "Pin Code"),
                  onChanged: (val) => pinCode = val,
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Address"),
                  onChanged: (val) => address = val,
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text("Cancel"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: submit,
                      icon: const Icon(Icons.check),
                      label: const Text("✅ नया परिवार बनाएँ"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ]),
            ),
    );
  }
}
