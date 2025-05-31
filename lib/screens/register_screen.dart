import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '', email = '', password = '';
  bool loading = false;
  String message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Soft background color
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Logo
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/logo.jpeg'), // Replace with your logo
                backgroundColor: Colors.white,
              ),
              SizedBox(height: 20),
              // Card with form
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: loading
                      ? Center(child: CircularProgressIndicator())
                      : Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                'Create an Account',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val) => name = val,
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Enter name'
                                    : null,
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val) => email = val,
                                validator: (val) => val == null ||
                                        !val.contains('@')
                                    ? 'Enter valid email'
                                    : null,
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true,
                                onChanged: (val) => password = val,
                                validator: (val) =>
                                    val == null || val.length < 6
                                        ? 'Min 6 chars'
                                        : null,
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      loading = true;
                                      message = '';
                                    });
                                    final res = await ApiService.register(
                                        name, email, password);
                                    setState(() {
                                      loading = false;
                                    });
                                    if (res.containsKey('error')) {
                                      setState(() {
                                        message = res['error'].toString();
                                      });
                                    } else {
                                      setState(() {
                                        message =
                                            'Registered Successfully! Go to Login';
                                      });
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 32),
                                ),
                                child: Text('Register'),
                              ),
                              SizedBox(height: 10),
                              Text(
                                message,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Already have account? Login'),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
