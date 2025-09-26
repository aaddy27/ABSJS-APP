import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'base_scaffold.dart';

class SamparkScreen extends StatelessWidget {
  const SamparkScreen({super.key});

  // ------------------ Launch Helpers ------------------
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri url = Uri.parse("https://wa.me/91$phoneNumber");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // ------------------ Card Builders ------------------
  Widget _buildCard(String title, String phone, [String? email, bool isWhatsApp = false]) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.indigo.shade900,
              ),
            ),
            const SizedBox(height: 10),

            // Phone / WhatsApp
            if (isWhatsApp)
              InkWell(
                onTap: () => _launchWhatsApp(phone),
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      phone,
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              InkWell(
                onTap: () => _launchPhone(phone),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      phone,
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 6),

            if (email != null)
              InkWell(
                onTap: () => _launchEmail(email),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        email,
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard(String title, String address, {String? phone, String? email}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 6),
            Text("📍 $address", style: GoogleFonts.roboto(fontSize: 14, color: Colors.black87)),
            if (phone != null) ...[
              const SizedBox(height: 4),
              Text("📞 $phone", style: GoogleFonts.roboto(fontSize: 14, color: Colors.blueGrey)),
            ],
            if (email != null) ...[
              const SizedBox(height: 4),
              Text("✉️ $email", style: GoogleFonts.roboto(fontSize: 14, color: Colors.redAccent)),
            ],
          ],
        ),
      ),
    );
  }

  // ------------------ Build ------------------
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.indigo.shade50,
              child: TabBar(
                labelStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                labelColor: Colors.indigo,
                indicatorColor: Colors.indigo,
                tabs: const [
                  Tab(text: "मुख्य संपर्क"),
                  Tab(text: "अन्य प्रवर्तिया कार्यालय"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ---------- First Tab ----------
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Extra Address Card on Top
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 5,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "केंद्रीय कार्यालय",
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.indigo.shade900,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "पता: समता भवन, आचार्य श्री नानेश मार्ग, नोखा रोड, गंगाशहर, बीकानेर – 334401, राजस्थान, भारत",
                                  style: GoogleFonts.roboto(fontSize: 15),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => _launchPhone("01512270261"),
                                  child: Text("फोन: +91 151 2270261",
                                      style: GoogleFonts.roboto(fontSize: 15, color: Colors.blue)),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => _launchEmail("ho@sadhumargi.com"),
                                  child: Text("ईमेल: ho@sadhumargi.com",
                                      style: GoogleFonts.roboto(fontSize: 15, color: Colors.red)),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Existing Cards
                        _buildCard("केंद्रीय कार्यालय लेखा विभाग", "7073311108", "accounts@sadhumargi.com"),
                        _buildCard("श्रमणोपासक", "9799061990", "news@sadhumargi.com"),
                        _buildCard("श्रमणोपासक समाचार", "8955682153", "news@sadhumargi.com"),
                        _buildCard("साहित्य", "8209090748", "sahitya@sadhumargi.com"),
                        _buildCard("महिला समिति", "6375633109", "ms@sadhumargi.com"),
                        _buildCard("समता युवा संघ", "7073238777", "yuva@sadhumargi.com"),
                        _buildCard("धार्मिक परीक्षा", "7231933008", "examboard@sadhumargi.com"),
                        _buildCard("कर्म सिद्धांत", "7976519363"),
                        _buildCard("परिवारांजलि", "7231033008", "anjali@sadhumargi.com"),
                        _buildCard("विहार", "8505053113", "vihar@sadhumargi.com"),
                        _buildCard("पाठशाला", "9982990507", "pathshala@sadhumargi.com"),
                        _buildCard("शिविर", "7231833008", "udaipur@sadhumargi.com"),
                        _buildCard("ग्लोबल कार्ड अपडेट्स", "6265311663", "globalcard@sadhumargi.com"),
                        _buildCard("अन्य प्रवृत्तियाँ", "9602026899"),
                        _buildCard("साहित्य संबंधित प्रवृत्तियाँ", "7231933008"),
                        _buildCard("संघ हेल्पलाइन (WhatsApp only)", "8535858853", null, true),
                      ],
                    ),
                  ),

                  // ---------- Second Tab ----------
                  GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: 2.1,
                    children: [
                      _buildSmallCard(
                        "समता प्रचार संघ द्वारा – आचार्य श्री नानेश ध्यान केंद्र",
                        "राणाप्रताप नगर, पद्मिनी मार्ग, सुन्दरवास पो. उदयपुर (राज.)",
                        phone: "0294-2490717 (ऑ./फैक्स)",
                        email: "asndkudaipur@gmail.com",
                      ),
                      _buildSmallCard(
                        "श्री गणेश जैन छात्रावास",
                        "राणाप्रताप नगर, पद्मिनी मार्ग, सुन्दरवास पो. उदयपुर (राज.)",
                        phone: "0294-2494375 (ऑ./फैक्स)",
                      ),
                      _buildSmallCard(
                        "श्री गणेश जैन ज्ञान भंडार",
                        "समता भवन, नौलाईपुरा पो. रतलाम – 457001 (म.प्र.)",
                        phone: "07412-244443 (ऑ.)",
                        email: "rmgorecha@gmail.com",
                      ),
                      _buildSmallCard(
                        "श्री प्रेमराज गणपतराज बोहरा धर्मपाल जैन छात्रावास",
                        "नानेश निकेतन, दिलीपनगर पो. रतलाम – (म.प्र.)",
                        phone: "07412-267212 (ऑ.)",
                        email: "naneshniketanrtm@gmail.com",
                      ),
                      _buildSmallCard(
                        "भगवान महावीर समता चिकित्सालय",
                        "पो. डोंडीलोहारा, जि. दुर्ग – 491771 (छ.ग.)",
                        phone: "07749-264054 (ऑ.)",
                        email: "asndkudaipur@gmail.com",
                      ),
                      _buildSmallCard(
                        "आगम, अहिंसा-समता एवं प्राकृत संस्थान द्वारा – आचार्य श्री नानेश ध्यान केंद्र",
                        "राणाप्रताप नगर, पद्मिनी मार्ग, पो. उदयपुर (राज.)",
                        phone: "0294-2490717 (ऑ.)",
                        email: "asndkudaipur@gmail.com",
                      ),
                      _buildSmallCard(
                        "श्री आदिनाथ पशु रक्षा संस्थान",
                        "पो. कानोड़, जि. उदयपुर – 313604 (राज.)",
                        phone: "9460726890",
                      ),
                      _buildSmallCard("समता महिला सेवा केंद्र", "पो. रतलाम (म.प्र.)", phone: "07412-238696"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
