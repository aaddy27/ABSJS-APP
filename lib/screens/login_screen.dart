import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? email = '', password = '';
  bool loading = false;
  String message = '';
  bool _obscureText = true;

  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background blobs
          Positioned(top: -100, left: -100, child: _buildBlob(Colors.deepPurple)),
          Positioned(bottom: -80, right: -80, child: _buildBlob(Colors.indigo)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // 🌟 Logo added here
                    Image.asset(
                      'assets/logo.png',
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),

                    // Login title
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Email input
                    _buildInputField(
                      icon: Icons.person,
                      hintText: 'Username',
                      onChanged: (val) => email = val,
                      validator: (val) =>
                          val == null || val.isEmpty || !val.contains('@')
                              ? 'Enter valid email'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // Password input
                    _buildInputField(
                      icon: Icons.lock,
                      hintText: 'Password',
                      obscureText: _obscureText,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                      ),
                      onChanged: (val) => password = val,
                      validator: (val) =>
                          val == null || val.length < 6
                              ? 'Min 6 characters'
                              : null,
                    ),

                    const SizedBox(height: 40),

                    // Login button
                    loading
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                            onTap: _handleLogin,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blueAccent,
                              child: const Icon(Icons.arrow_forward,
                                  color: Colors.white, size: 30),
                            ),
                          ),

                    const SizedBox(height: 16),

                    // Continue without login button
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      child: const Text(
                        'Continue without login',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Error message
                    if (message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          message,
                          style: TextStyle(color: Colors.red[700]),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 60),

                    // Register link
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Widget _buildBlob(Color color) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    Widget? suffix,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: TextFormField(
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[800]),
          suffixIcon: suffix,
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
        message = '';
      });

      try {
        final res = await ApiService.login(email!, password!);
        if (res.containsKey('error')) {
          setState(() {
            message = res['error'].toString();
            loading = false;
          });
        } else if (res.containsKey('access_token')) {
          await saveToken(res['access_token']);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          setState(() {
            message = 'Unexpected response from server';
            loading = false;
          });
        }
      } catch (e) {
        setState(() {
          message = 'Error: ${e.toString()}';
          loading = false;
        });
      }
    }
  }
}
