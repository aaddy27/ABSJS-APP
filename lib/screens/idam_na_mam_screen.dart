import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class IdamNaMamScreen extends StatefulWidget {
  const IdamNaMamScreen({super.key});

  @override
  State<IdamNaMamScreen> createState() => _IdamNaMamScreenState();
}

class _IdamNaMamScreenState extends State<IdamNaMamScreen> {
  List announcements = [];
  Map<String, dynamic>? summary;
  bool isLoading = true;
  bool isLoadingAnnouncements = false;
  String? memberId;
  bool showAnnouncements = false;

  @override
  void initState() {
    super.initState();
    loadMemberId();
  }

  Future<void> loadMemberId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("member_id");
    if (id != null) {
      memberId = id;
      await fetchSummary(id);
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> fetchSummary(String mid) async {
    final url =
        "https://misapp.sadhumargi.com/api/donor-announcements/idam/summary/$mid";
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        summary = jsonDecode(res.body);

        // अगर total_activity_amount 0 है तो summary null मान लो
        if (summary?['total_activity_amount'] == null ||
            summary?['total_activity_amount'] == 0) {
          summary = null;
        }
      }
    } catch (e) {
      debugPrint("Error fetching summary: $e");
    }
  }

  Future<void> fetchAnnouncements(String mid) async {
    setState(() => isLoadingAnnouncements = true);
    final url =
        "https://misapp.sadhumargi.com/api/donor-announcements/idam/$mid";
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        announcements = jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("Error fetching announcements: $e");
    } finally {
      setState(() => isLoadingAnnouncements = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (memberId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "सदस्य आईडी नहीं मिली। कृपया पुनः लॉगिन करें।",
            style: TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 🔹 अगर summary और announcements दोनों empty/null हैं → सिर्फ empty message दिखाओ
    if (summary == null && announcements.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(child: _buildEmptyState(theme)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 🔹 Summary Card (Only if available)
              if (summary != null) _buildSummaryCard(summary!, theme),

              const SizedBox(height: 10),

              // 🔹 Toggle Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (!showAnnouncements) {
                        fetchAnnouncements(memberId!);
                      }
                      setState(() {
                        showAnnouncements = !showAnnouncements;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(
                      showAnnouncements
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    label: Text(
                      showAnnouncements ? "घोषणाएँ छिपाएँ" : "घोषणाएँ देखें",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // 🔹 Announcements List (Toggle show/hide)
              if (showAnnouncements)
                if (isLoadingAnnouncements)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  )
                else if (announcements.isEmpty)
                  _buildEmptyState(theme)
                else
                  Column(
                    children: announcements
                        .map((item) => _buildAnnouncementCard(item, theme))
                        .toList(),
                  ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(Icons.volunteer_activism_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            "आपकी कोई 'इदम् न मम' घोषणा नहीं है।",
            style:
                theme.textTheme.titleLarge?.copyWith(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "दान की इस पवित्र धारा से जुड़ें और पुण्य के भागी बनें।",
            style:
                theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Announcement card
  Widget _buildAnnouncementCard(Map<String, dynamic> item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['Activity Name'] ?? 'N/A',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16),
            _buildInfoRow(Icons.calendar_today_outlined, "घोषणा तिथि:",
                item['Announcement Date']),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.account_balance_wallet_outlined, "घोषणा राशि:",
                "₹${item['Announcement Amount']}"),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.check_circle_outline, "प्राप्त राशि:",
                "₹${item['Received Amount']}"),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.hourglass_empty_outlined, "बकाया राशि:",
                "₹${item['OutStanding Amount']}",
                valueColor: Colors.orange.shade800),
          ],
        ),
      ),
    );
  }

  /// Summary card
  Widget _buildSummaryCard(Map<String, dynamic> summaryData, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📊 कुल सारांश",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const Divider(height: 20),
            _buildInfoRow(Icons.date_range_outlined, "प्रथम घोषणा:",
                "${summaryData['first_announcement_date']}"),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.account_balance_wallet, "कुल घोषणा:",
                "₹${summaryData['total_activity_amount']}"),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.check_circle, "कुल प्राप्त राशि:",
                "₹${summaryData['total_received_amount']}",
                valueColor: Colors.green.shade700),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.error_outline, "कुल बकाया राशि:",
                "₹${summaryData['total_outstanding_amount']}",
                valueColor: Colors.red.shade700),
          ],
        ),
      ),
    );
  }

  /// Info row
  Widget _buildInfoRow(IconData icon, String title, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
              color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
