import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../layout_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MahilaAavedanPatraScreen extends StatefulWidget {
  const MahilaAavedanPatraScreen({super.key});

  @override
  State<MahilaAavedanPatraScreen> createState() => _MahilaAavedanPatraScreenState();
}

class _MahilaAavedanPatraScreenState extends State<MahilaAavedanPatraScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<dynamic> onlineList = [];
  List<dynamic> offlineList = [];
  bool isLoadingOnline = true;
  bool isLoadingOffline = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchOnline();
    fetchOffline();
  }

  Future<void> fetchOnline() async {
    final response = await http.get(Uri.parse(
        "https://website.sadhumargi.in/api/mahila-aavedan-patra/online"));
    if (response.statusCode == 200) {
      setState(() {
        onlineList = json.decode(response.body);
        isLoadingOnline = false;
      });
    } else {
      setState(() => isLoadingOnline = false);
    }
  }

  Future<void> fetchOffline() async {
    final response = await http.get(Uri.parse(
        "https://website.sadhumargi.in/api/mahila-aavedan-patra/offline"));
    if (response.statusCode == 200) {
      setState(() {
        offlineList = json.decode(response.body);
        isLoadingOffline = false;
      });
    } else {
      setState(() => isLoadingOffline = false);
    }
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ लिंक नहीं खुल सका")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutScreen(
      title: "आवेदन पत्र",
      body: Column(
        children: [
          // 🔹 Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.amber[800],
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.amber[800],
            tabs: const [
              Tab(text: "ऑफ़लाइन"), // पहले Offline
              Tab(text: "ऑनलाइन"),  // बाद में Online
            ],
          ),

          // 🔹 Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // OFFLINE TAB (पहले)
                isLoadingOffline
                    ? const Center(child: CircularProgressIndicator())
                    : _buildList(offlineList),

                // ONLINE TAB (बाद में)
                isLoadingOnline
                    ? const Center(child: CircularProgressIndicator())
                    : _buildList(onlineList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic> data) {
    if (data.isEmpty) {
      return const Center(child: Text("⚠ कोई डेटा उपलब्ध नहीं है"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              item["name"] ?? "Untitled",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text("Type: ${item["type"]}"),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (item["type"] == "google_form" &&
                    item["google_form_link"] != null) {
                  _openUrl(item["google_form_link"]);
                } else if (item["type"] == "pdf" && item["pdf"] != null) {
                  _openUrl(
                      "https://website.sadhumargi.in/storage/${item["pdf"]}");
                }
              },
              child: Text(item["type"] == "google_form" ? "Open Form" : "Open PDF"),
            ),
          ),
        );
      },
    );
  }
}
