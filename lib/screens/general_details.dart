import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// -------------------- Models --------------------
class Relation {
  final int id;
  final String relationUtf8;
  final String relation;

  Relation({required this.id, required this.relationUtf8, required this.relation});

  factory Relation.fromJson(Map<String, dynamic> json) {
    return Relation(
      id: json['id'],
      relationUtf8: json['relation_utf8'] ?? '',
      relation: json['relation'] ?? '',
    );
  }
}

class Country {
  final String name;
  final String iso2;

  Country({required this.name, required this.iso2});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] ?? '',
      iso2: json['iso2'] ?? '',
    );
  }
}

class StateModel {
  final String name;

  StateModel({required this.name});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      name: json['name'] ?? '',
    );
  }
}

// -------------------- Screen --------------------
class GeneralDetails extends StatefulWidget {
  const GeneralDetails({super.key});

  @override
  _GeneralDetailsState createState() => _GeneralDetailsState();
}

class _GeneralDetailsState extends State<GeneralDetails> {
  // Stepper state
  int _currentStep = 0;

  // Top message
  String? _message;
  Color _msgColor = Colors.green;

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final guardianNameController = TextEditingController();
  final mobileController = TextEditingController();
  final whatsappNumberController = TextEditingController();
  final alternateNumberController = TextEditingController();
  final emailController = TextEditingController();
  final adharNameController = TextEditingController();
  final adharFatherNameController = TextEditingController();
  final adharController = TextEditingController();
  final originCityController = TextEditingController();
  final originStateController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final postController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final pinCodeController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();

  // Dropdown data
  List<Relation> relationList = [];
  Relation? selectedRelationModel;

  List<Country> countryList = [];
  Country? selectedCountryModel;

  List<StateModel> stateList = [];
  StateModel? selectedStateModel;

  // Dropdown selected values
  String? selectedGender,
      selectedEducation,
      selectedProfession,
      selectedJobType,
      selectedWhatsApp,
      selectedReligion;

  DateTime? selectedDOB;

  // Master lists
  final List<String> genders = ['पुरुष', 'महिला'];
  final List<String> educations = [
    "Less than SSC",
    "SSC",
    "HSC",
    "CA",
    "Doctor",
    "Engineer",
    "Software Engineer",
    "LLB",
    "MBA",
    "PHD",
    "Graduate",
    "Post Graduate",
    "Professional Degree",
    "Other"
  ];

  final List<String> professions = [
    'Teacher',
    'Engineer',
    'Doctor',
    'Housewife',
    'Business',
    'Farmer',
    'CA',
    'Advocate',
    'Self Employed',
    'Other'
  ];

  final List<String> jobTypes = ['घर', 'व्यवसाये', 'Business', 'Other'];

  final List<String> whatsappStatus = ['हाँ', 'नहीं'];

  final List<String> religions = [
    'Sadhumargi',
    'Jain',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    fetchCountries();
    fetchRelations().then((_) {
      fetchMemberData();
    });
  }

  // -------------------- API: Relations --------------------
  Future<void> fetchRelations() async {
    try {
      final response = await http.get(Uri.parse('https://mrmapi.sadhumargi.in/api/relations'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          relationList = data.map((item) => Relation.fromJson(item)).toList();
        });
      } else {
        debugPrint("Failed to load relations: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading relations: $e");
    }
  }

