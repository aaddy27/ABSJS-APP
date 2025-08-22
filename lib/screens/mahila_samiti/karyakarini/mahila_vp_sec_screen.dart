// lib/screens/mahila_samiti/karyakarini/mahila_vp_sec_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../layout_screen.dart';

class MahilaVpSecScreen extends StatefulWidget {
  const MahilaVpSecScreen({super.key});

  @override
  State<MahilaVpSecScreen> createState() => _MahilaVpSecScreenState();
}

class _MahilaVpSecScreenState extends State<MahilaVpSecScreen> {
  Map<String, List<dynamic>> groupedData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVpSecData();
  }

  Future<void> fetchVpSecData() async {
    const String url = "https://website.sadhumargi.in/api/mahila_vp_sec";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // 🔹 Group data by Aanchal
        final Map<String, List<dynamic>> grouped = {};
        for (var item in data) {
          final String aanchal = item["aanchal"]?["name"] ?? "Other";
          grouped.putIfAbsent(aanchal, () => []);
          grouped[aanchal]!.add(item);
        }

        setState(() {
          groupedData = grouped;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching VP/Secretary data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutScreen(
      title: "VP / Secretary",
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedData.isEmpty
              ? const Center(child: Text("No data found"))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: groupedData.entries.map((entry) {
                    final String aanchalName = entry.key;
                    final List<dynamic> members = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Heading for Aanchal
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            aanchalName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),

                        // 🔹 List of members in that Aanchal
                        Column(
                          children: members.map((item) {
                            final String name = item["name"] ?? "";
                            final String post = item["post"] ?? "";
                            final String mobile = item["mobile"] ?? "—";
                            final String photoUrl =
                                "https://website.sadhumargi.in${item['photo']}";

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin:
                                  const EdgeInsets.symmetric(vertical: 6),
                              elevation: 3,
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
                                subtitle: Text("पद: $post\nमोबाइल: $mobile"),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
    );
  }
}
