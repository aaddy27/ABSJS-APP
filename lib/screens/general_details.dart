import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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




class GeneralDetails extends StatefulWidget {
  const GeneralDetails({super.key});

  @override
  _GeneralDetailsState createState() => _GeneralDetailsState();
}

class _GeneralDetailsState extends State<GeneralDetails> {
  final _formKey = GlobalKey<FormState>();

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


List<Relation> relationList = [];
Relation? selectedRelationModel;

List<Country> countryList = [];
Country? selectedCountryModel;

List<StateModel> stateList = [];
StateModel? selectedStateModel;


  // Dropdown selected values
  String? selectedRelation,
      selectedGender,
      selectedEducation,
      selectedProfession,
      selectedJobType,
      selectedCountry,
      selectedState,
      selectedWhatsApp,
      selectedReligion;

  DateTime? selectedDOB, selectedMarriageDate;

Widget buildRelationDropdown() {
  return DropdownButtonFormField<Relation>(
    isExpanded: true,
    isDense: true,
    value: selectedRelationModel,
    items: relationList.map((relation) {
      return DropdownMenuItem(
        value: relation,
        child: Text("${relation.relationUtf8} (${relation.relation})"),
      );
    }).toList(),
    onChanged: (Relation? newValue) {
      setState(() {
        selectedRelationModel = newValue;
      });
    },
    decoration: InputDecoration(
      labelText: "सदस्य का मुखिया से रिश्ता",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
    validator: (value) => value == null ? 'कृपया चयन करें' : null,
  );
}
  // Dropdown lists

  List<String> genders = ['पुरुष', 'महिला'];
List<String> educations = [
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


List<String> professions = [
  'Teacher', 'Engineer', 'Doctor', 'Housewife', 'Business', 'Farmer', 'CA', 'Advocate', 'Self Employed', 'Other'
];
List<String> jobTypes = ['घर', 'व्यवसाये', 'Business', 'Other'];
  // List<String> countries = ['भारत', 'नेपाल'];
  // List<String> states = ['राजस्थान', 'महाराष्ट्र', 'पंजाब'];
  List<String> whatsappStatus = ['हाँ', 'नहीं'];
List<String> religions = [
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




Future<void> fetchRelations() async {
  try {
    final response = await http.get(Uri.parse('https://mrmapi.sadhumargi.in/api/relations'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        relationList = data.map((item) => Relation.fromJson(item)).toList();
      });
    } else {
      print("Failed to load relations: ${response.statusCode}");
    }
  } catch (e) {
    print("Error loading relations: $e");
  }
}

List<Country> countryModels = [];

Future<void> fetchCountries() async {
  final response = await http.get(
    Uri.parse('https://api.countrystatecity.in/v1/countries'),
    headers: {
      'X-CSCAPI-KEY': 'S2dBYnJldWtmRFM4U2VUdG9Fd0hiRXp2RjhpTm81YlhVVThiWEdiTA==',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    setState(() {
      countryList = data.map((item) => Country.fromJson(item)).toList(); // FIXED
    });
  } else {
    print('Failed to load countries');
  }
}


List<StateModel> stateModels = [];

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
        stateList = data.map((item) => StateModel.fromJson(item)).toList(); // FIXED
      });
    } else {
      print('Failed to fetch states: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching states: $e');
  }
}


Future<void> updateMemberDetails() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final memberId = prefs.getString('member_id') ?? '';

  if (token.isEmpty || memberId.isEmpty) {
    print('🔴 Token or Member ID is missing!');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🔑 लॉगिन टोकन गायब है। कृपया पुनः लॉगिन करें।')),
    );
    return;
  }

  final url = Uri.parse('https://mrmapi.sadhumargi.in/api/member/$memberId/update');

 final body = {
  "salution": "Kumar", // If applicable
  "first_name": firstNameController.text,
  "last_name": lastNameController.text,
  "guardian_type": "Father", // or use a controller/dropdown if dynamic
  "guardian_name": guardianNameController.text,
  "relation": selectedRelationModel?.id,
  "gender": selectedGender == "पुरुष" ? "Male" : "Female",
  "birth_day": selectedDOB?.toIso8601String(),
  "education": selectedEducation,
  "occupation": selectedProfession,
  "country": selectedCountryModel?.name,  // ✅ Exactly here
  "state": selectedStateModel?.name,      // ✅ Exactly here
  "origin_city": originCityController.text,
  "origin_state": originStateController.text,
  "mobile": mobileController.text,
  "whatsapp_number": whatsappNumberController.text,
  "alternate_number": alternateNumberController.text,
  "email_address": emailController.text,
  "pincode": pinCodeController.text,
  "adhar_name": adharNameController.text,
  "adharfatherName": adharFatherNameController.text,
  "adhar1": adharController.text.substring(0, 4),
  "adhar2": adharController.text.substring(4, 8),
  "adhar3": adharController.text.substring(8),
  "religion": selectedReligion,
};


  try {
    final response = await http.post(
  url,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode(body), // 🔽 Your updated body with country/state name
);


    print("📥 Status Code: ${response.statusCode}");
    print("📥 Body: ${response.body}");

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'सफलतापूर्वक अपडेट किया गया')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ सर्वर से त्रुटि: ${response.statusCode}')),
      );
    }
  } catch (e) {
    print("❌ Exception while updating: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ सहेजने में त्रुटि हुई')),
    );
  }
}


