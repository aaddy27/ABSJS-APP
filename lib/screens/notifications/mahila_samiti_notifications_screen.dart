import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MahilaSamitiNotificationsScreen extends StatefulWidget {
  const MahilaSamitiNotificationsScreen({super.key});

  @override
  State<MahilaSamitiNotificationsScreen> createState() => _MahilaSamitiNotificationsScreenState();
}

class _MahilaSamitiNotificationsScreenState extends State<MahilaSamitiNotificationsScreen> {
  List notifications = [];
  bool isLoading = true;

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse("https://website.sadhumargi.in/api/notifications/filter?group=Mahila%20Samiti"),
      );
      if (response.statusCode == 200) {
        setState(() {
          notifications = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (notifications.isEmpty) return const Center(child: Text("No Notifications Found"));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final item = notifications[index];
        final title = item["title"] ?? "";
        final body = item["body"] ?? "";
        final imageUrl = item["image"];
        final date = item["created_at"].toString().split("T").first;

        return _buildNotificationCard(context, title, body, imageUrl, date);
      },
    );
  }

  Widget _buildNotificationCard(BuildContext context, String title, String body, String? imageUrl, String date) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            _buildBodyText(context, title, body, imageUrl),
            if (imageUrl != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showFullImage(context, imageUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
            ],
            const SizedBox(height: 6),
            Align(alignment: Alignment.centerRight, child: Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyText(BuildContext context, String title, String body, String? imageUrl) {
    if (body.split(" ").length > 20 || body.length > 100) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(body, maxLines: 3, overflow: TextOverflow.ellipsis),
          InkWell(
            onTap: () => _showFullMessage(context, title, body, imageUrl),
            child: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text("See More", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    }
    return Text(body);
  }

  void _showFullMessage(BuildContext context, String title, String body, String? imageUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              if (imageUrl != null) ...[
                GestureDetector(
                  onTap: () => _showFullImage(context, imageUrl),
                  child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(imageUrl)),
                ),
                const SizedBox(height: 12),
              ],
              Text(body, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 16),
            ]),
          ),
        );
      },
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black,
          child: Center(child: InteractiveViewer(child: Image.network(url))),
        ),
      ),
    );
  }
}
