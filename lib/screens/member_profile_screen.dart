// member_profile_screen.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'base_scaffold.dart';
import 'login_screen.dart';

class MemberProfileScreen extends StatefulWidget {
  final String memberId;
  const MemberProfileScreen({super.key, required this.memberId});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  Map<String, dynamic>? memberData;
  String? parivaranjali;
  int? utkrantiFamily;

  // UI states
  bool isLoading = true; // true only when app has no cached data and initial fetch running
  bool isRefreshing = false; // true when background refresh running

  // local cached profile image file (if downloaded or uploaded)
  File? cachedProfileImageFile;

  // SharedPreferences keys
  String get _prefsMemberKey => 'member_cache_${widget.memberId}';
  String get _prefsImagePathKey => 'member_image_${widget.memberId}';
  String get _prefsParivaranjaliKey => 'member_parivaranjali_${widget.memberId}';
  String get _prefsUtkrantiKey => 'member_utkranti_${widget.memberId}';

  @override
  void initState() {
    super.initState();
    _loadCacheThenRefresh();
  }

  /// Load cache first (so UI shows immediately), then start background refresh (non-blocking).
  Future<void> _loadCacheThenRefresh() async {
    await _loadCachedMemberData();
    // If user had cache, show it immediately; now start network fetch but do not await here so UI not blocked
    fetchData(); // fire-and-forget refresh; fetchData will manage isRefreshing
  }

