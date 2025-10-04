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
  
  // लोडिंग स्टेट्स
  bool _loadingSlider = true;
  bool _loadingContent = true;
  
  // API से आने वाला टेक्स्ट कंटेंट
  String _content = ''; 

  @override
  void initState() {
    super.initState();
    // दोनों APIs को initState में कॉल करें
    fetchSliderImages();
    fetchContent(); 
  }

  // -------------------------------------------------------------------
  // 1. स्लाइडर इमेजेज को API से लाने का फंक्शन
  // -------------------------------------------------------------------
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
          _loadingSlider = false;
        });
      } else {
        setState(() => _loadingSlider = false);
      }
    } catch (e) {
      setState(() => _loadingSlider = false);
    }
  }

  // -------------------------------------------------------------------
  // 2. टेक्स्ट कंटेंट को API से लाने का फंक्शन
  // (आपके JSON फॉर्मेट के अनुसार अपडेटेड)
  // -------------------------------------------------------------------
  Future<void> fetchContent() async {
    try {
      final response =
          await http.get(Uri.parse("https://website.sadhumargi.in/api/yuva-content"));
      
      if (response.statusCode == 200) {
        // रिस्पॉन्स एक लिस्ट (List) है जिसमें पहला एलिमेंट कंटेंट है
        final List<dynamic> dataList = json.decode(response.body);
        
        String fetchedContent = '';
        
        if (dataList.isNotEmpty && dataList.first is Map) {
          // पहले ऑब्जेक्ट से 'content' key का मान निकालें
          // dart:convert स्वतः ही unicode (\uXXXX) को हिंदी में बदल देता है
          fetchedContent = dataList.first['content'] ?? 'कंटेंट लोड करने में असमर्थ।';
        } else {
          fetchedContent = 'कंटेंट डेटा फॉर्मेट में नहीं मिला।';
        }

        setState(() {
          _content = fetchedContent;
          _loadingContent = false;
        });
      } else {
        setState(() {
          _content = 'सर्वर से कंटेंट लोड करने में विफल (Status: ${response.statusCode})।';
          _loadingContent = false;
        });
      }
    } catch (e) {
      setState(() {
        _content = 'कंटेंट लोड करने के दौरान एक त्रुटि आई।';
        _loadingContent = false;
      });
    }
  }
  
  // -------------------------------------------------------------------
  // 3. नेविगेशन डॉट्स विजेट
  // -------------------------------------------------------------------
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
  
  // -------------------------------------------------------------------
  // 4. बिल्ड मेथड
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        const SizedBox(height: 12),

        // Slider
        SizedBox(
          height: 200,
          child: _loadingSlider
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

        // Dynamic Content Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _loadingContent
              ? const Center(child: CircularProgressIndicator()) // कंटेंट लोड हो रहा है
              : Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.brown.shade200, width: 1),
                  ),
                  color: Colors.brown.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _content, // API से प्राप्त कंटेंट
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