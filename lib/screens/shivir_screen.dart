import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShivirScreen extends StatefulWidget {
  const ShivirScreen({super.key});

  @override
  State<ShivirScreen> createState() => _ShivirScreenState();
}

class _ShivirScreenState extends State<ShivirScreen> {
  bool _loading = true;
  List<dynamic> _shivirs = [];

  @override
  void initState() {
    super.initState();
    _fetchShivirs();
  }

  Future<void> _fetchShivirs() async {
    try {
      final response = await http.get(
        Uri.parse('https://website.sadhumargi.in/api/shivir'),
      );
      if (response.statusCode == 200) {
        List<dynamic> result = json.decode(response.body);
        setState(() {
          _shivirs = result;
          _loading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Widget _buildInfoRow(String? label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Opens full-screen modal with image
  void _openFullScreenImage(String url) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InteractiveViewer(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Color.fromARGB(255, 0, 0, 0), size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsiveImage(String url) {
    return GestureDetector(
      onTap: () => _openFullScreenImage(url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_shivirs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "कार्य प्रगति पर है, सहयोग बनाए रखें। धन्यवाद!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _shivirs.length,
      itemBuilder: (context, index) {
        final shivir = _shivirs[index];
        final photo = shivir['photo'];
        final photoUrl = (photo != null && photo.isNotEmpty)
            ? 'https://website.sadhumargi.in/storage/${photo}'
            : null;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photoUrl != null) _buildResponsiveImage(photoUrl),
                const SizedBox(height: 8),
                _buildInfoRow(null, shivir['title']),
                _buildInfoRow("तिथि", shivir['date']),
                _buildInfoRow("स्थान", shivir['location']),
                _buildInfoRow("विवरण", shivir['description']),
              ],
            ),
          ),
        );
      },
    );
  }
}
