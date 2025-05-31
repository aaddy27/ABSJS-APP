import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _launchELForm() async {
    final Uri url = Uri.parse('https://sadhumargi.com/wp-content/uploads/2024/02/Global-Card-_-Form.pdf');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('❌ Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 140,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'श्री अखिल भारतवर्षीय साधुमार्गी जैन संघ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('1. यहाँ आप केवल अपनी MID के माध्यम से ही लॉगिन कर सकते हैं।'),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('2. यदि आपके पास MID नहीं है, तो कृपया केंद्रीय कार्यालय से संपर्क करें।'),
                  ),
                  ],
              ),
            ),
            const Spacer(),

            // ✅ सूचना मैसेज
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                'यदि आप कोई नया परिवार जोड़ना चाहते हैं, तो कृपया नीचे दिए गए फॉर्म को डाउनलोड करके भरें और स्थानीय अध्यक्ष-मंत्री से हस्ताक्षर करवाकर इस नंबर पर व्हाट्सएप करें: 6265311663',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ✅ DOWNLOAD BUTTON
            TextButton.icon(
              onPressed: _launchELForm,
              icon: const Icon(Icons.download, color: Colors.deepPurple),
              label: const Text(
                'Global Card फॉर्म डाउनलोड करें',
                style: TextStyle(color: Colors.deepPurple, fontSize: 16),
              ),
            ),

            const SizedBox(height: 10),

            // ✅ आगे बढ़ें बटन
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                 label: const Text(
  'आगे बढ़ें',
  style: TextStyle(
    fontSize: 20,
    color: Colors.white,
  ),
),
                 style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color.fromARGB(255, 101, 11, 161),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
