import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../base_scaffold.dart';

class DharmikPravartiyaScreen extends StatefulWidget {
  const DharmikPravartiyaScreen({super.key});

  @override
  State<DharmikPravartiyaScreen> createState() =>
      _DharmikPravartiyaScreenState();
}

class _DharmikPravartiyaScreenState extends State<DharmikPravartiyaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabTitles = [
    'समता संस्कार पाठशाला',
    'श्री समता प्रचार संघ',
    'समता संस्कार शिविर',
  ];

  final List<String> tabContents = [
    '''
आत्मिक विकास हेतु नियमित ध्यान और साधना की विधियाँ।
''',
    '''
इस प्रवृत्ति का उद्भव समता विभूति परम श्रद्धेय स्व. आचार्य श्री नानालाल जी म.सा. की सद्प्रेरणा से उदयपुर में सन् 1978 में हुआ। प्रवृत्ति का उद्देश्य समता सिद्धांत को जन-जन तक पहुंचाने का है। पर्युषण पर्व पर जहां चारित्र आत्माएं नहीं पहुंच पाती है; वहां स्वाध्यायी जाकर आठ दिन सेवा देते है। स्वाध्यायियों को तैयार करने के लिए समय-समय पर स्वाध्यायी प्रशिक्षण शिविरों का आयोजन करना, पयुर्षण पर्वाराधना के पावन प्रसंग पर अधिकाधिक क्षेत्रों में धर्माराधना करवाना, इस प्रवृत्ति का मुख्य उद्देश्य है। समता प्रचार संघ के माध्यम से प्रतिवर्ष लगभग 550 स्वाध्यायी 174 से अधिक स्थलों पर स्वाध्यायी सेवा देते है। वर्ष 2024 में होली चातुर्मास के उपलक्ष्य में पहली बार ‘फाल्गुनी पर्व’ आराधना के रुप में पूरे देशभर में 11,111 संवर/पौषध/दया करने का लक्ष्य रखा गया, जिसमें सभी श्रावक-श्राविकाओं की सक्रिय सहभागिता रही।
''',
    '''
संघ द्वारा बालक-बालिकाओं के चारित्र निर्माण हेतु प्रतिवर्ष सम्पूर्ण देश में क्षेत्रीय एवं स्थानीय समता संस्कार शिविरों का आयोजन किया जाता है। इन शिविरों के माध्यम से बालक-बालिकाओं को जैन धर्म का प्रारम्भिक ज्ञान कराया जाता है। साथ ही उन्हें व्यसनमुक्त एवं संस्कारयुक्त जीवन जीने की विशेष प्रेरणा दी जाती है। प्रतिवर्ष लगभग 3 से 4 हजार बालक-बालिकाएँ समता संस्कार शिविरों में भाग लेते हैं। समय-समय पर आयोजित संस्कार शिविरों में संघ की Know & Grow परियोजना के अनुसार, प्रतिभागियों को विभिन्न जीवन मूल्यों का ज्ञान दिया जाता है। शिविर में आयोजित प्रतियोगिताओं में विजेता प्रतिभागियों को पुरस्कार देकर अर्जित ज्ञान को व्यवहार में अपनाने हेतु प्रेरित किया जाता है।
''',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabTitles.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget buildTab(int index, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                colors: [Color(0xFF5B3FFF), Color(0xFF7A4FFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFEDE7F6), Color(0xFFE3F2FD)],
              ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Text(
        tabTitles[index],
        style: GoogleFonts.hindSiliguri(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : Colors.indigo.shade900,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: -1,
      body: SafeArea(
        child: Column(
          children: [
            // Top Tab Bar
            SizedBox(
              height: 80,
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  return TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    isScrollable: true,
                    tabs: List.generate(
                      tabTitles.length,
                      (index) {
                        final selected = _tabController.index == index;
                        return Tab(
                          child: buildTab(index, selected),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Content Area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(
                  tabContents.length,
                  (index) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: SingleChildScrollView(
                      key: ValueKey(index),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 25),
                      child: Card(
                        elevation: 6,
                        shadowColor: Colors.indigo.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Heading
                              Text(
                                tabTitles[index],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 2,
                                width: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.indigo.shade400,
                                      Colors.deepPurple.shade400
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Content
                              Text(
                                tabContents[index],
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