Future<void> fetchMemberData() async {
  final prefs = await SharedPreferences.getInstance();
  final memberId = prefs.getString('member_id') ?? '';
  final url = Uri.parse('https://mrmapi.sadhumargi.in/api/member/$memberId');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      /// Get relation from relationList using relation_id
      Relation? matchedRelation;
      final relationIdFromApi = data['relation_id'];
      if (relationList.isNotEmpty && relationIdFromApi != null) {
        matchedRelation = relationList.firstWhere(
          (relation) => relation.id == relationIdFromApi,
          orElse: () => Relation(id: 0, relationUtf8: '', relation: ''),
        );
      }

      setState(() {
        // 📝 Name Details
        firstNameController.text = data['first_name'] ?? '';
        lastNameController.text = data['last_name'] ?? '';
        guardianNameController.text = data['guardian_name'] ?? '';

        // 📝 Contact
        mobileController.text = data['mobile'] ?? '';
        whatsappNumberController.text = data['whatsapp_number'] ?? '';
        alternateNumberController.text = data['alternate_number'] ?? '';
        emailController.text = data['email_address'] ?? '';

        // 📝 Aadhaar
        adharNameController.text = data['adhar_name'] ?? '';
        adharFatherNameController.text = data['adharfatherName'] ?? '';
        adharController.text = "${data['adhar1'] ?? ''}${data['adhar2'] ?? ''}${data['adhar3'] ?? ''}";

        // 📝 Address
        originCityController.text = data['origin_city'] ?? '';
        originStateController.text = data['origin_state'] ?? '';
        address1Controller.text = data['address'] ?? '';
        address2Controller.text = data['address2'] ?? '';
        postController.text = data['post'] ?? '';
        cityController.text = data['city'] ?? '';
        districtController.text = data['district'] ?? '';
        pinCodeController.text = data['pincode']?.toString() ?? '';  // Corrected: pincode
        countryController.text = data['country'] ?? '';
        stateController.text = data['state'] ?? '';

        // Dropdown Selections
  selectedGender = mapGender(data['gender']);  // पुरुष/महिला
  selectedRelationModel = (matchedRelation != null && matchedRelation.id != 0) ? matchedRelation : null;

  // ✅ Missing: Education, Occupation, Address Type, Religion
  selectedEducation = educations.contains(data['education']) ? data['education'] : null;
  selectedProfession = professions.contains(data['occupation']) ? data['occupation'] : null;
  selectedJobType = jobTypes.contains(data['address_type']) ? data['address_type'] : null;
  selectedReligion = religions.contains(data['rel_faith']) ? data['rel_faith'] : null;

  // ✅ Country & State (Double check if matching with your lists)
 selectedCountryModel = countryList.firstWhere(
          (country) => country.name.toLowerCase() == (data['country'] ?? '').toLowerCase(),
          orElse: () => Country(name: '', iso2: ''),
        );

selectedStateModel = stateList.firstWhere(
          (state) => state.name.toLowerCase() == (data['state'] ?? '').toLowerCase(),
          orElse: () => StateModel(name: ''),
        );

        // 📝 WhatsApp Status
        selectedWhatsApp = (data['whatsapp_number'] != null && data['whatsapp_number'].toString().isNotEmpty) ? 'हाँ' : 'नहीं';

        // 📝 Date Pickers
        if (data['birth_day'] != null) {
          selectedDOB = DateTime.tryParse(data['birth_day']);
        }

       

        // 📝 Children Count

      });
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching member data: $e");
  }
}



  /// Mapping gender from API to dropdown value
  String? mapGender(String? value) {
    switch (value?.toLowerCase()) {
      case 'male':
        return 'पुरुष';
      case 'female':
        return 'महिला';
      default:
        return 'अन्य';
    }
  }

  /// Mapping relation ID to string
  String? mapRelation(dynamic id) {
    switch (id) {
      case 1:
        return 'पिता';
      case 2:
        return 'माता';
      case 3:
        return 'भाई';
      case 4:
        return 'बहन';
      default:
        return null;
    }
  }

  Widget buildTextField(String label,
      {TextEditingController? controller, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'फील्ड भरना आवश्यक है' : null,
    );
  }

  Widget buildDropdown(String label, List<String> items, String? selectedValue,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
  isExpanded: true,
  isDense: true,
  value: items.contains(selectedValue) ? selectedValue : null,
  items: items
      .map((item) => DropdownMenuItem(value: item, child: Text(item)))
      .toList(),
  onChanged: onChanged,
  decoration: InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
  validator: (value) => value == null ? 'कृपया चयन करें' : null,
);

  }

  Widget buildDatePicker(
      String label, DateTime? selectedDate, Function(DateTime) onPicked) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      controller: TextEditingController(
          text: selectedDate == null
              ? ''
              : "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}"),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            onPicked(picked);
          });
        }
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'तिथि चुनें' : null,
    );
  }

  Widget buildRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget buildCard(Widget child) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: child,
      ),
    );
  }

  Widget sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.deepPurple),
          SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  resizeToAvoidBottomInset: true,
  appBar: AppBar(
    title: Text("सामान्य विवरण"),
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
  ),
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
                sectionHeader(Icons.person, 'सामान्य विवरण'),
               buildCard(buildRelationDropdown()),

                buildCard(buildRow(
                    buildTextField("प्रथम नाम",
                        controller: firstNameController),
                    buildTextField("उपनाम", controller: lastNameController))),
                buildCard(buildRow(
                    buildTextField("पिता / पति का नाम",
                        controller: guardianNameController),
                    buildDropdown("लिंग", genders, selectedGender, (val) {
                      setState(() => selectedGender = val);
                    }))),
                sectionHeader(Icons.school, 'शिक्षा व जन्म विवरण'),
                buildCard(buildRow(
                    buildDatePicker("जन्म तिथि", selectedDOB,
                        (val) => selectedDOB = val),
                    buildDropdown("शिक्षा", educations, selectedEducation,
                        (val) {
                      setState(() => selectedEducation = val);
                    }))),
                buildCard(buildDropdown("व्यवसाय", professions,
                    selectedProfession, (val) {
                  setState(() => selectedProfession = val);
                })),
                sectionHeader(Icons.location_city, 'पता विवरण'),
                buildCard(buildDropdown("पते का प्रकार", jobTypes,
                    selectedJobType, (val) {
                  setState(() => selectedJobType = val);
                })),
                buildCard(buildRow(
  buildTextField("पता 1", controller: address1Controller),
  buildTextField("पता 2", controller: address2Controller),
)),
buildCard(buildRow(
  buildTextField("पोस्ट", controller: postController),
  buildTextField("शहर", controller: cityController),
)),
buildCard(buildRow(
  buildTextField("जिला", controller: districtController),
  buildTextField("पिन कोड", controller: pinCodeController, keyboardType: TextInputType.number),
)),
buildCard(DropdownButtonFormField<Country>(
  isExpanded: true,
  value: selectedCountryModel?.name == '' ? null : selectedCountryModel,
  items: countryList.map((country) {
    return DropdownMenuItem(
      value: country,
      child: Text(country.name),
    );
  }).toList(),
  onChanged: (Country? newValue) {
    setState(() {
      selectedCountryModel = newValue;
      selectedStateModel = null;
      if (newValue != null) fetchStates(newValue.iso2);
    });
  },
  decoration: InputDecoration(
    labelText: 'देश',
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
  validator: (value) => value == null ? 'कृपया चयन करें' : null,
)),

buildCard(DropdownButtonFormField<StateModel>(
  isExpanded: true,
  value: selectedStateModel?.name == '' ? null : selectedStateModel,
  items: stateList.map((state) {
    return DropdownMenuItem(
      value: state,
      child: Text(state.name),
    );
  }).toList(),
  onChanged: (StateModel? newValue) {
    setState(() {
      selectedStateModel = newValue;
    });
  },
  decoration: InputDecoration(
    labelText: 'राज्य',
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
  validator: (value) => value == null ? 'कृपया चयन करें' : null,
)),
                buildCard(buildRow(
                    buildTextField("मूल शहर",
                        controller: originCityController),
                    buildTextField("मूल राज्य",
                        controller: originStateController))),
                sectionHeader(Icons.phone, 'संपर्क विवरण'),
                buildCard(buildRow(
                    buildTextField("मोबाइल *",
                        controller: mobileController,
                        keyboardType: TextInputType.phone),
                    buildTextField("अन्य वैकल्पिक फोन नंबर",
                        controller: alternateNumberController,
                        keyboardType: TextInputType.phone))),
                buildCard(buildRow(
                    buildDropdown("WhatsApp Status", whatsappStatus,
                        selectedWhatsApp, (val) {
                      setState(() => selectedWhatsApp = val);
                    }),
                    buildTextField("WhatsApp नंबर",
                        controller: whatsappNumberController,
                        keyboardType: TextInputType.phone))),
                buildCard(buildTextField("ईमेल",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress)),
              

                sectionHeader(Icons.credit_card, 'आधार विवरण'),
                buildCard(buildRow(
                    buildTextField("नाम (आधार अनुसार)",
                        controller: adharNameController),
                    buildTextField("पिता का नाम (आधार अनुसार)",
                        controller: adharFatherNameController))),
                buildCard(buildTextField("आधार कार्ड नंबर",
                    controller: adharController,
                    keyboardType: TextInputType.number)),
                sectionHeader(Icons.account_balance, 'धार्मिक जानकारी'),
                buildCard(buildDropdown("धार्मिक मान्यता", religions,
                    selectedReligion, (val) {
                  setState(() => selectedReligion = val);
                })),
                SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.check),
                      label:
                          Text("सबमिट करें", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
 onPressed: () {
  if (_formKey.currentState!.validate()) {
    updateMemberDetails();
  }
},
                   ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
