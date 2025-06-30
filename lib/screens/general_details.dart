import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


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

  // Dropdown lists
  List<String> relations = [ 'मुखिया','पुत्र','पुत्री','पति','पत्नी','भाई','बहन','पुत्र वधू','भाई की पत्नी','पौत्र','पौत्री','पर पोता','पर पोती', 'पौत्र वधू','पड़पौत्र वधू','भतीजा','बहतिजी','पिता','माता','चाचा जी / ताऊ जी/ फूफा जी','ताईजी/चाची जी/भूआ जी','दादा जी','दादी जी','नाना जी','नानी जी','मामा जी','ममी जी','भानजा','भांजी','अन्य'];
  List<String> genders = ['पुरुष', 'महिला'];
  List<String> educations = ['less than ssc', 'ssc', 'HSC','CA','DOCTOR','ENGINEER','SOFTWARE ENGINEER','LLB','MBA','PHD','Graduate', 'Postgraduate','PROFESSIONAL DEGREE','OTHER'];
  List<String> professions = ['Teacher', 'Engineer', 'Doctor'];
  List<String> jobTypes = ['घर', 'व्यवसाये', 'अन्य'];
  List<String> countries = ['भारत', 'नेपाल'];
  List<String> states = ['राजस्थान', 'महाराष्ट्र', 'पंजाब'];
  List<String> whatsappStatus = ['हाँ', 'नहीं'];
  List<String> religions = ['जैन', 'साधुमार्गी ', 'अन्य'];

   @override
  void initState() {
    super.initState();
    fetchMemberData();
  }

  Future<void> fetchMemberData() async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getString('member_id') ?? '';
    final url = Uri.parse('https://mrmapi.sadhumargi.in/api/member/$memberId');

  try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

         setState(() {
          firstNameController.text = data['first_name'] ?? '';
          lastNameController.text = data['last_name'] ?? '';
          guardianNameController.text = data['guardian_name'] ?? '';
          mobileController.text = data['mobile'] ?? '';
          whatsappNumberController.text = data['whatsapp_number'] ?? '';
          alternateNumberController.text = data['alternate_number'] ?? '';
          emailController.text = data['email_address'] ?? '';
          adharNameController.text = data['adhar_name'] ?? '';
          adharFatherNameController.text = data['adharfatherName'] ?? '';
          adharController.text = "${data['adhar1'] ?? ''}${data['adhar2'] ?? ''}${data['adhar3'] ?? ''}";
          originCityController.text = data['origin_city'] ?? '';
          originStateController.text = data['origin_state'] ?? '';
          address1Controller.text = data['address'] ?? '';
          address2Controller.text = data['address2'] ?? '';
          postController.text = data['post'] ?? '';
          cityController.text = data['city'] ?? '';
          districtController.text = data['district'] ?? '';
          pinCodeController.text = data['pin_code']?.toString() ?? '';
          countryController.text = data['country'] ?? '';
          stateController.text = data['state'] ?? '';

          selectedGender = mapGender(data['gender']);
          selectedRelation = mapRelation(data['relation_id']);
          selectedEducation = data['education'];
          selectedProfession = data['occupation'];
          selectedCountry = data['country'];
          selectedState = data['state'];
          selectedReligion = data['rel_faith'];
          selectedWhatsApp = (data['whatsapp_number'] != null && data['whatsapp_number'].toString().isNotEmpty) ? 'हाँ' : 'नहीं';


          
          if (data['birth_day'] != null) {
            selectedDOB = DateTime.tryParse(data['birth_day']);
          }
          if (data['marriage_day'] != null) {
            selectedMarriageDate = DateTime.tryParse(data['marriage_day']);
          }
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
                buildCard(buildDropdown("सदस्य का मुखिया से रिश्ता", relations,
                    selectedRelation, (val) {
                  setState(() => selectedRelation = val);
                })),
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
                buildCard(buildRow(
                    buildDropdown("देश", countries, selectedCountry, (val) {
                      setState(() => selectedCountry = val);
                    }),
                    buildDropdown("राज्य", states, selectedState, (val) {
                      setState(() => selectedState = val);
                    }))),
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
                sectionHeader(Icons.favorite, 'विवाहिक विवरण'),
                buildCard(buildDatePicker("विवाहिक तिथि",
                    selectedMarriageDate, (val) => selectedMarriageDate = val)),
                buildCard(
                    buildTextField("बच्चों की संख्या", keyboardType: TextInputType.number)),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("डेटा सफलतापूर्वक प्राप्त हुआ")),
                          );
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
