import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

class SanghSamridhiYojnaScreen extends StatefulWidget {
  const SanghSamridhiYojnaScreen({super.key});

  @override
  State<SanghSamridhiYojnaScreen> createState() =>
      _SanghSamridhiYojnaScreenState();
}

class _SanghSamridhiYojnaScreenState extends State<SanghSamridhiYojnaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget buildTabContent({
    required String title,
    String? imagePath,
    String? extraHeading,
    String? extraContent,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             if (imagePath != null) ...[
  ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Stack(
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover, // Image ko card ke andar crop-fit karega
          width: double.infinity,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
  const SizedBox(height: 16),
],

              Text(
                title,
                textAlign: TextAlign.justify,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              if (extraHeading != null && extraContent != null) ...[
                const SizedBox(height: 20),
                Divider(color: Colors.orange.shade300, thickness: 1),
                const SizedBox(height: 8),
                Text(
                  extraHeading,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  extraContent,
                  textAlign: TextAlign.justify,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 233, 213, 207), Color.fromARGB(255, 226, 225, 223)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color.fromARGB(255, 0, 0, 0), // creamish
              unselectedLabelColor: const Color.fromARGB(179, 0, 0, 0),
              labelStyle:
                  GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
              indicatorColor: const Color.fromARGB(255, 177, 33, 33),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'दानपेटी योजना'),
                Tab(text: 'संघ सदस्यता अभियान'),
                Tab(text: 'इदं न मम'),
                Tab(text: 'समता मिति योजना'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1
                buildTabContent(
                  title:
                      'श्री अखिल भारतवर्षीय साधुमार्गी जैन संघ की समस्त प्रवृत्तियों में समाज जन की सहभागिता सुलभ हो इस हेतु राष्ट्रीय संघ द्वारा दान पेटी योजना संचालित है | संघ के सभी परिवार प्रतिदिन अपना अंशदान देकर संघ द्वारा संचालित सेवा परोपकार जैसी प्रवृत्तियां हेतु अपना सहयोग प्रदान करते हैं | दान पेटी योजना पुण्यशालियों को प्रतिदिन सहज दान का अवसर प्रदान करती है |दान करने से दाता के मन में हर्ष व आत्मा में संतोष प्राप्त होता है इस योजना का मुख्य उद्देश्य नियमित दान अर्पण करना है , परिवार में मनाया जाने वाले प्रत्येक विशेष दिवस की शुरुआत दान से होना चाहिए ताकि परिवार में विशेषकर बच्चों में दान की भावना का विकास हो एवं सभी का केंद्रीय संघ के प्रति समर्पित भाव बढ़े | दान के उच्च भाव मोक्ष मार्ग में सहयोगी है|',
                  imagePath: 'assets/images/daanpeti-logo.jpg',
                  extraHeading: 'दानपेटी योजना से जुड़ें',
                  extraContent:
                      'इस हेतु प्रत्येक संघ में दान पेटी खरीद कर लगाई गई है एवं अध्यक्ष मंत्री व दान पेटी योजना प्रभारी के निर्देशन में साल में एक बार दान पेटी से राशि को इकट्ठा कर प्राप्त राशि का 60% केंद्रीय कार्यालय एवं 40% प्रतिशत स्थानीय संघ में उपयोग में लिया जाता है| '
                      'कई संघ पूरी राशि भी केंद्र में जमा करवा कर अपनी सहभागिता निभाते हैं जो की सम्माननीय है। '
                      'दान पेटी की सहयोग राशि जमा करवाते समय अपने विवरण के साथ मोबाइल नंबर देना होता हैं और रसीद प्राप्त की जाती है। '
                      'दान पेटी योजना का बैनर प्रत्येक स्थानक भवन, प्रवचन स्थल आदि में लगाया जाता है एवं सार्वजनिक कार्यक्रमों में दान पेटी के मूल उद्देश्यों को समझाते हुए प्रभावना की जाती है। '
                      'देश भर के अधिकांश संघों में दान पेटी योजना संचालित है। '
                      'संघ के तीनों इकाई के कोई भी जिम्मेदार व्यक्ति इस कार्य में अपना सहयोग प्रदान कर सकते हैं। '
                      'सर्वश्रेष्ठ अंचल एवं सर्वाधिक राशि जमा करने वाले प्रथम, द्वितीय और तृतीय संघ को अधिवेशन में सम्मानित किया जाता है।',
                ),

                // Tab 2
                buildTabContent(
                  title: 'संघ प्रभावक एवं शिखर सदस्यता अभियान के साथ ही संघ के आजीवन सदस्य, साहित्य सदस्य एवं श्रमणोपासक सदस्य आदि में उत्तरोत्तर अभिवृद्धि हो रही है ।',
                  imagePath: null,
                ),

                // Tab 3
                buildTabContent(
                  title: 'श्री अ.भ.सा. जैन संघ की विभिन्न प्रवृत्तियों के सुचारु सञ्चालन हेतु एक अभिनव प्रतिबद्धता की मिसाल एवं अर्थ सौजन्य का माध्यम प्रस्तावित हुआ है। दानदाताओं ने अपनी आय का निर्धारित भाग आजीवन नियमित रूप से संघ को समर्पित करने का संकल्प लिया है । इस समर्पण भाव की अभिव्यक्ति को ‘इदं न मम’ (यह मेरा नहीं हैं) के रूप में साकार किया गया है। यह उपक्रम अक्टूबर 2015 को संघ समर्पणा महोत्सव के शुभ दिन प्रारम्भ किया गया।',
                  imagePath: 'assets/images/idam_namam.jpg',
                ),

                // Tab 4
                buildTabContent(
                  title: 'श्री प्रेमराज गणपतराज बोहरा धर्मपाल जैन छात्रावास में अध्ययनरत छात्रों की समुचित व्यवस्था हेतु वर्ष 2012 में समता मिति योजना की मंगल शुरुआत की गई है। इसके अन्तर्गत कोई भी दानदाता किसी भी अवसर पर यथा पुण्यतिथि, जन्मतिथि, विवाह तिथि, तपस्या तिथि, तथा अन्य विशेष तिथियों को चिरस्मरणीय बनाने हेतु आर्थिक सहयोग प्रदान कर सकता है। इस सहयोग से 15 वर्षों तक निर्धारित तिथि पर उनकी ओर से नाश्ता, भोजन आदि प्रदान किया जायेगा, साथ ही मंगलाचरण, श्रद्धांजलि, बधाई, शुभकामनाएँ आदि संदेश छात्रावास सूचना-पट्ट पर अंकित की जाएंगी तथा छात्रों के बीच भी सम्प्रेषित की जाएंगी।'
                  'प्राप्त करने की विधि : इसके अन्तर्गत कोई भी दानदाता किसी भी विशिष्ट अवसर पर 5000/- रुपये एक मुश्त प्रदान कर सकता है। इस योजना की राशि सावधि जमा खाते में जमा रहेगी। निर्धारित तिथि से पूर्व इसकी सूचना संबंधित महानुभाव को दी जाएगी।'
                  '31 अक्टूबर 2024 तक समता मिति के अन्तर्गत 2580 सदस्यों ने अपनी सहभागिता स्वरुप अनुदान प्रदान किया है।',
                  imagePath: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
