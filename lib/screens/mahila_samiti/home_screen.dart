import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

class MahilaHomeScreen extends StatefulWidget {
  const MahilaHomeScreen({super.key});

  @override
  State<MahilaHomeScreen> createState() => _MahilaHomeScreenState();
}

class _MahilaHomeScreenState extends State<MahilaHomeScreen> {
  List<String> sliderImages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSliderImages();
  }

  Future<void> fetchSliderImages() async {
    try {
      final response = await http.get(
        Uri.parse("https://website.sadhumargi.in/api/mahila-slider"),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        setState(() {
          sliderImages = data
              .map((item) => "https://website.sadhumargi.in${item['photo']}")
              .toList()
              .cast<String>();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

@override
Widget build(BuildContext context) {
  return SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50), // 🔹 नीचे padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            /// 🔹 Slider
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : sliderImages.isEmpty
                    ? const Text("कोई स्लाइडर उपलब्ध नहीं है")
                    : CarouselSlider(
                        options: CarouselOptions(
                          height: 200,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                          aspectRatio: 16 / 9,
                          autoPlayInterval: const Duration(seconds: 3),
                        ),
                        items: sliderImages.map((imageUrl) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        }).toList(),
                      ),

            const SizedBox(height: 30),

            /// 🔹 Intro Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    "परिचय",
                    style: GoogleFonts.amita(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    ".श्री अ.भा.सा. जैन महिला समिति, बीकानेर नारी विकास, उत्थान हेतु पिछले कई वर्षों से महत्त्वपूर्ण भूमिका निभा रही है। भारतवर्ष के लगभग 300 से अधिक स्थानों पर महिला समिति की शाखाओं द्वारा धार्मिक एवं सामाजिक अनेक प्रकल्पों का संचालन किया जा रहा है। निश्चित रूप से महिला समिति द्वारा किये जा रहे कार्य नारी विकास का एक महत्त्वपूर्ण केन्द्र है। समिति की कार्य रूपरेखा में प्रमुख रूप से आध्यात्मिक उत्थान के लिए धार्मिक प्रवृत्तियों को संचालित करना है। नैतिक धार्मिक एवं व्यावहारिक शिक्षा का प्रचार एवं प्रसार करना। सामाजिक कुरीतियों के निवारण का प्रयत्न करना। संघ की प्रवृत्तियों को सहयोग देना एवं उनको उन्नत बनाने का प्रयत्न करना। जीवदया के कार्यों के लिये प्रयत्न करना आदि प्रमुख है। वर्तमान में श्री अ.भा.सा. जैन महिला समिति द्वारा समता छात्रवृत्ति, सर्वधर्मी सहयोग, संगठन, युवती शक्ति, केसरिया कार्यशाला, वुमनस मोटिवेशनल फोरम, परिवारांजलि आदि प्रमुख है। महिला समिति की सर्वधर्मी योजना में वर्तमान में लगभग 218 परिवार एवं समता छात्रवृत्ति योजना में लगभग 278 छात्र-छात्राएं लाभान्वित हो रहे हैं। इस योजना में महिला समिति द्वारा शारीरिक रूप से निःशक्त एवं वृद्धजनों को सहयोग प्रदान किया जाता है। संस्था का वार्षिक अधिवेशन प्रतिवर्ष आसोज शुक्ल तृतीया को आयोजित किया जाता है",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

}