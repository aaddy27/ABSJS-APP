import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _memberIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();

  List<Map<String, dynamic>> memberList = [];
  String selectedMemberId = "";
  bool isOTPSent = false;
  bool isMemberSelectionRequired = false;
  String currentMobile = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showLoader(bool status) async {
    if (status) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _loginWithMemberId() async {
    final memberId = _memberIdController.text.trim();
    final password = _passwordController.text.trim();
    if (memberId.isEmpty || password.isEmpty) return _showError('Please fill all fields');

    await _showLoader(true);
    final result = await ApiService().loginWithMemberId(memberId, password);
    await _showLoader(false);

    if (result['success']) {
      final data = result['data'] ?? {};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('member_id', data['member_id']?.toString() ?? '');
      await prefs.setString('family_id', data['family_id']?.toString() ?? '');
      await prefs.setBool('is_head_of_family', data['is_head_of_family'] == true);
      await prefs.setString('token', data['token'] ?? '');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showError(result['message'] ?? 'Login failed');
    }
  }

  Future<void> _checkMobile() async {
  final mobile = _mobileController.text.trim();
  if (mobile.isEmpty) return _showError('Enter mobile number');

  currentMobile = mobile;
  setState(() {
    isOTPSent = false;
    isMemberSelectionRequired = false;
    selectedMemberId = '';
    memberList = [];
  });

  await _showLoader(true);
  final result = await ApiService().checkMobile(mobile);
  await _showLoader(false);

  // ✅ Even if status == false, check if members are present
  if (result['members'] != null && result['members'].isNotEmpty) {
    setState(() {
      memberList = List<Map<String, dynamic>>.from(result['members']);

      if (result['single'] == true || memberList.length == 1) {
        selectedMemberId = memberList.first['member_id'].toString();
        isMemberSelectionRequired = false;
      } else {
        selectedMemberId = '';
        isMemberSelectionRequired = true;
      }
    });
  } else {
    _showError(result['message'] ?? 'No member ID found.');
  }
}


  Future<void> _sendOtp() async {
    if (currentMobile.isEmpty || selectedMemberId.isEmpty) {
      _showError('Missing mobile or member ID');
      return;
    }

    await _showLoader(true);
    final result = await ApiService().sendOTP(currentMobile, selectedMemberId);
    await _showLoader(false);

    if (result['success']) {
      setState(() => isOTPSent = true);
    } else {
      _showError(result['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || selectedMemberId.isEmpty) return _showError('Please enter OTP and select Member ID');

    await _showLoader(true);
    final result = await ApiService().verifyOTP(currentMobile, otp, selectedMemberId);
    await _showLoader(false);

    if (result['success']) {
      final data = result['data'] ?? {};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('member_id', data['member_id']?.toString() ?? '');
      await prefs.setString('family_id', data['family_id']?.toString() ?? '');
      await prefs.setBool('is_head_of_family', data['is_head_of_family'] == true);
      await prefs.setString('token', data['token'] ?? '');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showError(result['message'] ?? 'OTP verification failed');
    }
  }

  Widget buildTextField({required TextEditingController controller, required String label, IconData? icon, bool isPassword = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.deepPurple) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget buildLoginCard({required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black26,
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget buildButton({required String label, required VoidCallback onPressed, Color color = Colors.indigo, IconData? icon}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, color: Colors.white) : const SizedBox.shrink(),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Column(
                children: [
                  Image.asset('assets/logo.png', height: 90),
                  const SizedBox(height: 12),
                  const Text("साधुमार्गी जैन संघ ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.deepPurple,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(icon: Icon(Icons.person), text: "Member ID"),
                    Tab(icon: Icon(Icons.phone_android), text: "Mobile OTP"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 520,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Member ID Tab
                    buildLoginCard(
                      child: Column(
                        children: [
                          buildTextField(controller: _memberIdController, label: "Member ID", icon: Icons.perm_identity, keyboardType: TextInputType.number),
                          const SizedBox(height: 15),
                          buildTextField(controller: _passwordController, label: "Password", icon: Icons.lock, isPassword: true),
                          const SizedBox(height: 25),
                          buildButton(label: "Login", onPressed: _loginWithMemberId, icon: Icons.login),
                        ],
                      ),
                    ),

                    // Mobile OTP Tab
                    buildLoginCard(
                      child: Column(
                        children: [
                          buildTextField(controller: _mobileController, label: "Mobile Number", icon: Icons.phone, keyboardType: TextInputType.phone),
                          const SizedBox(height: 15),
                          buildButton(label: "Check Member IDs", onPressed: _checkMobile, icon: Icons.search),
                          const SizedBox(height: 15),

                          // Show dropdown or single member display
                          if ((isMemberSelectionRequired && memberList.isNotEmpty) || (!isMemberSelectionRequired && memberList.length == 1))
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: isMemberSelectionRequired
                                  ? DropdownButtonFormField<String>(
                                      value: selectedMemberId.isNotEmpty ? selectedMemberId : null,
                                      decoration: InputDecoration(
                                        labelText: 'Select Member ID',
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      items: memberList.map((member) {
                                        return DropdownMenuItem(
                                          value: member['member_id'].toString(),
                                          child: Text('${member['name'] ?? 'Member'} (${member['member_id']})'),
                                        );
                                      }).toList(),
                                      onChanged: (value) => setState(() => selectedMemberId = value ?? ''),
                                    )
                                  : Text('Member ID: ${memberList.first['member_id']} (${memberList.first['name'] ?? 'Member'})',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),

                          const SizedBox(height: 15),

                          if (selectedMemberId.isNotEmpty && !isOTPSent)
                            buildButton(label: "Send OTP", onPressed: _sendOtp, icon: Icons.sms),

                          if (isOTPSent) ...[
                            const SizedBox(height: 15),
                            buildTextField(controller: _otpController, label: "Enter OTP", icon: Icons.sms, keyboardType: TextInputType.number),
                            const SizedBox(height: 15),
                            buildButton(label: "Verify OTP", onPressed: _verifyOTP, icon: Icons.verified, color: Colors.green),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
