import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker extends StatefulWidget {
  final Widget child;
  const UpdateChecker({super.key, required this.child});

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  bool _showUpdate = false;
  String? _latestVersion;
  String? _currentVersion;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse("https://yourdomain.com/api/latest-version"));
      if (response.statusCode == 200) {
        final latestVersion = jsonDecode(response.body)['version_code'];
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        setState(() {
          _latestVersion = latestVersion;
          _currentVersion = currentVersion;
        });

        if (latestVersion != currentVersion) {
          setState(() {
            _showUpdate = true;
          });
        }
      }
    } catch (e) {
      print("Update check failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showUpdate) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 Update Illustration
                const Icon(Icons.system_update_alt, size: 120, color: Colors.white),
                const SizedBox(height: 30),

                // 🔹 Title
                const Text(
                  "Update Required 🚀",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // 🔹 Subtitle
                Text(
                  "A new version of the app is available.\nPlease update to continue.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

                // 🔹 Version Info
                if (_latestVersion != null && _currentVersion != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Installed: v$_currentVersion   →   Latest: v$_latestVersion",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 40),

                // 🔹 Update Button
                ElevatedButton(
                  onPressed: () async {
                    final url = Uri.parse(
                        "https://play.google.com/store/apps/details?id=com.sabsjs.laravel_auth_flutter");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    "Update Now",
                    style: TextStyle(
                      color: Color(0xFF673AB7),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
