import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../base_scaffold.dart';

class KsmMemberScreen extends StatefulWidget {
  const KsmMemberScreen({super.key});

  @override
  State<KsmMemberScreen> createState() => _KsmMemberScreenState();
}

class _KsmMemberScreenState extends State<KsmMemberScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, List<Map<String, dynamic>>>> groupedData;

  // ✅ Fetch and group members by AANCHAL NAME
  Future<Map<String, List<Map<String, dynamic>>>> fetchMembers() async {
    final response = await http.get(
      Uri.parse('https://website.sadhumargi.in/api/karyasamiti_sadasya'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);

      Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var item in jsonData) {
        if (item is Map<String, dynamic>) {
          final aanchalName = item['aanchal']?['name']?.toString() ?? 'अनजान';
          grouped.putIfAbsent(aanchalName, () => []).add(item);
        }
      }

      return grouped;
    } else {
      throw Exception('❌ Failed to load members');
    }
  }

  @override
  void initState() {
    super.initState();
    groupedData = fetchMembers();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: groupedData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('कोई डेटा नहीं मिला'));
          }

          final aanchalList = snapshot.data!.keys.toList();

          return DefaultTabController(
            length: aanchalList.length,
            child: Column(
              children: [
                Container(
                  color: Colors.blue.shade800,
                  child: TabBar(
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: aanchalList.map((a) => Tab(text: a)).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: aanchalList.map((aanchal) {
                      final members = snapshot.data![aanchal]!;

                      return ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final m = members[index];

                          final name = m['name']?.toString() ?? '';
                          final city = m['city']?.toString() ?? '';
                          final mobile = m['mobile']?.toString() ?? '';
                          final photoPath = m['photo']?.toString() ?? '';

                          final String imageUrl = photoPath.isNotEmpty
                              ? 'https://website.sadhumargi.in/storage/$photoPath'
                              : 'https://via.placeholder.com/100x100.png?text=No+Image';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(imageUrl),
                                onBackgroundImageError: (_, __) {},
                              ),
                              title: Text(name),
                              subtitle: Text('$city • $mobile'),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
