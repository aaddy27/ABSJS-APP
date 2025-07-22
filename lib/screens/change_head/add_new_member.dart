import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:intl/intl.dart';

import '../base_scaffold.dart';

class AddNewMemberScreen extends StatefulWidget {
  const AddNewMemberScreen({super.key});

  @override
  State<AddNewMemberScreen> createState() => _AddNewMemberScreenState();
}

class _AddNewMemberScreenState extends State<AddNewMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedGender;
  String? _selectedRelation;
  List<dynamic> _relations = [];

  final String _familyId = "8929";
  final String _requestMemberId = "197954";

  @override
  void initState() {
    super.initState();
    fetchRelations();
  }

  Future<void> fetchRelations() async {
    final response =
        await http.get(Uri.parse('https://mrmapi.sadhumargi.in/api/relations'));
    if (response.statusCode == 200) {
      setState(() {
        _relations = json.decode(response.body);
      });
    }
  }

  Future<void> submitRequest() async {
    final Map<String, dynamic> payload = {
      "new_mem_first_name": _firstNameController.text.trim(),
      "new_mem_last_name": _lastNameController.text.trim(),
      "new_mem_mobile": _mobileController.text.trim(),
      "mem_dob": _dobController.text.trim(),
      "mem_gender": _selectedGender,
      "new_mem_family_id": _familyId,
      "relation": _selectedRelation,
      "request_member_id": _requestMemberId,
    };

    final response = await http.post(
      Uri.parse("https://mrmapi.sadhumargi.in/api/new-member-request"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );

    final resBody = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (resBody['success'] == true) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: "Success",
          desc: resBody['message'] ?? 'Request submitted successfully!',
          btnOkOnPress: () {
            _formKey.currentState?.reset();
            _dobController.clear();
            setState(() {
              _selectedGender = null;
              _selectedRelation = null;
            });
          },
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: "Failed",
          desc: resBody['message'] ?? 'Something went wrong.',
          btnOkOnPress: () {},
        ).show();
      }
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: "Server Error",
        desc: "Status code: ${response.statusCode}",
        btnOkOnPress: () {},
      ).show();
    }
  }

  void showConfirmationDialog() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to submit this member request?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                submitRequest();
              },
              child: const Text("Yes, Submit"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      selectedIndex: 0,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("New Member Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Mobile"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Date of Birth"),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
              ),
              const SizedBox(height: 10),
              const Text("Gender"),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Male"),
                      value: "male",
                      groupValue: _selectedGender,
                      onChanged: (value) => setState(() => _selectedGender = value),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Female"),
                      value: "female",
                      groupValue: _selectedGender,
                      onChanged: (value) => setState(() => _selectedGender = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Relation with Family Head"),
                value: _selectedRelation,
                items: _relations.map<DropdownMenuItem<String>>((relation) {
                  return DropdownMenuItem<String>(
                    value: relation['relation'],
                    child: Text(relation['relation_utf8']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedRelation = value),
                validator: (value) => value == null ? "Please select a relation" : null,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: showConfirmationDialog,
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
