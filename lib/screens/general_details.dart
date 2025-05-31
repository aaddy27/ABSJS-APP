import 'package:flutter/material.dart';

class GeneralDetails extends StatefulWidget {
  const GeneralDetails({super.key});

  @override
  _GeneralDetailsState createState() => _GeneralDetailsState();
}

class _GeneralDetailsState extends State<GeneralDetails> {
  final _formKey = GlobalKey<FormState>();

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

  List<String> relations = ['पिता', 'माता', 'भाई', 'बहन'];
  List<String> genders = ['पुरुष', 'महिला', 'अन्य'];
  List<String> educations = ['10th', '12th', 'Graduate', 'Postgraduate'];
  List<String> professions = ['Teacher', 'Engineer', 'Doctor'];
  List<String> jobTypes = ['घर', 'व्यवसाये', 'अन्य'];
  List<String> countries = ['भारत', 'नेपाल'];
  List<String> states = ['राजस्थान', 'महाराष्ट्र', 'पंजाब'];
  List<String> whatsappStatus = ['हाँ', 'नहीं'];
  List<String> religions = ['जैन', 'हिन्दू', 'मुस्लिम'];

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

  Widget buildTextField(String label, {TextInputType? keyboardType}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'फील्ड भरना आवश्यक है' : null,
    );
  }

  Widget buildDropdown(
      String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
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
      validator: (value) => value == null || value.isEmpty ? 'तिथि चुनें' : null,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("सामान्य विवरण"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔷 सामान्य विवरण
                sectionHeader(Icons.person, 'सामान्य विवरण'),
                buildCard(buildDropdown("सदस्य का मुखिया से रिश्ता", relations, selectedRelation, (val) {
                  selectedRelation = val;
                })),
                buildCard(buildRow(buildTextField("प्रथम नाम"), buildTextField("उपनाम"))),
                buildCard(buildRow(
                    buildTextField("पिता / पति का नाम"),
                    buildDropdown("लिंग", genders, selectedGender, (val) {
                      selectedGender = val;
                    }))),

                /// 🔷 शिक्षा व जन्म विवरण
                sectionHeader(Icons.school, 'शिक्षा व जन्म विवरण'),
                buildCard(buildRow(
                    buildDatePicker("जन्म तिथि", selectedDOB, (val) => selectedDOB = val),
                    buildDropdown("शिक्षा", educations, selectedEducation, (val) => selectedEducation = val))),
                buildCard(buildDropdown("व्यवसाय", professions, selectedProfession, (val) => selectedProfession = val)),

                /// 🔷 पता विवरण
                sectionHeader(Icons.location_city, 'पता विवरण'),
                buildCard(buildDropdown("पते का प्रकार", jobTypes, selectedJobType, (val) => selectedJobType = val)),
                buildCard(buildRow(buildTextField("पता 1"), buildTextField("पता 2"))),
                buildCard(buildRow(buildTextField("पोस्ट"), buildTextField("शहर"))),
                buildCard(buildRow(buildTextField("जिला"), buildTextField("पिन कोड", keyboardType: TextInputType.number))),
                buildCard(buildRow(
                    buildDropdown("देश", countries, selectedCountry, (val) => selectedCountry = val),
                    buildDropdown("राज्य", states, selectedState, (val) => selectedState = val))),
                buildCard(buildRow(buildTextField("मूल शहर"), buildTextField("मूल राज्य"))),

                /// 🔷 संपर्क विवरण
                sectionHeader(Icons.phone, 'संपर्क विवरण'),
                buildCard(buildRow(
                    buildTextField("मोबाइल *", keyboardType: TextInputType.phone),
                    buildTextField("अन्य वैकल्पिक फोन नंबर", keyboardType: TextInputType.phone))),
                buildCard(buildRow(
                    buildDropdown("WhatsApp Status", whatsappStatus, selectedWhatsApp, (val) => selectedWhatsApp = val),
                    buildTextField("WhatsApp नंबर", keyboardType: TextInputType.phone))),
                buildCard(buildTextField("ईमेल", keyboardType: TextInputType.emailAddress)),

                /// 🔷 विवाहिक विवरण
                sectionHeader(Icons.favorite, 'विवाहिक विवरण'),
                buildCard(buildDatePicker("विवाहिक तिथि", selectedMarriageDate, (val) => selectedMarriageDate = val)),
                buildCard(buildTextField("बच्चों की संख्या", keyboardType: TextInputType.number)),

                /// 🔷 आधार विवरण
                sectionHeader(Icons.credit_card, 'आधार विवरण'),
                buildCard(buildRow(
                    buildTextField("नाम (आधार अनुसार)"),
                    buildTextField("पिता का नाम (आधार अनुसार)"))),
                buildCard(buildTextField("आधार कार्ड नंबर", keyboardType: TextInputType.number)),

                /// 🔷 धार्मिक जानकारी
                sectionHeader(Icons.account_balance, 'धार्मिक जानकारी'),
                buildCard(buildDropdown("धार्मिक मान्यता", religions, selectedReligion, (val) => selectedReligion = val)),

                /// 🔷 सबमिट बटन
                SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.check),
                      label: Text("सबमिट करें", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("डेटा (डमी) प्राप्त किया गया")),
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