  // -------------------- API: Countries --------------------
  Future<void> fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.countrystatecity.in/v1/countries'),
        headers: {
          'X-CSCAPI-KEY': 'S2dBYnJldWtmRFM4U2VUdG9Fd0hiRXp2RjhpTm81YlhVVThiWEdiTA==',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          countryList = data.map((item) => Country.fromJson(item)).toList();
        });
      } else {
        debugPrint('Failed to load countries');
      }
    } catch (e) {
      debugPrint('Error countries: $e');
    }
  }

  // -------------------- API: States --------------------
  Future<void> fetchStates(String countryIso) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.countrystatecity.in/v1/countries/$countryIso/states'),
        headers: {
          'X-CSCAPI-KEY': 'S2dBYnJldWtmRFM4U2VUdG9Fd0hiRXp2RjhpTm81YlhVVThiWEdiTA==',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          stateList = data.map((item) => StateModel.fromJson(item)).toList();
        });
      } else {
        debugPrint('Failed to fetch states: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching states: $e');
    }
  }

  // -------------------- API: Fetch Member --------------------
  Future<void> fetchMemberData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memberId = prefs.getString('member_id') ?? '';
      if (memberId.isEmpty) return;

      final url = Uri.parse('https://mrmapi.sadhumargi.in/api/member/$memberId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // match relation
        Relation? matchedRelation;
        final relationIdFromApi = data['relation_id'];
        if (relationList.isNotEmpty && relationIdFromApi != null) {
          matchedRelation = relationList.firstWhere(
            (r) => r.id == relationIdFromApi,
            orElse: () => Relation(id: 0, relationUtf8: '', relation: ''),
          );
        }

        setState(() {
          // Name
          firstNameController.text = data['first_name'] ?? '';
          lastNameController.text = data['last_name'] ?? '';
          guardianNameController.text = data['guardian_name'] ?? '';

          // Contact
          mobileController.text = data['mobile'] ?? '';
          whatsappNumberController.text = data['whatsapp_number'] ?? '';
          alternateNumberController.text = data['alternate_number'] ?? '';
          emailController.text = data['email_address'] ?? '';

          // Aadhaar
          adharNameController.text = data['adhar_name'] ?? '';
          adharFatherNameController.text = data['adharfatherName'] ?? '';
          adharController.text =
              "${data['adhar1'] ?? ''}${data['adhar2'] ?? ''}${data['adhar3'] ?? ''}";

          // Address
          originCityController.text = data['origin_city'] ?? '';
          originStateController.text = data['origin_state'] ?? '';
          address1Controller.text = data['address'] ?? '';
          address2Controller.text = data['address2'] ?? '';
          postController.text = data['post'] ?? '';
          cityController.text = data['city'] ?? '';
          districtController.text = data['district'] ?? '';
          pinCodeController.text = data['pincode']?.toString() ?? '';
          countryController.text = data['country'] ?? '';
          stateController.text = data['state'] ?? '';

          // Dropdowns
          selectedGender = mapGender(data['gender']);
          selectedRelationModel =
              (matchedRelation != null && matchedRelation.id != 0) ? matchedRelation : null;

          selectedEducation = educations.contains(data['education']) ? data['education'] : null;
          selectedProfession = professions.contains(data['occupation']) ? data['occupation'] : null;
          selectedJobType = jobTypes.contains(data['address_type']) ? data['address_type'] : null;
          selectedReligion = religions.contains(data['rel_faith']) ? data['rel_faith'] : null;

          // Country/State pre-select
          if (countryList.isNotEmpty && (data['country'] ?? '').toString().isNotEmpty) {
            final foundCountry = countryList.firstWhere(
              (c) => c.name.toLowerCase() == data['country'].toString().toLowerCase(),
              orElse: () => Country(name: '', iso2: ''),
            );
            selectedCountryModel = foundCountry.name.isEmpty ? null : foundCountry;
            if (selectedCountryModel != null) {
              fetchStates(selectedCountryModel!.iso2).then((_) {
                if ((data['state'] ?? '').toString().isNotEmpty) {
                  final foundState = stateList.firstWhere(
                    (s) => s.name.toLowerCase() == data['state'].toString().toLowerCase(),
                    orElse: () => StateModel(name: ''),
                  );
                  setState(() {
                    selectedStateModel = foundState.name.isEmpty ? null : foundState;
                  });
                }
              });
            }
          }

          // WhatsApp status
          selectedWhatsApp =
              (data['whatsapp_number'] != null && data['whatsapp_number'].toString().isNotEmpty)
                  ? 'हाँ'
                  : null; // null भी हो सकता है
          if (selectedWhatsApp == null && (data['whatsapp_number'] ?? '').toString().isEmpty) {
            // hide number by default
          }

          // DOB
          if (data['birth_day'] != null) {
            selectedDOB = DateTime.tryParse(data['birth_day']);
          }
        });
      } else {
        debugPrint("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching member data: $e");
    }
  }

  // -------------------- API: Update Member --------------------
  Future<void> updateMemberDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final memberId = prefs.getString('member_id') ?? '';

    if (token.isEmpty || memberId.isEmpty) {
      setState(() {
        _message = '🔑 लॉगिन टोकन गायब है। कृपया पुनः लॉगिन करें।';
        _msgColor = Colors.red;
      });
      return;
    }

    final url = Uri.parse('https://mrmapi.sadhumargi.in/api/member/$memberId/update');

    // सुरक्षित Aadhaar split
    final adhar = adharController.text.replaceAll(RegExp(r'\s+'), '');
    String a1 = '', a2 = '', a3 = '';
    if (adhar.length >= 12) {
      a1 = adhar.substring(0, 4);
      a2 = adhar.substring(4, 8);
      a3 = adhar.substring(8, 12);
    } else if (adhar.length >= 8) {
      a1 = adhar.substring(0, 4);
      a2 = adhar.substring(4, 8);
      a3 = adhar.substring(8);
    } else if (adhar.length >= 4) {
      a1 = adhar.substring(0, 4);
      a2 = adhar.substring(4);
    } else if (adhar.isNotEmpty) {
      a1 = adhar;
    }

    final body = {
      "salution": "Kumar",
      "first_name": firstNameController.text.isEmpty ? null : firstNameController.text,
      "last_name": lastNameController.text.isEmpty ? null : lastNameController.text,
      "guardian_type": "Father",
      "guardian_name": guardianNameController.text.isEmpty ? null : guardianNameController.text,
      "relation": selectedRelationModel?.id,
      "gender": selectedGender == "पुरुष"
          ? "Male"
          : selectedGender == "महिला"
              ? "Female"
              : null,
      "birth_day": selectedDOB?.toIso8601String(),
      "education": selectedEducation,
      "occupation": selectedProfession,
      "country": selectedCountryModel?.name,
      "state": selectedStateModel?.name,
      "origin_city": originCityController.text.isEmpty ? null : originCityController.text,
      "origin_state": originStateController.text.isEmpty ? null : originStateController.text,
      "mobile": mobileController.text.isEmpty ? null : mobileController.text,
      "whatsapp_number": selectedWhatsApp == 'हाँ' ? (whatsappNumberController.text) : '',
      "alternate_number": alternateNumberController.text.isEmpty ? null : alternateNumberController.text,
      "email_address": emailController.text.isEmpty ? null : emailController.text,
      "pincode": pinCodeController.text.isEmpty ? null : pinCodeController.text,
      "adhar_name": adharNameController.text.isEmpty ? null : adharNameController.text,
      "adharfatherName": adharFatherNameController.text.isEmpty ? null : adharFatherNameController.text,
      "adhar1": a1.isEmpty ? null : a1,
      "adhar2": a2.isEmpty ? null : a2,
      "adhar3": a3.isEmpty ? null : a3,
      "religion": selectedReligion,
      "address_type": selectedJobType,
      "address": address1Controller.text.isEmpty ? null : address1Controller.text,
      "address2": address2Controller.text.isEmpty ? null : address2Controller.text,
      "post": postController.text.isEmpty ? null : postController.text,
      "city": cityController.text.isEmpty ? null : cityController.text,
      "district": districtController.text.isEmpty ? null : districtController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        setState(() {
          _message = res['message'] ?? '✅ सफलतापूर्वक अपडेट किया गया';
          _msgColor = Colors.green;
        });
      } else {
        setState(() {
          _message = '❌ सर्वर से त्रुटि: ${response.statusCode}';
          _msgColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _message = '❌ सहेजने में त्रुटि हुई';
        _msgColor = Colors.red;
      });
    }
  }

  // -------------------- Helpers --------------------
  String? mapGender(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'male':
        return 'पुरुष';
      case 'female':
        return 'महिला';
      default:
        return null;
    }
  }

  Widget buildRelationDropdown() {
    return DropdownButtonFormField<Relation>(
      isExpanded: true,
      isDense: true,
      value: selectedRelationModel,
      items: relationList
          .map((relation) => DropdownMenuItem(
                value: relation,
                child: Text("${relation.relationUtf8} (${relation.relation})"),
              ))
          .toList(),
      onChanged: (Relation? newValue) {
        setState(() {
          selectedRelationModel = newValue;
        });
      },
      decoration: InputDecoration(
        labelText: "सदस्य का मुखिया से रिश्ता",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (_) => null, // not required
    );
  }

  Widget buildTextField(
    String label, {
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboardType,
      validator: (_) => null, // not required
    );
  }

  Widget buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      isDense: true,
      value: items.contains(selectedValue) ? selectedValue : null,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (_) => null, // not required
    );
  }

  Widget buildDatePicker(
    String label,
    DateTime? selectedDate,
    ValueChanged<DateTime> onPicked,
  ) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      controller: TextEditingController(
        text: selectedDate == null ? '' : "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => onPicked(picked));
        }
      },
      validator: (_) => null, // not required
    );
  }

  Widget _gap() => const SizedBox(height: 12);

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    final steps = <Step>[
      // Step 0: सामान्य विवरण
      Step(
        title: const Text('सामान्य'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            buildRelationDropdown(),
            _gap(),
            Row(
              children: [
                Expanded(child: buildTextField("प्रथम नाम", controller: firstNameController)),
                const SizedBox(width: 12),
                Expanded(child: buildTextField("उपनाम", controller: lastNameController)),
              ],
            ),
            _gap(),
            Row(
              children: [
                Expanded(child: buildTextField("पिता / पति का नाम", controller: guardianNameController)),
                const SizedBox(width: 12),
                Expanded(
                  child: buildDropdown("लिंग", genders, selectedGender, (val) {
                    setState(() => selectedGender = val);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),

      // Step 1: शिक्षा व जन्म विवरण
      Step(
        title: const Text('शिक्षा'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: buildDatePicker("जन्म तिथि", selectedDOB, (val) => selectedDOB = val),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildDropdown("शिक्षा", educations, selectedEducation, (val) {
                    setState(() => selectedEducation = val);
                  }),
                ),
              ],
            ),
            _gap(),
            buildDropdown("व्यवसाय", professions, selectedProfession, (val) {
              setState(() => selectedProfession = val);
            }),
          ],
        ),
      ),

      // Step 2: पता विवरण
      Step(
        title: const Text('पता'),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            buildDropdown("पते का प्रकार", jobTypes, selectedJobType, (val) {
              setState(() => selectedJobType = val);
            }),
            _gap(),
            Row(
              children: [
                Expanded(child: buildTextField("पता 1", controller: address1Controller)),
                const SizedBox(width: 12),
                Expanded(child: buildTextField("पता 2", controller: address2Controller)),
              ],
            ),
            _gap(),
            Row(
              children: [
                Expanded(child: buildTextField("पोस्ट", controller: postController)),
                const SizedBox(width: 12),
                Expanded(child: buildTextField("शहर", controller: cityController)),
              ],
            ),
            _gap(),
            Row(
              children: [
                Expanded(child: buildTextField("जिला", controller: districtController)),
                const SizedBox(width: 12),
                Expanded(
                  child: buildTextField(
                    "पिन कोड",
                    controller: pinCodeController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            _gap(),
            DropdownButtonFormField<Country>(
              isExpanded: true,
              value: selectedCountryModel,
              items: countryList
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (Country? newValue) {
                setState(() {
                  selectedCountryModel = newValue;
                  selectedStateModel = null;
                  stateList = [];
                });
                if (newValue != null) fetchStates(newValue.iso2);
              },
              decoration: InputDecoration(
                labelText: 'देश',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (_) => null,
            ),
            _gap(),
            DropdownButtonFormField<StateModel>(
              isExpanded: true,
              value: selectedStateModel,
              items: stateList
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (StateModel? newValue) {
                setState(() => selectedStateModel = newValue);
              },
              decoration: InputDecoration(
                labelText: 'राज्य',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (_) => null,
            ),
            _gap(),
            Row(
              children: [
                Expanded(child: buildTextField("मूल शहर", controller: originCityController)),
                const SizedBox(width: 12),
                Expanded(child: buildTextField("मूल राज्य", controller: originStateController)),
              ],
            ),
          ],
        ),
      ),

      // Step 3: संपर्क/आधार/धर्म
      Step(
        title: const Text('अन्य'),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    "मोबाइल",
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildTextField(
                    "अन्य वैकल्पिक फोन नंबर",
                    controller: alternateNumberController,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            _gap(),
            Row(
              children: [
                Expanded(
                  child: buildDropdown("WhatsApp Status", whatsappStatus, selectedWhatsApp, (val) {
                    setState(() => selectedWhatsApp = val);
                  }),
                ),
                const SizedBox(width: 12),
                if (selectedWhatsApp == 'हाँ')
                  Expanded(
                    child: buildTextField(
                      "WhatsApp नंबर",
                      controller: whatsappNumberController,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
              ],
            ),
            _gap(),
            buildTextField("ईमेल", controller: emailController, keyboardType: TextInputType.emailAddress),
            _gap(),
            Row(
              children: [
                Expanded(child: buildTextField("नाम (आधार अनुसार)", controller: adharNameController)),
                const SizedBox(width: 12),
                Expanded(child: buildTextField("पिता का नाम (आधार अनुसार)", controller: adharFatherNameController)),
              ],
            ),
            _gap(),
            buildTextField(
              "आधार कार्ड नंबर",
              controller: adharController,
              keyboardType: TextInputType.number,
            ),
            _gap(),
            buildDropdown("धार्मिक मान्यता", religions, selectedReligion, (val) {
              setState(() => selectedReligion = val);
            }),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("सामान्य विवरण"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_message != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                decoration: BoxDecoration(
                  color: _msgColor.withOpacity(0.1),
                  border: Border.all(color: _msgColor, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _msgColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                steps: steps,
                onStepTapped: (index) {
                  setState(() => _currentStep = index);
                },
                controlsBuilder: (context, details) {
                  final isLast = _currentStep == steps.length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back'),
                            onPressed: () {
                              setState(() => _currentStep -= 1);
                            },
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                            label: Text(isLast ? "सबमिट करें" : "Next"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              if (!isLast) {
                                setState(() => _currentStep += 1);
                              } else {
                                await updateMemberDetails();
                              }
                            },
                          ),
                        ),
                      ],
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
}
