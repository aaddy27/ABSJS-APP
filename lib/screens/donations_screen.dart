import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  bool isLoading = true;
  List<dynamic> announcements = [];

  final NumberFormat indianFormat = NumberFormat.decimalPattern('hi_IN');

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memberId = prefs.getString("member_id");

      if (memberId == null) {
        setState(() => isLoading = false);
        return;
      }

      final url = Uri.parse(
          "https://misapp.sadhumargi.com/api/donor-announcements/$memberId");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          announcements = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchReceipts(String announcementId) async {
    try {
      final url = Uri.parse(
          "https://misapp.sadhumargi.com/api/announcement-receipts/$announcementId");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        showReceiptsDialog(data);
      } else {
        debugPrint("Receipt API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception fetching receipts: $e");
    }
  }

void showReceiptsDialog(List<dynamic> receipts) {
  showDialog(
    context: context,
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            title: const Text(
              "रसीद विवरण",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: isWide ? 500 : double.maxFinite,
              child: receipts.isEmpty
                  ? const Text("कोई रसीद प्राप्त नहीं हुई है। \n अधिक जानकारी के लिए \n  श्री अ.भा.सा. जैन संघ केंद्र कार्यालय के लेखा साखा विभाग से संपर्क करे। \n 7073311108 \n धन्यवाद। ")
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: receipts.length,
                      itemBuilder: (context, index) {
                        final r = receipts[index];

                        final announcementAmt = indianFormat.format(
                            r["announcement_amount"] ?? 0);
                        final activityAmt = indianFormat.format(
                            r["activity_amount"] ?? 0);

                        // 🔹 Format date to dd-MM-yyyy
                        final rawDate = r["receipt_date"] ?? "";
                        String formattedDate = rawDate;
                        try {
                          if (rawDate.isNotEmpty) {
                            final parsedDate = DateTime.parse(rawDate);
                            formattedDate =
                                DateFormat('dd-MM-yyyy').format(parsedDate);
                          }
                        } catch (e) {
                          debugPrint("Date parse error: $e");
                        }

                        return Card(
                          color: Colors.orange.shade50,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("रसीद संख्या : ${r["receipt_number"] ?? "-"}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text("दिनांक : $formattedDate"),
                                Text("घोषित राशि : ₹$announcementAmt"),
                                Text("प्राप्त राशि : ₹$activityAmt"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("बंद करें"),
              )
            ],
          );
        },
      );
    },
  );
}


  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    final horizontalPadding = isWide ? screenWidth * 0.2 : 16.0;

    // 🔹 अगर कोई donation नहीं है
    if (announcements.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/donation.webp",
                height: isWide ? 250 : 180,
              ),
              const SizedBox(height: 20),
              const Text(
                "🙏 साधुमार्गी जैन संघ की प्रवृत्तियों,\nसंघ के उत्थान और समाज सेवा हेतु\nआपका सहयोग अनमोल है।\n\nआज ही दान देकर पुण्य अर्जित करें 🙏",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 20),

              // Donor Portal Button
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 250, maxWidth: 400),
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(
                      "https://donorportal.sadhumargi.com/login"),
                  icon:
                      const Icon(Icons.volunteer_activism, color: Colors.white),
                  label: const Text(
                    "Donor Portal से दान करें",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Razorpay Direct Donate Button
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 250, maxWidth: 400),
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(
                      "https://razorpay.com/payment-button/pl_JoX6ZBeBRmwAfA/view/?utm_source=payment_button&utm_medium=button&utm_campaign=payment_button"),
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text(
                    "Donate Now Online (₹2000/- तक)",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 🔹 अगर donations available हैं
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        final item = announcements[index];

        final announced =
            indianFormat.format(item["Announcement Amount"] ?? 0);
        final received =
            indianFormat.format(item["Received Amount"] ?? 0);
        final outstanding =
            indianFormat.format(item["OutStanding Amount"] ?? 0);

        final announcementId = item["Announcement Id"].toString();

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${item["Activity Name"] ?? ""}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 6),
                Text("घोषणा दिनांक : ${item["Announcement Date"] ?? "-"}"),
                const Divider(),
                Text("घोषित राशि : ₹$announced"),
                Text("प्राप्त राशि : ₹$received"),
                Text("शेष राशि : ₹$outstanding"),

                const SizedBox(height: 10),

             Align(
  alignment: Alignment.centerRight,
  child: OutlinedButton.icon(
    onPressed: () => fetchReceipts(announcementId),
    icon: const Icon(Icons.receipt_long, color: Colors.deepOrange),
    label: const Text(
      "रसीद देखें",
      style: TextStyle(color: Colors.deepOrange),
    ),
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.deepOrange, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: Colors.white, // 🔹 White background
    ),
  ),
),

              ],
            ),
          ),
        );
      },
    );
  }
}
