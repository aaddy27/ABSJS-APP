import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
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
  bool isLoading = true;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }


Future<void> uploadProfileImage() async {
  if (selectedImage == null) return;

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token'); // Token agar auth lage to, warna hata do

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('https://mrmapi.sadhumargi.in/api/upload-profile-pic'),
  );

  request.files.add(await http.MultipartFile.fromPath('profile_pic', selectedImage!.path));
  request.fields['member_id'] = widget.memberId;

  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  final response = await request.send();

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile image uploaded successfully')),
    );
    fetchData(); // refresh image
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to upload image')),
    );
  }
}


  Future<void> fetchData() async {
    try {
      final memberRes = await http.get(Uri.parse('https://mrmapi.sadhumargi.in/api/member/${widget.memberId}'));
      final parivaranjaliRes = await http.get(Uri.parse('https://mrmapi.sadhumargi.in/api/parivaranjali/${widget.memberId}'));
      final utkrantiRes = await http.get(Uri.parse('https://mrmapi.sadhumargi.in/api/members-family-details/${widget.memberId}'));

      if (memberRes.statusCode == 200) {
        memberData = json.decode(memberRes.body);
      }

      if (parivaranjaliRes.statusCode == 200) {
        final data = json.decode(parivaranjaliRes.body)['data'];
        parivaranjali = data.values.any((value) => value == 0) ? "हां" : "नहीं";
      }

      if (utkrantiRes.statusCode == 200) {
        utkrantiFamily = json.decode(utkrantiRes.body)['data']['utkranti_family'];
      }

      setState(() => isLoading = false);
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> generateAndDownloadCardPDF() async {
    if (memberData == null) return;

    final mid = memberData!['member_id'].toString();
    final name = "${memberData!['first_name']} ${memberData!['last_name']}";
    final father = memberData!['adharfatherName'] ?? '';
    final dob = memberData!['birth_day'] ?? '';
    final profileUrl = "https://members.sadhumargi.com/profiles/${memberData!['profile_pic']}";

    final pdf = pw.Document();
    final profileImage = await networkImage(profileUrl);
    final bgImage = (await rootBundle.load('assets/images/card_template.jpeg')).buffer.asUint8List();

pdf.addPage(
  pw.Page(
    pageFormat: PdfPageFormat(74 * PdfPageFormat.mm, 105 * PdfPageFormat.mm),
    build: (pw.Context context) {
      return pw.Stack(
        children: [
          // Background Image
          pw.Positioned(
            left: 0,
            top: 0,
            child: pw.Image(pw.MemoryImage(bgImage), width: 74 * PdfPageFormat.mm, height: 105 * PdfPageFormat.mm),
          ),
          // Member ID at bottom
pw.Positioned(
  left: 22,
  bottom: 12, // Adjust as needed
  child: pw.Text(
    " $mid",
    style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
  ),
),
          // Member ID
          pw.Positioned(
            left: 28,
            top: 53,
            child: pw.Text(
              " $mid",
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          // Profile Image
        pw.Positioned(
  left: 75,
  top: 255,
  child: pw.ClipRect(
    child: pw.Container(
      width: 28,
      height: 28,
      decoration: pw.BoxDecoration(
        image: pw.DecorationImage(
          image: profileImage,
          fit: pw.BoxFit.cover,
        ),
      ),
    ),
  ),
),
pw.Positioned(
  bottom: 20,
 left: 7,
  child: pw.BarcodeWidget(
    barcode: pw.Barcode.qrCode(),
    data: "${memberData!['anchal_id']}-${memberData!['local_sangh_id']}-${memberData!['family_id']}-${memberData!['member_id']}", // Global Card ID as QR
    width: 15,
    height: 15,
  ),
),

        // Name + Father + DOB (in BOLD and CAPITAL)
pw.Positioned(
  left: 8,
  top: 241,
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        name.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.Text(
        father.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.Text(
        dob.toUpperCase(), // If DOB is in "dd-mm-yyyy" it will remain same
        style: pw.TextStyle(
          fontSize: 5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    ],
  ),
),
pw.Positioned(
  left: 110,
  bottom: 60, // adjust as needed to avoid overlapping with QR or Member ID
  child: pw.Text(
    "${memberData!['anchal_id']}-${memberData!['local_sangh_id']}-${memberData!['family_id']}-${memberData!['member_id']}",
    style: pw.TextStyle(
      fontSize: 7,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    ),
  ),
),

// ⬅️ new not of card

pw.Positioned(
  left: 19, // ⬅️ new position (change as needed)
  bottom: 92, // ⬅️ same vertical level
  child: pw.Text(
    "${memberData!['anchal_id']}-${memberData!['local_sangh_id']}-${memberData!['family_id']}-${memberData!['member_id']}",
    style: pw.TextStyle(
      fontSize: 7,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    ),
  ),
),

          // QR Code
          pw.Positioned(
            top: 70,
            left: 20,
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: mid,
              width: 40,
              height: 40,
            ),
          ),
        ],
      );
    },
  ),
);



    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "global_card_$mid.pdf",
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: 5,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : memberData == null
              ? const Center(child: Text('डेटा प्राप्त नहीं हुआ'))
              : SingleChildScrollView(
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
    );
  }

  Widget buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: showFullImageDialog,
          child: CircleAvatar(
            radius: 95,
            backgroundImage: selectedImage != null
                ? FileImage(selectedImage!)
                : NetworkImage("https://members.sadhumargi.com/profiles/${memberData!['profile_pic']}") as ImageProvider,
            backgroundColor: Colors.grey[200],
            child: Container(),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: InkWell(
            onTap: pickImage,
            borderRadius: BorderRadius.circular(20),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Icon(Icons.edit, color: Colors.deepPurple),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMemberCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${memberData!['salution']} ${memberData!['first_name']} ${memberData!['last_name']}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildInfoRow("सदस्य आईडी", memberData!['member_id'].toString()),
            _buildInfoRow("उत्क्रांति परिवार", utkrantiFamily == 0 ? 'हां' : 'नहीं'),
            _buildInfoRow("परिवारंजली", parivaranjali ?? 'N/A'),
            _buildInfoRow("ग्लोबल कार्ड आईडी", "${memberData!['anchal_id']}-${memberData!['local_sangh_id']}-${memberData!['family_id']}-${memberData!['member_id']}", color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
  icon: const Icon(Icons.lock),
  label: const Text("पासवर्ड बदले"),
  onPressed: showChangePasswordDialog,
  style: _buttonStyle(),
)
,
        ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text("ग्लोबल कार्ड"),
          onPressed: generateAndDownloadCardPDF,
          style: _buttonStyle(),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text("लॉगआउट करें"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
    );
  }
  Future<void> changePassword(
  String oldPassword,
  String newPassword,
  String confirmPassword,
) async {
  if (newPassword != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('नया पासवर्ड और पुष्टि मेल नहीं खाते')),
    );
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final response = await http.post(
    Uri.parse('https://mrmapi.sadhumargi.in/api/change-password'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'old_password': oldPassword,
      'password': newPassword,
      'password_confirmation': confirmPassword,
      'member_id': widget.memberId,
    }),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('पासवर्ड सफलतापूर्वक बदल गया')),
    );
    Navigator.pop(context); // Close the dialog
  } else {
    String error = 'पासवर्ड बदलने में विफल';
    try {
      final respJson = jsonDecode(response.body);
      error = respJson['message'] ?? error;
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }
}


Future<void> pickImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked != null) {
    setState(() => selectedImage = File(picked.path));
    await uploadProfileImage();
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'पुराना पासवर्ड'),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'नया पासवर्ड'),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'नया पासवर्ड पुष्टि करें'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('रद्द करें')),
          ElevatedButton(
              onPressed: () async {
                await changePassword(
                  oldPasswordController.text,
                  newPasswordController.text,
                  confirmPasswordController.text,
                );
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
            child: selectedImage != null
                ? Image.file(selectedImage!, fit: BoxFit.contain)
                : Image.network("https://members.sadhumargi.com/profiles/${memberData!['profile_pic']}", fit: BoxFit.contain),
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
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}