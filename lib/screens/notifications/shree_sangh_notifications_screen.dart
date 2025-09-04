import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShreeSanghNotificationsScreen extends StatefulWidget {
  const ShreeSanghNotificationsScreen({super.key});

  @override
  State<ShreeSanghNotificationsScreen> createState() => _ShreeSanghNotificationsScreenState();
}

class _ShreeSanghNotificationsScreenState extends State<ShreeSanghNotificationsScreen> {
  List notifications = [];
  bool isLoading = true;

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse("https://website.sadhumargi.in/api/notifications/filter?group=Shree%20Sangh"),
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifications.isEmpty) {
      return const Center(child: Text("No Notifications Found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final item = notifications[index];
        final String title = item["title"] ?? "";
        final String body = item["body"] ?? "";
        final String? imageUrl = item["image"];
        final String date = item["created_at"].toString().split("T").first;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Title
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),

                // ✅ Body with See More
                _buildBodyText(context, title, body, imageUrl),

                // ✅ Image (if available)
                if (imageUrl != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showFullImage(context, imageUrl),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                // ✅ Date
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Text with See More
  Widget _buildBodyText(BuildContext context, String title, String body, String? imageUrl) {
    const maxLines = 3;

    if (body.split(" ").length > 20 || body.length > 100) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            body,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
          InkWell(
            onTap: () => _showFullMessage(context, title, body, imageUrl),
            child: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(
                "See More",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    return Text(body);
  }

  // ✅ Full message modal
  void _showFullMessage(BuildContext context, String title, String body, String? imageUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),

                // Image if available
                if (imageUrl != null) ...[
                  GestureDetector(
                    onTap: () => _showFullImage(context, imageUrl),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(imageUrl),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Full Body
                Text(
                  body,
                  style: const TextStyle(fontSize: 15),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Fullscreen image viewer
  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black,
          child: Center(
            child: InteractiveViewer(
              child: Image.network(url),
            ),
          ),
        ),
      ),
    );
  }
}
