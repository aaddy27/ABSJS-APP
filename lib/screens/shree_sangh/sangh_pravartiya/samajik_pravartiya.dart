import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SamajikPravartiyaScreen extends StatefulWidget {
  const SamajikPravartiyaScreen({super.key});

  @override
  State<SamajikPravartiyaScreen> createState() => _SamajikPravartiyaScreenState();
}

class _SamajikPravartiyaScreenState extends State<SamajikPravartiyaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<dynamic>> _apiData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _apiData = fetchUtkraantiAbhiyanData();
  }

  Future<List<dynamic>> fetchUtkraantiAbhiyanData() async {
    final response = await http.get(Uri.parse("https://example.com/api/utkraanti"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("डेटा लोड करने में समस्या हुई");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelStyle: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.hindSiliguri(fontSize: 16),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepOrange,
            tabs: const [
              Tab(
                child: SizedBox(
                  width: 180,
                  child: Text(
                    'समता जनकल्याण प्रन्यास',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Tab(
                child: SizedBox(
                  width: 220,
                  child: Text(
                    'भगवान महावीर समता चिकित्सालय',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Tab(
                child: SizedBox(
                  width: 160,
                  child: Text(
                    'नानेश चिकित्सालय',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              // Tab(
              //   child: SizedBox(
              //     width: 160,
              //     child: Text(
              //       'उत्क्रान्ति अभियान',
              //       textAlign: TextAlign.center,
              //       maxLines: 2,
              //       overflow: TextOverflow.visible,
              //     ),
              //   ),
              // ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1 - Improved UI
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Heading
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.deepOrange, Colors.orangeAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'समता जनकल्याण प्रन्यास',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Content Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'सामान्य बीमारियों हेतु अल्प व्यय का सहयोग तो व्यक्ति विशेष द्वारा भी किया जाना संभव है किन्तु गंभीर, असाध्य एवं व्यापक धन व्यय का सहयोग देना व्यक्ति विशेष से आगे बढकर संघ और संगठन पर आधारित हो जाता है। इसी दृष्टि को ध्यान में रखकर गंभीर असाध्य बीमारियों से ग्रसित सर्वधर्मी बन्धुओं को सहयोग देने हेतु संघ द्वारा श्री समता जनकल्याण प्रन्यास की स्थापना की गई है। सर्वधर्मी भाई-बहिन किसी असाध्य बीमारी से ग्रसित हो, जिसका ईलाज अत्यंत खर्चीला होने से वे वहन करने में असमर्थ हों तो उनकी सहायता समता जनकल्याण प्रन्यास द्वारा की जाती है। पूर्व में इसके ईलाज की राशि की सीमा 50,000/- थी, जिसे बढाकर 1,25,000/- कर दिया गया है। इस सहायता के लिये क्षेत्रीय पदाधिकारी की अनुशंसा बहुत जरूरी है। ड्राफ्ट सीधा अस्पताल के नाम से ही भेजा जायेगा। संघ का मानना है कि अपनी उन्नति एवं प्रगति के लिये सभी तत्पर रहते हैं किन्तु समाज के प्रति भी हमारा एक दायित्व है, जिन्हें हमें पूर्ण करना होगा। उन्हें पूर्ण किये बगैर हम मनुष्यता के ऋण से उऋण नही हो सकते। इस हेतु समता जनकल्याण प्रन्यास में अपनी अर्जित राशि को भेंट करने हेतु 1,100/-, 2,100/-, 3,100/-, 5,100/-, 11,000/-, 21,000/-, 31,000/- व 51,000/- राशि के कूपन उपलब्ध है। कोई भी महानुभाव अपनी यथाशक्ति मानव कल्याण के इस महायज्ञ में अपनी आहुति दे सकता है।',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

 SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Heading
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.deepOrange, Colors.orangeAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'भगवान महावीर समता चिकित्सालय, डोंडीलोहारा',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Content Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'देशभर में फैले श्रीसंघों और क्षेत्रीय संघों द्वारा लोक सेवा के कार्य संपादित किये जाते हैं। कभी-कभी किसी विशिष्ट सेवा प्रवृत्ति में सतत और समर्पित सेवा कार्यों की शृंखला एक स्थायी स्वरूप ग्रहण कर लेती है। छत्तीसगढ़ क्षेत्र के कार्यकर्ताओं के समर्पित चिकित्सा सेवा के विकास का नाम है ‘भगवान महावीर समता चिकित्सालय’ डोंडीलोहारा। आदिवासी बाहुल्य क्षेत्र में इस चिकित्सालय की स्थापना 20 फरवरी, 1999 को हुई तथा इसका शुभारंभ 22 फरवरी, 2004 को किया गया। तब से लेकर आज तक इस चिकित्सालय ने चिकित्सा जगत् में अनेक आयाम स्थापित किये हैं। चिकित्सालय में वॉर्मर मशीन, एक्स-रे, पैथोलॉजी लैब, प्रसूति-गृह, ऑपरेशन थियेटर, भोजानालय, जल मंदिर आदि है।',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // TAB 3
               SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Heading
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepOrange, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            'नानेश चिकित्सालय, रतलाम',
            style: GoogleFonts.hindSiliguri(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),

      const SizedBox(height: 20),

      // Image
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/nanesh-chiktsalay.jpg',
          fit: BoxFit.cover,
        ),
      ),

      const SizedBox(height: 20),

      // Content Card
      Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'नानेश चिकित्सलाय, रतलाम : संघ के चिकित्सा एवं आरोग्य प्रवृत्तियों की शृंखला में नानेश चिकित्सालय, रतलाम एक अभिनव कड़ी है। '
            'धर्मपाल बंधुओं एवं अन्य जनों के सेवार्थ तथा उपचारार्थ नानेश निकेतन परिसर रतलाम में नानेश चिकित्सालय का शुभारंभ 10 जनवरी 2016 को किया गया। '
            'यह सेवा प्रकल्प तात्कालिक सफलता व जनप्रियता हासिल कर चुका है। उपचार के साथ साथ निःशुल्क औषध की भी सेवा मरीजों का उपलब्ध कराई जाती है।',
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    ],
  ),
),
                // TAB 4 - API Data
                // FutureBuilder<List<dynamic>>(
                //   future: _apiData,
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return const Center(child: CircularProgressIndicator());
                //     } else if (snapshot.hasError) {
                //       return Center(child: Text("त्रुटि: ${snapshot.error}"));
                //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                //       return const Center(child: Text("कोई डेटा उपलब्ध नहीं है"));
                //     }
                //     final data = snapshot.data!;
                //     return ListView.builder(
                //       padding: const EdgeInsets.all(16),
                //       itemCount: data.length,
                //       itemBuilder: (context, index) {
                //         return Card(
                //           margin: const EdgeInsets.only(bottom: 12),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           elevation: 3,
                //           child: Padding(
                //             padding: const EdgeInsets.all(12.0),
                //             child: Text(
                //               data[index]['title'] ?? 'Untitled',
                //               style: GoogleFonts.hindSiliguri(fontSize: 16),
                //             ),
                //           ),
                //         );
                //       },
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