  Future<void> _loadCachedMemberData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_prefsMemberKey);
      final cachedImagePath = prefs.getString(_prefsImagePathKey);
      final storedParivaranjali = prefs.getString(_prefsParivaranjaliKey);
      final storedUtkranti = prefs.getInt(_prefsUtkrantiKey);

      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson);
        if (mounted) {
          setState(() {
            memberData = Map<String, dynamic>.from(decoded);
            parivaranjali = storedParivaranjali;
            utkrantiFamily = storedUtkranti;
            isLoading = false; // show cached immediately
          });
        }
      }

      if (cachedImagePath != null) {
        final f = File(cachedImagePath);
        if (await f.exists()) {
          if (mounted) setState(() => cachedProfileImageFile = f);
        } else {
          await prefs.remove(_prefsImagePathKey);
        }
      } else {
        // no local image; still ok
      }
    } catch (e) {
      debugPrint('Error loading cache: $e');
    }
  }

  Future<void> _saveMemberDataToCache(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsMemberKey, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving member cache: $e');
    }
  }

  Future<void> _saveParivaranjaliCache(String? v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (v == null) {
        await prefs.remove(_prefsParivaranjaliKey);
      } else {
        await prefs.setString(_prefsParivaranjaliKey, v);
      }
    } catch (e) {
      debugPrint('Error saving parivaranjali cache: $e');
    }
  }

  Future<void> _saveUtkrantiCache(int? v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (v == null) {
        await prefs.remove(_prefsUtkrantiKey);
      } else {
        await prefs.setInt(_prefsUtkrantiKey, v);
      }
    } catch (e) {
      debugPrint('Error saving utkranti cache: $e');
    }
  }

  Future<String?> _downloadAndCacheProfileImage(String imageNameOrPathFromServer) async {
    try {
      final url = "https://members.sadhumargi.com/profiles/$imageNameOrPathFromServer";
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final bytes = resp.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final profileDir = Directory('${dir.path}/profiles');
        if (!await profileDir.exists()) await profileDir.create(recursive: true);
        final filePath = '${profileDir.path}/member_${widget.memberId}.jpg';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsImagePathKey, file.path);
        return file.path;
      } else {
        debugPrint('Profile image download failed: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('Profile image download error: $e');
    }
    return null;
  }

  Future<void> _removeCachedProfileImage() async {
    // kept for internal use but not exposed in UI (user asked to remove delete button)
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_prefsImagePathKey);
      if (path != null) {
        final f = File(path);
        if (await f.exists()) await f.delete();
        await prefs.remove(_prefsImagePathKey);
      }
      if (mounted) setState(() => cachedProfileImageFile = null);
    } catch (e) {
      debugPrint('Error removing cached image: $e');
    }
  }

  /// Fetch fresh data from network. This function will set isRefreshing=true (if cache exists),
  /// otherwise set isLoading=true for initial load.
  Future<void> fetchData() async {
    // If we have cached memberData already, do not set isLoading (to avoid spinner). Use isRefreshing instead.
    final hadCache = memberData != null;
    if (hadCache) {
      if (mounted) setState(() => isRefreshing = true);
    } else {
      if (mounted) setState(() => isLoading = true);
    }

    try {
      final memberUrl = 'https://mrmapi.sadhumargi.in/api/member/${widget.memberId}';
      final parivaranjaliUrl = 'https://mrmapi.sadhumargi.in/api/parivaranjali/${widget.memberId}';
      final utkrantiUrl = 'https://mrmapi.sadhumargi.in/api/members-family-details/${widget.memberId}';

      final responses = await Future.wait([
        http.get(Uri.parse(memberUrl)),
        http.get(Uri.parse(parivaranjaliUrl)),
        http.get(Uri.parse(utkrantiUrl)),
      ]);

      final memberRes = responses[0];
      final parivaranjaliRes = responses[1];
      final utkrantiRes = responses[2];

      if (memberRes.statusCode == 200) {
        final decoded = json.decode(memberRes.body);
        if (mounted) setState(() => memberData = decoded);
        await _saveMemberDataToCache(decoded);
      }

      if (parivaranjaliRes.statusCode == 200) {
        final data = json.decode(parivaranjaliRes.body);
        String result = 'N/A';
        try {
          final inner = data['data'];
          if (inner is Map) {
            result = inner.values.any((v) => v == 0) ? "हां" : "नहीं";
          } else {
            result = (data == 0) ? "हां" : "नहीं";
          }
        } catch (_) {
          result = 'N/A';
        }
        if (mounted) setState(() => parivaranjali = result);
        await _saveParivaranjaliCache(result);
      }

      if (utkrantiRes.statusCode == 200) {
        try {
          final decoded = json.decode(utkrantiRes.body);
          final int? ut = decoded['data'] != null && decoded['data']['utkranti_family'] != null
              ? int.tryParse(decoded['data']['utkranti_family'].toString())
              : null;
          if (mounted) setState(() => utkrantiFamily = ut);
          await _saveUtkrantiCache(ut);
        } catch (_) {
          // ignore
        }
      }

      // If server returned a profile filename and we don't have local cached image, download it in background
      if (memberData != null && memberData!['profile_pic'] != null && (cachedProfileImageFile == null)) {
        final serverImageField = memberData!['profile_pic'].toString();
        if (serverImageField.trim().isNotEmpty) {
          final savedPath = await _downloadAndCacheProfileImage(serverImageField);
          if (savedPath != null && mounted) {
            setState(() => cachedProfileImageFile = File(savedPath));
          }
        }
      }
    } catch (e) {
      debugPrint('fetchData error: $e');
    } finally {
      if (hadCache) {
        if (mounted) setState(() => isRefreshing = false);
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  /// Upload profile image and update cache/UI. Returns true on success.
  Future<bool> uploadProfileImageFile(File fileToUpload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // optional

      final request = http.MultipartRequest('POST', Uri.parse('https://mrmapi.sadhumargi.in/api/upload-profile-pic'));
      request.files.add(await http.MultipartFile.fromPath('profile_pic', fileToUpload.path));
      request.fields['member_id'] = widget.memberId;
      if (token != null) request.headers['Authorization'] = 'Bearer $token';

      final streamedResp = await request.send();
      final respStr = await streamedResp.stream.bytesToString();

      if (streamedResp.statusCode == 200) {
        // optimistic: copy uploaded file to local cache folder
        final dir = await getApplicationDocumentsDirectory();
        final profileDir = Directory('${dir.path}/profiles');
        if (!await profileDir.exists()) await profileDir.create(recursive: true);
        final destPath = '${profileDir.path}/member_${widget.memberId}.jpg';
        await fileToUpload.copy(destPath);
        final prefs2 = await SharedPreferences.getInstance();
        await prefs2.setString(_prefsImagePathKey, destPath);
        if (mounted) setState(() => cachedProfileImageFile = File(destPath));
        // refresh member data in background
        fetchData();
        return true;
      } else {
        debugPrint('Upload failed: $respStr');
        return false;
      }
    } catch (e) {
      debugPrint('uploadProfileImageFile error: $e');
      return false;
    }
  }

  /// Pick from gallery & upload (optimistic UI)
  Future<void> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        final file = File(picked.path);
        // show picked image immediately
        if (mounted) setState(() => cachedProfileImageFile = file);
        // upload in background
        final success = await uploadProfileImageFile(file);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Image uploaded' : 'Upload failed')));
        }
      }
    } catch (e) {
      debugPrint('pickAndUploadImage error: $e');
    }
  }

  /// PDF generation (defensive)
  Future<void> generateAndDownloadCardPDF() async {
    if (memberData == null) return;

    final mid = memberData!['member_id'].toString();
    final name = "${memberData!['first_name'] ?? ''} ${memberData!['last_name'] ?? ''}".trim();
    final father = memberData!['adharfatherName'] ?? '';
    final dob = memberData!['birth_day'] ?? '';
    final profileFileName = memberData!['profile_pic'] ?? '';

    final pdf = pw.Document();

    // try to load profile image bytes (prefer cached local file)
    Uint8List? profileImageBytes;
    try {
      if (cachedProfileImageFile != null && await cachedProfileImageFile!.exists()) {
        profileImageBytes = await cachedProfileImageFile!.readAsBytes();
      } else if (profileFileName.toString().isNotEmpty) {
        final url = "https://members.sadhumargi.com/profiles/$profileFileName";
        final resp = await http.get(Uri.parse(url));
        if (resp.statusCode == 200) profileImageBytes = resp.bodyBytes;
      }
    } catch (e) {
      debugPrint('profile image bytes fetch error: $e');
    }

    final bgImage = (await rootBundle.load('assets/images/card_template.jpeg')).buffer.asUint8List();
    final pwImage = profileImageBytes != null ? pw.MemoryImage(profileImageBytes) : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(74 * PdfPageFormat.mm, 105 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Stack(children: [
            pw.Positioned(left: 0, top: 0, child: pw.Image(pw.MemoryImage(bgImage), width: 74 * PdfPageFormat.mm, height: 105 * PdfPageFormat.mm)),
            pw.Positioned(left: 28, top: 53, child: pw.Text(" $mid", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
            if (pwImage != null)
              pw.Positioned(left: 75, top: 255, child: pw.ClipRect(child: pw.Container(width: 28, height: 28, decoration: pw.BoxDecoration(image: pw.DecorationImage(image: pwImage, fit: pw.BoxFit.cover))))),
            pw.Positioned(bottom: 20, left: 7, child: pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: "${memberData!['anchal_id']}-${memberData!['local_sangh_id']}-${memberData!['family_id']}-${memberData!['member_id']}", width: 15, height: 15)),
            pw.Positioned(left: 8, top: 241, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(name.toUpperCase(), style: pw.TextStyle(fontSize: 5, fontWeight: pw.FontWeight.bold)),
              pw.Text(father.toUpperCase(), style: pw.TextStyle(fontSize: 5, fontWeight: pw.FontWeight.bold)),
              pw.Text(dob.toUpperCase(), style: pw.TextStyle(fontSize: 5, fontWeight: pw.FontWeight.bold)),
            ])),
            pw.Positioned(left: 110, bottom: 60, child: pw.Text("${memberData!['anchal_id']}-${memberData!['local_sangh_id']}-${memberData!['family_id']}-${memberData!['member_id']}", style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
          ]);
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: "global_card_$mid.pdf");
  }

  // UI builders
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: 5,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : memberData == null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('डेटा प्राप्त नहीं हुआ'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: fetchData, child: const Text('Retry'))
                ]))
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Column(
                        children: [
                          buildProfileImage(),
                          const SizedBox(height: 24),
                          buildMemberCard(),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                          const SizedBox(height: 24),
                          _buildLogoutButton(),
                        ],
                      ),
                    ),
                    if (isRefreshing)
                      Positioned(
                        top: 18,
                        right: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: const [
                              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                              SizedBox(width: 8),
                              Text('Updating...', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget buildProfileImage() {
    final imageProvider = (cachedProfileImageFile != null && cachedProfileImageFile!.existsSync())
        ? FileImage(cachedProfileImageFile!)
        : (memberData != null && memberData!['profile_pic'] != null && memberData!['profile_pic'].toString().isNotEmpty
            ? NetworkImage("https://members.sadhumargi.com/profiles/${memberData!['profile_pic']}")
            : const AssetImage('assets/images/avatar_placeholder.png')) as ImageProvider;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: showFullImageDialog,
          child: CircleAvatar(
            radius: 95,
            backgroundImage: imageProvider,
            backgroundColor: Colors.grey[200],
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: InkWell(
            onTap: pickAndUploadImage,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.06), blurRadius: 6)]),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.edit, color: Colors.deepPurple),
            ),
          ),
        ),
        // NOTE: Deleted the local-cache delete button per your request.
      ],
    );
  }

  Widget buildMemberCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${memberData!['salution'] ?? ''} ${memberData!['first_name'] ?? ''} ${memberData!['last_name'] ?? ''}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildInfoRow("सदस्य आईडी", memberData!['member_id'].toString()),
          _buildInfoRow("उत्क्रांति परिवार", utkrantiFamily == 0 ? 'हां' : (utkrantiFamily == null ? 'N/A' : 'नहीं')),
          _buildInfoRow("परिवारंजली", parivaranjali ?? 'N/A'),
          _buildInfoRow("ग्लोबल कार्ड आईडी", "${memberData!['anchal_id'] ?? ''}-${memberData!['local_sangh_id'] ?? ''}-${memberData!['family_id'] ?? ''}-${memberData!['member_id'] ?? ''}", color: Colors.deepPurple),
        ]),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(icon: const Icon(Icons.lock), label: const Text("पासवर्ड बदले"), onPressed: showChangePasswordDialog, style: _buttonStyle()),
        ElevatedButton.icon(icon: const Icon(Icons.download), label: const Text("ग्लोबल कार्ड"), onPressed: generateAndDownloadCardPDF, style: _buttonStyle()),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text("लॉगआउट करें"),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
        }
      },
    );
  }

  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('नया पासवर्ड और पुष्टि मेल नहीं खाते')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(Uri.parse('https://mrmapi.sadhumargi.in/api/change-password'), headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    }, body: jsonEncode({
      'old_password': oldPassword,
      'password': newPassword,
      'password_confirmation': confirmPassword,
      'member_id': widget.memberId,
    }));

    if (response.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('पासवर्ड सफलतापूर्वक बदल गया')));
        Navigator.pop(context);
      }
    } else {
      String error = 'पासवर्ड बदलने में विफल';
      try {
        final respJson = jsonDecode(response.body);
        error = respJson['message'] ?? error;
      } catch (_) {}
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final f = File(picked.path);
      if (mounted) setState(() => cachedProfileImageFile = f);
      final success = await uploadProfileImageFile(f);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Image uploaded' : 'Upload failed')));
    }
  }

  void showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('पासवर्ड बदलें'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: oldPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'पुराना पासवर्ड')),
            TextField(controller: newPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'नया पासवर्ड')),
            TextField(controller: confirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'नया पासवर्ड पुष्टि करें')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
            ElevatedButton(
                onPressed: () async {
                  await changePassword(oldPasswordController.text, newPasswordController.text, confirmPasswordController.text);
                },
                child: const Text('बदलें')),
          ],
        );
      },
    );
  }

  void showFullImageDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (cachedProfileImageFile != null)
                ? Image.file(cachedProfileImageFile!, fit: BoxFit.contain)
                : (memberData != null && memberData!['profile_pic'] != null && memberData!['profile_pic'].toString().isNotEmpty)
                    ? Image.network("https://members.sadhumargi.com/profiles/${memberData!['profile_pic']}", fit: BoxFit.contain)
                    : Image.asset('assets/images/avatar_placeholder.png', fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: TextStyle(color: color))),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
  }
}
