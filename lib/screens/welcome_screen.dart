import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E3A8A);

  Future<void> _launchELForm() async {
    final Uri url = Uri.parse(
      'https://website.sadhumargi.in/storage/aavedan_patra/1754901997_8oHPl89Bm9.pdf',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('❌ Could not launch $url');
    }
  }

  Future<void> _openWhatsApp() async {
    // ✅ direct WhatsApp chat (fallback: tel:)
    final Uri wa = Uri.parse('https://wa.me/916265311663');
    if (!await launchUrl(wa, mode: LaunchMode.externalApplication)) {
      final Uri tel = Uri.parse('tel:+916265311663');
      await launchUrl(tel, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double logoSize = math.max(
              100.0,
              math.min(180.0, constraints.maxWidth * 0.25),
            );

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
                      SizedBox(height: constraints.maxHeight * 0.02),
                      Image.asset('assets/logo.png', height: logoSize),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        'श्री अखिल भारतवर्षीय साधुमार्गी जैन संघ',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: constraints.maxWidth < 360 ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          color: primaryBlue,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info Card
                      Card(
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            children: const [
                              _BulletTile(
                                text: '1. यहाँ आप केवल अपनी MID के माध्यम से ही लॉगिन कर सकते हैं।',
                              ),
                              Divider(height: 0),
                              _BulletTile(
                                text: '2. यदि आपके पास MID नहीं है, तो कृपया केंद्रीय कार्यालय से संपर्क करें।',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Notice Card
                      Card(
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'यदि आप कोई नया परिवार जोड़ना चाहते हैं, तो कृपया नीचे दिए गए फॉर्म को डाउनलोड करके भरें और स्थानीय अध्यक्ष-मंत्री से हस्ताक्षर करवाकर इस नंबर पर व्हाट्सएप करें:',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
  borderRadius: BorderRadius.circular(8),
  onTap: _openWhatsApp,
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: primaryBlue.withOpacity(0.06),
      border: Border.all(color: primaryBlue.withOpacity(0.15)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(FontAwesomeIcons.whatsapp, color: Colors.green), // ✅ FIXED
        SizedBox(width: 8),
        Text(
          '6265311663',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.green,
          ),
        ),
      ],
    ),
  ),
),

                              const SizedBox(height: 10),

                              // Download Button
                              OutlinedButton.icon(
                                onPressed: _launchELForm,
                                icon: const Icon(Icons.download),
                                label: const Text('Global Card फॉर्म डाउनलोड करें'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryBlue,
                                  side: const BorderSide(color: primaryBlue, width: 1.2),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Proceed Button
                      SizedBox(
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
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.02),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BulletTile extends StatelessWidget {
  const _BulletTile({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 15.5,
          color: Colors.black87,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
