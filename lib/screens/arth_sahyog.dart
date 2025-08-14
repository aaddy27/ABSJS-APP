import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'base_scaffold.dart';

class ArthSahyogScreen extends StatelessWidget {
  const ArthSahyogScreen({super.key});

  // URL Launch Function
  Future<void> _launchDonationPortal() async {
    const url = "https://donorportal.sadhumargi.com/login";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: 0,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Heading with Amita font
            Text(
              "अर्थ सहयोग",
              style: GoogleFonts.amita(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Banner / Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/donation.webp',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Content Text
            const Text(
              "संघ में आपके सहयोग व सदस्यता की सम्पूर्ण जानकारी प्राप्त करने व "
              "ऑनलाइन भुगतान हेतु नीचे दिए लिंक पर क्लिक करें।\n\n"
              "आपका छोटा सा योगदान भी समाज में बड़ा बदलाव ला सकता है। "
              "आपका हर सहयोग हमें शिक्षा, सेवा, और संस्कार के कार्यों को आगे बढ़ाने में मदद करता है।",
              style: TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // QR Code
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/donor_portal_qr.png', // आपका QR इमेज पाथ
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 15),

            // Donation Button
            ElevatedButton.icon(
              onPressed: _launchDonationPortal,
              icon: const Icon(Icons.volunteer_activism, color: Colors.white),
              label: const Text(
                "अभी सहयोग करें",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
