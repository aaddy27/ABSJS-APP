import 'dart:math';
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

  // Show full image from asset at exact 344x495 inside a dialog
  void _showFullImageAsset(BuildContext context, String assetPath, {String? title}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row with optional title and close button
            Row(
              children: [
                if (title != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        title,
                        style: GoogleFonts.kalam(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            // The image with exact requested dimensions (344 x 495)
            SizedBox(
              width: 344,
              height: 495,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain, // contain => show whole image, no crop
                  errorBuilder: (ctx, err, stack) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 48),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 🔹 अब 3 tabs होंगे
      child: BaseScaffold(
        selectedIndex: -1,
        body: SafeArea(
          child: Column(
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
                      onShowFullImage: (asset, title) => _showFullImageAsset(context, asset, title: title),
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
      ),
    );
  }
}

// 🔹 पहले वाले पेज का content अलग widget में shift किया गया
class ArthMainTab extends StatelessWidget {
  final Future<void> Function() launchDonationPortal;
  final Future<void> Function() launchRazorpayButton;
  final void Function(String assetPath, String? title) onShowFullImage;

  const ArthMainTab({
    super.key,
    required this.launchDonationPortal,
    required this.launchRazorpayButton,
    required this.onShowFullImage,
  });

  @override
  Widget build(BuildContext context) {
    // responsive inline QR size: up to 344 but keep comfortable for small screens
    final mq = MediaQuery.of(context);
    final double maxAvailableWidth = mq.size.width - 48; // padding considered
    final double qrInlineSize = min(344, maxAvailableWidth * 0.7); // responsive; <=344

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Banner Image (tappable -> full 344x495)
          GestureDetector(
            onTap: () => onShowFullImage('assets/images/donation.webp', 'Donation Banner'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/donation.webp',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 160, // compact banner visible in page
                errorBuilder: (ctx, err, st) => Container(
                  width: double.infinity,
                  height: 160,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
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

          // QR Code (tappable -> full 344x495)
          // IMPORTANT: use BoxFit.contain and a white background with border so QR is never cropped
          GestureDetector(
            onTap: () => onShowFullImage('assets/images/sbinew.JPG', 'QR Code'),
            child: Center(
              child: Container(
                width: qrInlineSize,
                height: qrInlineSize, // keep square for QR
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white, // keep white background so QR contrast is preserved
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/sbinew.JPG',
                    fit: BoxFit.contain, // contain ensures full QR visible (no crop)
                    width: qrInlineSize,
                    height: qrInlineSize,
                    errorBuilder: (ctx, err, st) => Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
              ),
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
                  const Text(" लेखा विभाग केन्द्रीय कार्यालय बीकानेर 7073311108, accounts@sadhumargi.com"),
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
