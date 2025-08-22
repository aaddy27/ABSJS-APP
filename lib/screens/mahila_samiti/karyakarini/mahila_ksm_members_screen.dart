// lib/screens/mahila_samiti/karyakarini/mahila_ksm_members_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../layout_screen.dart';  // ✅ Layout import किया

class MahilaKsmMembersScreen extends StatefulWidget {
  const MahilaKsmMembersScreen({super.key});

  @override
  State<MahilaKsmMembersScreen> createState() => _MahilaKsmMembersScreenState();
}

class _MahilaKsmMembersScreenState extends State<MahilaKsmMembersScreen> {
  Map<String, List<dynamic>> groupedData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchKsmMembers();
  }

  Future<void> fetchKsmMembers() async {
    const String url = "https://website.sadhumargi.in/api/mahila_ksm_members";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Group by aanchal name
        Map<String, List<dynamic>> temp = {};
        for (var item in data) {
          final String aanchalName = item["aanchal"]?["name"] ?? "अन्य";
          if (!temp.containsKey(aanchalName)) {
            temp[aanchalName] = [];
          }
          temp[aanchalName]!.add(item);
        }

        setState(() {
          groupedData = temp;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching KSM Members: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutScreen(
      title: " KSM Members",   // ✅ AppBar का title Layout से आएगा
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedData.isEmpty
              ? const Center(child: Text("No members found"))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: groupedData.entries.map((entry) {
                    final String aanchalName = entry.key;
                    final List<dynamic> members = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Aanchal Heading
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            aanchalName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        // Members under this aanchal
                        Column(
                          children: members.map((item) {
                            final String name = item["name"] ?? "";
                            final String city = item["city"] ?? "";
                            final String mobile = item["mobile"] ?? "—";
                            final String photoUrl =
                                "https://website.sadhumargi.in${item['photo']}";

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(photoUrl),
                                  backgroundColor: Colors.grey[200],
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("शहर: $city"),
                                    Text("मोबाइल: $mobile"),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const Divider(thickness: 1),
                      ],
                    );
                  }).toList(),
                ),
    );
  }
}
