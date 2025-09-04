import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // ====== DESIGN SYSTEM ======
  static const Color primary = Color(0xFF1E3A8A); // brand blue
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const double radius = 18;

  late TabController _tabController;

  final _memberIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscurePass = true;

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

  @override
  void dispose() {
    _tabController.dispose();
    _memberIdController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ====== HELPERS ======
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showLoader(bool status) async {
    if (status) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)],
            ),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    }
  }

  Future<void> _openWhatsApp() async {
    // Use full international format without '+'
    const phone = '919636501008';
    final uri = Uri.parse('https://wa.me/$phone');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Fallback to SMS/phone if WhatsApp not available
      final sms = Uri.parse('sms:+$phone');
      if (!await launchUrl(sms, mode: LaunchMode.externalApplication)) {
        final tel = Uri.parse('tel:+$phone');
        await launchUrl(tel, mode: LaunchMode.externalApplication);
      }
    }
  }

  // ====== API FLOWS (unchanged) ======
  Future<void> _loginWithMemberId() async {
    final memberId = _memberIdController.text.trim();
    final password = _passwordController.text.trim();
    if (memberId.isEmpty || password.isEmpty) return _showError('Please fill all fields');

    await _showLoader(true);
    final result = await ApiService().loginWithMemberId(memberId, password);
    await _showLoader(false);

    if (result['success'] == true) {
      final data = result['data'] ?? {};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('member_id', data['member_id']?.toString() ?? '');
      await prefs.setString('family_id', data['family_id']?.toString() ?? '');
      await prefs.setBool('is_head_of_family', data['is_head_of_family'] == true);
      await prefs.setString('token', data['token'] ?? '');
      if (!mounted) return;
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

    if (result['success'] == true) {
      setState(() => isOTPSent = true);
    } else {
      _showError(result['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || selectedMemberId.isEmpty) {
      return _showError('Please enter OTP and select Member ID');
    }
    await _showLoader(true);
    final result = await ApiService().verifyOTP(currentMobile, otp, selectedMemberId);
    await _showLoader(false);

    if (result['success'] == true) {
      final data = result['data'] ?? {};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('member_id', data['member_id']?.toString() ?? '');
      await prefs.setString('family_id', data['family_id']?.toString() ?? '');
      await prefs.setBool('is_head_of_family', data['is_head_of_family'] == true);
      await prefs.setString('token', data['token'] ?? '');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showError(result['message'] ?? 'OTP verification failed');
    }
  }

  // ====== UI PARTS ======
  InputDecoration _decor(String label, {IconData? icon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: primary) : null,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      filled: true,
      fillColor: Colors.grey[50],
      hintStyle: const TextStyle(color: textSecondary),
      labelStyle: const TextStyle(color: textSecondary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _button(String label, VoidCallback onPressed, {Color color = primary, IconData? icon}) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Card(
      elevation: 10,
      color: surface.withOpacity(0.86),
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget _pillTabs() {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withOpacity(0.18)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        tabs: const [
          Tab(text: "Member ID", icon: Icon(Icons.person)),
          Tab(text: "Mobile OTP", icon: Icon(Icons.phone_android)),
        ],
      ),
    );
  }

  Widget _idLoginPanel() {
    return _card(
      Column(
        children: [
          TextField(
            controller: _memberIdController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _decor("Member ID", icon: Icons.perm_identity),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePass,
            decoration: _decor(
              "Password",
              icon: Icons.lock,
              suffix: IconButton(
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off, color: primary),
                tooltip: _obscurePass ? 'Show Password' : 'Hide Password',
              ),
            ),
          ),
          const SizedBox(height: 20),
          _button("Login", _loginWithMemberId, icon: Icons.login),
        ],
      ),
    );
  }

  Widget _otpLoginPanel() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
  controller: _mobileController,
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10), // 🔒 max 10 digits
  ],
  decoration: _decor("Mobile Number", icon: Icons.phone),
),

          const SizedBox(height: 12),
          _button("Check Member IDs", _checkMobile, icon: Icons.search),
          const SizedBox(height: 14),

          if ((isMemberSelectionRequired && memberList.isNotEmpty) || (!isMemberSelectionRequired && memberList.length == 1))
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: isMemberSelectionRequired
                  ? DropdownButtonFormField<String>(
                      value: selectedMemberId.isNotEmpty ? selectedMemberId : null,
                      decoration: InputDecoration(
                        labelText: 'Select Member ID',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
                      ),
                      items: memberList.map((member) {
                        return DropdownMenuItem(
                          value: member['member_id'].toString(),
                          child: Text('${member['name'] ?? 'Member'} (${member['member_id']})'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedMemberId = value ?? ''),
                    )
                  : Text(
                      'Member ID: ${memberList.first['member_id']} (${memberList.first['name'] ?? 'Member'})',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
                    ),
            ),

          const SizedBox(height: 14),

          if (selectedMemberId.isNotEmpty && !isOTPSent)
            _button("Send OTP", _sendOtp, icon: Icons.sms),

          if (isOTPSent) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _decor("Enter OTP", icon: Icons.sms),
            ),
            const SizedBox(height: 14),
            _button("Verify OTP", _verifyOTP, icon: Icons.verified, color: Colors.green),
          ],
        ],
      ),
    );
  }

  // ====== RESPONSIVE LAYOUT ======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // subtle blue gradient background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, const Color(0xFF0B1954)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // decorative circles (very subtle)
            Positioned(
              top: -60,
              right: -40,
              child: _blob(220, Colors.white.withOpacity(0.06)),
            ),
            Positioned(
              bottom: -70,
              left: -50,
              child: _blob(260, Colors.white.withOpacity(0.05)),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 900;

                  final logo = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/logo.png', height: math.max(72, math.min(110, c.maxWidth * 0.12))),
                      const SizedBox(height: 10),
                      const Text(
                        "साधुमार्गी जैन संघ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Welcome • कृपया लॉगिन करें",
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600),
                      ),
                    ],
                  );

                  final authPanels = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _pillTabs(),
                      const SizedBox(height: 16),
                      // adaptive height to avoid overflow (compact)
                      SizedBox(
                        height: math.max(360, math.min(480, c.maxHeight * (isWide ? 0.45 : 0.42))),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _idLoginPanel(),
                            _otpLoginPanel(),
                          ],
                        ),
                      ),
                    ],
                  );

                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 24 : 16,
                        vertical: 24,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isWide ? 1000 : 640),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left: Brand / Hero
                                  Expanded(
                                    child: _card(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            logo,
                                            const SizedBox(height: 24),
                                            _heroBullets(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // Right: Auth panels
                                  Expanded(child: authPanels),
                                ],
                              )
                            : Column(
                                children: [
                                  logo,
                                  const SizedBox(height: 18),
                                  authPanels,
                                  const SizedBox(height: 8),
                                  _heroBullets(),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // subtle marketing bullets (last row opens WhatsApp)
  Widget _heroBullets() {
    Widget bulletRow(IconData i, Widget content) {
      return Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(i, size: 16, color: primary),
          ),
          const SizedBox(width: 10),
          Expanded(child: content),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        children: [
          bulletRow(
            Icons.lock_outline,
            const Text(
              'Secure login with Member ID or Mobile OTP',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, height: 1.25),
            ),
          ),
          const SizedBox(height: 8),
          bulletRow(
            Icons.verified_user_outlined,
            const Text(
              'Your data is private and encrypted',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, height: 1.25),
            ),
          ),
          const SizedBox(height: 8),

          // ✅ Clickable help row -> WhatsApp
          InkWell(
            onTap: _openWhatsApp,
            borderRadius: BorderRadius.circular(8),
            child: bulletRow(
              Icons.support_agent_outlined,
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Need help? Contact central office, Bikaner ',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, height: 1.25),
                    ),
                    TextSpan(
                      text: '9636501008',
                      style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // decorative blob
  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 10)],
      ),
    );
  }
}
