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

  // Member ID Login
  final _memberIdController = TextEditingController();
  final _passwordController = TextEditingController();
  

  // Mobile OTP Login
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();

  List<Map<String, dynamic>> memberList = [];
  String selectedMemberId = "";
  bool isOTPSent = false;
  bool isLoading = false;
  bool isMemberSelectionRequired = false;
   String currentMobile = ''; // ✅ Add this line

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loginWithMemberId() async {
    final memberId = _memberIdController.text.trim();
    final password = _passwordController.text.trim();
    if (memberId.isEmpty || password.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => isLoading = true);
final result = await ApiService().loginWithMemberId(memberId, password);
final data = result['data'] ?? {};
    setState(() => isLoading = false);

    if (result['success']) {
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
    if (mobile.isEmpty) {
      _showError('Enter mobile number');
      return;
    }

currentMobile = mobile; // ✅ store it

    setState(() {
      isLoading = true;
      isOTPSent = false;
      isMemberSelectionRequired = false;
      selectedMemberId = '';
      memberList = [];
    });

    final result = await ApiService().checkMobile(mobile);
    print('Mobile Check API response: $result');

    setState(() => isLoading = false);

    if (result['members'] != null && result['members'].isNotEmpty) {
      setState(() {
        memberList = List<Map<String, dynamic>>.from(result['members']);
        selectedMemberId = memberList.first['member_id'].toString();
        isMemberSelectionRequired = true;
      });
    } else {
      _showError('No member ID found.');
    }
  }

Future<void> _sendOtp() async {
  final mobile = currentMobile;
  if (mobile.isEmpty || selectedMemberId.isEmpty) {
    _showError('Missing mobile or member ID');
    return;
  }

  print("Sending OTP to: $mobile with memberId: $selectedMemberId");

  setState(() => isLoading = true);
final result = await ApiService().sendOTP(currentMobile, selectedMemberId);

  setState(() {
    isLoading = false;
    isOTPSent = result['success'];
  });

  if (!result['success']) {
    _showError(result['message'] ?? 'Failed to send OTP');
  }
}


  Future<void> _verifyOTP() async {
  final otp = _otpController.text.trim();
  final mobile = _mobileController.text.trim();

  if (otp.isEmpty || selectedMemberId.isEmpty || mobile.isEmpty) {
    _showError('Please enter OTP and select Member ID');
    return;
  }

  setState(() => isLoading = true);
  final result = await ApiService().verifyOTP(mobile, otp, selectedMemberId);
  setState(() => isLoading = false);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Member ID'),
              Tab(text: 'Mobile OTP'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Member ID Login Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _memberIdController,
                        decoration: const InputDecoration(labelText: 'Member ID'),
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password'),
                      ),
                      const SizedBox(height: 20),
                      isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _loginWithMemberId,
                              child: const Text('Login'),
                            ),
                    ],
                  ),
                ),

                // Mobile OTP Login Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Mobile Number'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _checkMobile,
                        child: const Text('Check MIDs'),
                      ),
                      const SizedBox(height: 10),
                      if (isMemberSelectionRequired)
                        DropdownButtonFormField<String>(
                          value: selectedMemberId.isNotEmpty ? selectedMemberId : null,
                          decoration: const InputDecoration(labelText: 'Select Member ID'),
                          items: memberList.map((member) {
                            return DropdownMenuItem(
                              value: member['member_id'].toString(),
                              child: Text('${member['name']} (${member['member_id']})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => selectedMemberId = value ?? '');
                          },
                        ),
                      const SizedBox(height: 10),
                      if (selectedMemberId.isNotEmpty && !isOTPSent)
                        ElevatedButton(
                          onPressed: _sendOtp,
                          child: const Text('Send OTP'),
                        ),
                      if (isOTPSent) ...[
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Enter OTP'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _verifyOTP,
                          child: const Text('Verify OTP'),
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (isLoading) const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
