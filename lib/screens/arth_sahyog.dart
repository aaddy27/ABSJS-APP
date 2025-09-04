import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'base_scaffold.dart';
import 'idam_na_mam_screen.dart';
import 'donations_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ArthSahyogScreen extends StatelessWidget {
  const ArthSahyogScreen({super.key});

  // Donor Portal Launch
  Future<void> _launchDonationPortal() async {
    const url = "https://donorportal.sadhumargi.com/login";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Razorpay Payment Button Launch
  Future<void> _launchRazorpayButton() async {
    const url =
        "https://razorpay.com/payment-button/pl_JoX6ZBeBRmwAfA/view/?utm_source=payment_button&utm_medium=button&utm_campaign=payment_button";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 🔹 अब 3 tabs होंगे
      child: BaseScaffold(
        selectedIndex: -1,
        body: Column(
          children: [
            // 🔹 App Heading
            Container(
              color: Colors.deepOrange.shade50,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "अर्थ सहयोग",
                    style: GoogleFonts.amita(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 TabBar
                  TabBar(
                    labelColor: Colors.deepOrange,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.deepOrange,
                    tabs: const [
                      Tab(text: "मुख्य पृष्ठ"),
                      Tab(text: "दान"),
                      Tab(text: "इदम् न मम"),
                    ],
                  ),
                ],
              ),
            ),

            // 🔹 Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  // पहला Tab → Arth Main Page
                  ArthMainTab(
                    launchDonationPortal: _launchDonationPortal,
                    launchRazorpayButton: _launchRazorpayButton,
                  ),

                  // दूसरा Tab → Donations
                  const DonationsScreen(),

                  // तीसरा Tab → Idam Na Mam
                  const IdamNaMamScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 पहले वाले पेज का content अलग widget में shift किया गया
class ArthMainTab extends StatelessWidget {
  final Future<void> Function() launchDonationPortal;
  final Future<void> Function() launchRazorpayButton;

  const ArthMainTab({
    super.key,
    required this.launchDonationPortal,
    required this.launchRazorpayButton,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/donation.webp',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),

          // Description
          const Text(
            "यदि आप श्री संघ एवं संघ की सहयोगी संस्थाओं द्वारा संचालित विभिन्न प्रवृत्तियों हेतु आर्थिक सहयोग करना चाहते हैं तो आप ऑनलाइन बैंक द्वारा भी हस्तांतरण कर सकते हैं अथवा संघ कार्यालय में संपर्क कर सकते हैं। संघ को दिया गया अर्थ सहयोग भारतीय आयकर अधिनियम की धारा 80 G के अंतर्गत कर मुक्त है। कृपया राशि भेजने के पश्चात केंद्रीय कार्यालय को अवश्य सूचित करें।",
            style: TextStyle(fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // QR Code
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/donor_portal_qr.png',
              width: 180,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 15),

          // 🔹 Donor Portal Button
          ElevatedButton.icon(
            onPressed: launchDonationPortal,
            icon: const Icon(Icons.volunteer_activism, color: Colors.white),
            label: const Text(
              "अभी सहयोग करें",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // 🔹 Razorpay Direct Donate Button
          ElevatedButton.icon(
            onPressed: launchRazorpayButton,
            icon: const Icon(Icons.payment, color: Colors.white),
            label: const Text(
              "Donate Now Online (₹2000-/ तक )",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // 🔹 Bank Details Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    "Bank Details:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                      "👤 Account Name: Shri Akhil Bharatvarshiya Sadhumargi Jain Sangh"),
                  const Text("🏦 Bank Name: State Bank Of India (S.B.I)"),
                  const Text("💳 Account Number: 31264126861"),
                  const Text("🔑 IFSC CODE: SBIN0003401"),
                  const Text("📍 Branch Name: Gangasahar Road, Bikaner"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
