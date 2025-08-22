// lib/screens/mahila_samiti/karyakarini/mahila_pravarti_sanyojak_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../layout_screen.dart';

class MahilaPravartiSanyojakScreen extends StatefulWidget {
  const MahilaPravartiSanyojakScreen({super.key});

  @override
  State<MahilaPravartiSanyojakScreen> createState() =>
      _MahilaPravartiSanyojakScreenState();
}

class _MahilaPravartiSanyojakScreenState
    extends State<MahilaPravartiSanyojakScreen> {
  Map<String, List<dynamic>> groupedData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPravartiSanyojak();
  }

  Future<void> fetchPravartiSanyojak() async {
    const String url =
        "https://website.sadhumargi.in/api/mahila_pravarti_sanyojika";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Grouping by "pravarti"
        Map<String, List<dynamic>> temp = {};
        for (var item in data) {
          final String pravarti = item["pravarti"] ?? "अन्य";
          if (!temp.containsKey(pravarti)) {
            temp[pravarti] = [];
          }
          temp[pravarti]!.add(item);
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
      debugPrint("Error fetching Pravarti Sanyojak: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutScreen(
      title: "महिला प्रवर्ति संयोजक",
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedData.isEmpty
              ? const Center(child: Text("No data found"))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: groupedData.entries.map((entry) {
                    final String pravartiName = entry.key;
                    final List<dynamic> members = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pravarti Heading
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            pravartiName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        // Members under this Pravarti
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
                                    Text("पद: $post"),
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
