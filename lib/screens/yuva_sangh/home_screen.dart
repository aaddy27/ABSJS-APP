import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class YuvaHomeScreen extends StatefulWidget {
  const YuvaHomeScreen({super.key});

  @override
  State<YuvaHomeScreen> createState() => _YuvaHomeScreenState();
}

class _YuvaHomeScreenState extends State<YuvaHomeScreen> {
  final PageController _pageController = PageController();
  int _current = 0;
  List<String> _sliderImages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchSliderImages();
  }

  Future<void> fetchSliderImages() async {
    try {
      final response =
          await http.get(Uri.parse("https://website.sadhumargi.in/api/yuva-slider"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<String> images = (data as List)
            .map((item) => "https://website.sadhumargi.in${item['image']}")
            .toList();
        setState(() {
          _sliderImages = images;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_sliderImages.length, (i) {
        final active = i == _current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 20 : 8,
          decoration: BoxDecoration(
            color: active ? Colors.brown : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        const SizedBox(height: 12),

        // Slider
        SizedBox(
          height: 200,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : (_sliderImages.isEmpty)
                  ? const Center(child: Text("No slider images available"))
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: _sliderImages.length,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemBuilder: (_, index) {
                        final img = _sliderImages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              img,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stack) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),

        const SizedBox(height: 10),
        if (_sliderImages.isNotEmpty) _buildDots(),
        const SizedBox(height: 24),

        // नीचे text (image की जगह)
       // नीचे text (image की जगह)
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.brown.shade200, width: 1),
    ),
    color: Colors.brown.shade50,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '''सन 1979 - अजमेर (राज.) :- समता की प्रतिमूर्ति समीक्षण ध्यान योगी परम पूज्य आचार्य प्रवर 1008 श्री नानालाल जी म. सा. के चातुर्मास में "समता - स्वाध्याय- सेवा" इन मूल मन्त्रों को लेकर साधुमार्गी युवाओं के संघठन की स्थापना की गई जिसे नाम दिया गया

"श्री अखिल भारतवर्षीय साधुमार्गी जैन समता युवा संघ"

पुरे राष्ट्र एवं विदेशों में फैलें साधुमार्गी परिवारों के युवाओं को अपने साथ संजोते हुए यह संघठन धीरे-धीरे विशाल रूप लेता गया पूज्य गुरु भगवंतों की असीम कृपा एवं समय-समय पर युवा नेतृत्वकर्ताओं ने, कार्यकर्ताओं ने अपने पुरुषार्थ से इसे संवारा आगे बढाया ।

समता युवा संघ श्री अ.भा.सा. जैन संघ की एक शाखा के रूप में है।

आज पुरे राष्ट्र में 200 शाखाओं एवं 5000 से अधिक युवा सदस्यों के साथ कार्यरत हैं आचार्य भगवन द्वारा दिए गये आयामों संघ की विभिन्न प्रवृत्तियों आदि की प्रभावना करने के साथ साथ युवा साथियों के व्यक्तित्त्व विकास, धार्मिक विकास ऊर्जा को बढ़ाने हेतु भी निरंतर कार्यरत हैं।

युवा साथियों के साथ में तरुण युवाओं (12 से 18 वर्ष) हेतु भी कई आयोजन करते हुए उनमे धार्मिक विकास हेतु भी कार्यरत हैं।''',
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
        textAlign: TextAlign.justify,
      ),
    ),
  ),
),

      ],
    );
  }
}
