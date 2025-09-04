import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// -------------------- Models --------------------

class FamilyMember {
  final int id;
  final String memberId; // API ID
  final String name;

  FamilyMember({required this.id, required this.memberId, required this.name});

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final firstName = (json['first_name'] ?? '').toString().trim();
    final lastName = (json['last_name'] ?? '').toString().trim();
    return FamilyMember(
      id: json['id'] ?? 0,
      memberId: json['member_id']?.toString() ?? '',
      name: [firstName, lastName].where((e) => e.isNotEmpty).join(' '),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyMember && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Relation {
  final int id;
  final String relationUtf8;
  final String relation;

  Relation({required this.id, required this.relationUtf8, required this.relation});

  factory Relation.fromJson(Map<String, dynamic> json) {
    return Relation(
      id: json['id'] ?? 0,
      relationUtf8: (json['relation_utf8'] ?? '').toString(),
      relation: (json['relation'] ?? '').toString(),
    );
  }
}

class Country {
  final String name;
  final String iso2;

  Country({required this.name, required this.iso2});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: (json['name'] ?? '').toString(),
      iso2: (json['iso2'] ?? '').toString(),
    );
  }
}

class StateModel {
  final String name;

  StateModel({required this.name});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(name: (json['name'] ?? '').toString());
  }
}

// -------------------- Helpers --------------------

class AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 12; i++) {
      if (i != 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

InputDecoration _dec(String label, {String? hint, Widget? icon}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon,
    filled: true,
    isDense: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}

void _toast(BuildContext context, String msg, {Color? color}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: color),
  );
}

Widget _sectionCard({required IconData icon, required String title, required Widget child, String? subtitle}) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 16, child: Icon(icon, size: 18)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
        const SizedBox(height: 14),
        child,
      ]),
    ),
  );
}

// -------------------- Screen --------------------
class GeneralDetails extends StatefulWidget {
  const GeneralDetails({super.key});

  @override
  State<GeneralDetails> createState() => _GeneralDetailsState();
}

class _GeneralDetailsState extends State<GeneralDetails> {
  int _currentStep = 0;
  bool _isHeadOfFamily = false;
  String? _loggedInMemberId;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _bannerMsg;
  Color _bannerColor = Colors.green;

  List<FamilyMember> _familyMembers = [];
  FamilyMember? _selectedFamilyMember;

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
    "Less than SSC","SSC","HSC","CA","Doctor","Engineer","Software Engineer","LLB","MBA","PHD","Graduate","Post Graduate","Professional Degree","Other"
  ];
  final List<String> professions = [
    'Teacher','Engineer','Doctor','Housewife','Business','Farmer','CA','Advocate','Self Employed','Other'
  ];
  final List<String> jobTypes = ['घर', 'व्यवसाये', 'Business', 'Other'];
  final List<String> whatsappStatus = ['हाँ', 'नहीं'];
  final List<String> religions = ['Sadhumargi', 'Jain', 'Other'];

  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];

  @override
  void initState() {
    super.initState();
    _initialize();
    mobileController.addListener(() {
      if (selectedWhatsApp == 'हाँ' && whatsappNumberController.text.isEmpty) {
        whatsappNumberController.text = mobileController.text;
      }
      setState(() {});
    });
    adharController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [
      firstNameController,lastNameController,guardianNameController,mobileController,whatsappNumberController,
      alternateNumberController,emailController,adharNameController,adharFatherNameController,adharController,
      originCityController,originStateController,address1Controller,address2Controller,postController,
      cityController,districtController,pinCodeController,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    await Future.wait([fetchCountries(), fetchRelations()]);

    final prefs = await SharedPreferences.getInstance();
    _isHeadOfFamily = prefs.getBool('is_head_of_family') ?? false;
    _loggedInMemberId = prefs.getString('member_id');
    final familyId = prefs.getString('family_id');

    try {
      if (_isHeadOfFamily && familyId != null && (_loggedInMemberId ?? '').isNotEmpty) {
        await fetchFamilyMembers(familyId, _loggedInMemberId!);
        final me = _familyMembers.firstWhere(
          (m) => m.memberId == _loggedInMemberId,
          orElse: () => FamilyMember(id: 0, memberId: '', name: ''),
        );
        if (me.name.isNotEmpty) _selectedFamilyMember = me;
        await fetchMemberData(_loggedInMemberId!);
      } else if ((_loggedInMemberId ?? '').isNotEmpty) {
        await fetchMemberData(_loggedInMemberId!);
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  // -------------------- API --------------------

  Future<void> fetchFamilyMembers(String familyId, String headMemberId) async {
    try {
      final url = Uri.parse('https://mrmapi.sadhumargi.in/api/family-members/$familyId');
      final response = await http.get(url, headers: {'member_id': headMemberId});
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final list = <Map<String, dynamic>>[];
        final headData = responseData['head'];
        if (headData is Map<String, dynamic>) list.add(headData);
        final membersList = responseData['members'];
        if (membersList is List) list.addAll(List<Map<String, dynamic>>.from(membersList));
        if (!mounted) return;
        setState(() { _familyMembers = list.map(FamilyMember.fromJson).toList(); });
      } else {
        _toast(context, "परिवार सूची लोड करने में समस्या: ${response.statusCode}", color: Colors.red);
      }
    } catch (e) {
      _toast(context, "परिवार सूची लोड नहीं हो सकी", color: Colors.red);
    }
  }

  Future<void> fetchMemberData(String memberId) async {
    if (memberId.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('https://mrmapi.sadhumargi.in/api/member/$memberId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final map = jsonDecode(response.body);
        await _populateForm(map);
      } else {
        _toast(context, "सदस्य डेटा लोड विफल: ${response.statusCode}", color: Colors.red);
      }
    } catch (e) {
      _toast(context, "नेटवर्क त्रुटि: सदस्य डेटा नहीं मिला", color: Colors.red);
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.countrystatecity.in/v1/countries'),
        headers: {'X-CSCAPI-KEY': 'S2dBYnJldWtmRFM4U2VUdG9Fd0hiRXp2RjhpTm81YlhVVThiWEdiTA=='},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() => countryList = data.map((e) => Country.fromJson(e)).toList());
      } else {
        _toast(context, 'देश सूची लोड नहीं हो सकी', color: Colors.red);
      }
    } catch (e) {
      _toast(context, 'देश सूची में नेटवर्क समस्या', color: Colors.red);
    }
  }

  Future<void> fetchRelations() async {
    try {
      final response = await http.get(Uri.parse('https://mrmapi.sadhumargi.in/api/relations'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() => relationList = data.map((e) => Relation.fromJson(e)).toList());
      } else {
        _toast(context, "रिश्ते लोड नहीं हो सके: ${response.statusCode}", color: Colors.red);
      }
    } catch (e) {
      _toast(context, "रिश्ते लोड करने में नेटवर्क समस्या", color: Colors.red);
    }
  }

  Future<void> fetchStates(String iso2) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.countrystatecity.in/v1/countries/$iso2/states'),
        headers: {'X-CSCAPI-KEY': 'S2dBYnJldWtmRFM4U2VUdG9Fd0hiRXp2RjhpTm81YlhVVThiWEdiTA=='},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() => stateList = data.map((e) => StateModel.fromJson(e)).toList());
      } else {
        _toast(context, 'राज्यों की सूची लोड नहीं हो सकी', color: Colors.red);
      }
    } catch (e) {
      _toast(context, 'राज्य सूची में नेटवर्क समस्या', color: Colors.red);
    }
  }

  // -------------------- Populate --------------------

  Future<void> _populateForm(Map<String, dynamic> data) async {
    Relation? matchedRelation;
    final relationId = data['relation_id'];
    if (relationList.isNotEmpty && relationId != null) {
      matchedRelation = relationList.firstWhere(
        (r) => r.id == relationId,
        orElse: () => Relation(id: 0, relationUtf8: '', relation: ''),
      );
    }

    setState(() {
      firstNameController.text = (data['first_name'] ?? '').toString();
      lastNameController.text = (data['last_name'] ?? '').toString();
      guardianNameController.text = (data['guardian_name'] ?? '').toString();

      mobileController.text = (data['mobile'] ?? '').toString();
      whatsappNumberController.text = (data['whatsapp_number'] ?? '').toString();
      alternateNumberController.text = (data['alternate_number'] ?? '').toString();

      emailController.text = (data['email_address'] ?? '').toString();

      adharNameController.text = (data['adhar_name'] ?? '').toString();
      adharFatherNameController.text = (data['adharfatherName'] ?? '').toString();

      final a1 = (data['adhar1'] ?? '').toString();
      final a2 = (data['adhar2'] ?? '').toString();
      final a3 = (data['adhar3'] ?? '').toString();
      final aadhaarRaw = (a1 + a2 + a3).replaceAll(RegExp(r'\D'), '');
      adharController.text = AadhaarInputFormatter().formatEditUpdate(
        const TextEditingValue(text: ''),
        TextEditingValue(text: aadhaarRaw),
      ).text;

      originCityController.text = (data['origin_city'] ?? '').toString();
      originStateController.text = (data['origin_state'] ?? '').toString();

      address1Controller.text = (data['address'] ?? '').toString();
      address2Controller.text = (data['address2'] ?? '').toString();
      postController.text = (data['post'] ?? '').toString();
      cityController.text = (data['city'] ?? '').toString();
      districtController.text = (data['district'] ?? '').toString();
      pinCodeController.text = (data['pincode'] ?? '').toString();

      selectedGender = mapGender((data['gender'] ?? '').toString());
      selectedRelationModel = (matchedRelation != null && matchedRelation.id != 0) ? matchedRelation : null;
      selectedEducation = educations.contains(data['education']) ? data['education'] : null;
      selectedProfession = professions.contains(data['occupation']) ? data['occupation'] : null;
      selectedJobType = jobTypes.contains(data['address_type']) ? data['address_type'] : null;
      selectedReligion = religions.contains(data['rel_faith']) ? data['rel_faith'] : null;
      selectedWhatsApp = ((data['whatsapp_number'] ?? '').toString().isNotEmpty) ? 'हाँ' : 'नहीं';
      selectedDOB = data['birth_day'] != null ? DateTime.tryParse(data['birth_day'].toString()) : null;
    });

    if (countryList.isNotEmpty && (data['country'] ?? '').toString().isNotEmpty) {
      Country? foundCountry;
      try {
        foundCountry = countryList.firstWhere(
          (c) => c.name.toLowerCase() == data['country'].toString().toLowerCase(),
        );
      } catch (_) {}
      if (foundCountry != null) {
        await fetchStates(foundCountry.iso2);
        StateModel? foundState;
        if ((data['state'] ?? '').toString().isNotEmpty) {
          try {
            foundState = stateList.firstWhere(
              (s) => s.name.toLowerCase() == data['state'].toString().toLowerCase(),
            );
          } catch (_) {}
        }
        if (!mounted) return;
        setState(() {
          selectedCountryModel = foundCountry;
          selectedStateModel = foundState;
        });
      }
    }
  }

  // -------------------- Submit --------------------

  Future<void> updateMemberDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final memberIdToUpdate = _isHeadOfFamily ? _selectedFamilyMember?.memberId : _loggedInMemberId;
    if (token.isEmpty || memberIdToUpdate == null || memberIdToUpdate.isEmpty) {
      setState(() { _bannerMsg = '🔑 सदस्य आईडी या लॉगिन टोकन गायब है।'; _bannerColor = Colors.red; });
      return;
    }

    final aadhaarDigits = adharController.text.replaceAll(RegExp(r'\D'), '');
    String a1 = '', a2 = '', a3 = '';
    if (aadhaarDigits.length >= 12) {
      a1 = aadhaarDigits.substring(0, 4);
      a2 = aadhaarDigits.substring(4, 8);
      a3 = aadhaarDigits.substring(8, 12);
    } else if (aadhaarDigits.length >= 8) {
      a1 = aadhaarDigits.substring(0, 4);
      a2 = aadhaarDigits.substring(4, 8);
      a3 = aadhaarDigits.substring(8);
    } else if (aadhaarDigits.length >= 4) {
      a1 = aadhaarDigits.substring(0, 4);
      a2 = aadhaarDigits.substring(4);
    } else if (aadhaarDigits.isNotEmpty) {
      a1 = aadhaarDigits;
    }

    final body = {
      "salution": "Kumar",
      "first_name": firstNameController.text.isEmpty ? null : firstNameController.text,
      "last_name": lastNameController.text.isEmpty ? null : lastNameController.text,
      "guardian_type": "Father",
      "guardian_name": guardianNameController.text.isEmpty ? null : guardianNameController.text,
      "relation": selectedRelationModel?.id,
      "gender": selectedGender == "पुरुष" ? "Male" : selectedGender == "महिला" ? "Female" : null,
      "birth_day": selectedDOB?.toIso8601String(),
      "education": selectedEducation,
      "occupation": selectedProfession,
      "country": selectedCountryModel?.name,
      "state": selectedStateModel?.name,
      "origin_city": originCityController.text.isEmpty ? null : originCityController.text,
      "origin_state": originStateController.text.isEmpty ? null : originStateController.text,
      "mobile": mobileController.text.isEmpty ? null : mobileController.text,
      "whatsapp_number": selectedWhatsApp == 'हाँ' ? whatsappNumberController.text : '',
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

    setState(() => _isSaving = true);
    try {
      final url = Uri.parse('https://mrmapi.sadhumargi.in/api/member/$memberIdToUpdate/update');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        setState(() { _bannerMsg = res['message'] ?? '✅ सफलतापूर्वक अपडेट किया गया'; _bannerColor = Colors.green; });
        _toast(context, _bannerMsg!, color: Colors.green);
      } else {
        setState(() { _bannerMsg = '❌ सर्वर से त्रुटि: ${response.statusCode}'; _bannerColor = Colors.red; });
        _toast(context, _bannerMsg!, color: Colors.red);
      }
    } catch (e) {
      setState(() { _bannerMsg = '❌ सहेजने में त्रुटि हुई'; _bannerColor = Colors.red; });
      _toast(context, _bannerMsg!, color: Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // -------------------- UI Pieces --------------------

  String? mapGender(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'male': return 'पुरुष';
      case 'female': return 'महिला';
      default: return null;
    }
  }

  Widget _familyPill() {
    return DropdownButtonFormField<FamilyMember>(
      isExpanded: true,
      value: _selectedFamilyMember,
      items: _familyMembers.map((m) => DropdownMenuItem(
        value: m,
        child: Row(children: [
          CircleAvatar(radius: 14, child: Text(m.name.isNotEmpty ? m.name[0] : '?')),
          const SizedBox(width: 8),
          Expanded(child: Text(m.name, overflow: TextOverflow.ellipsis)),
        ]),
      )).toList(),
      onChanged: (val) {
        if (val != null && val.id != _selectedFamilyMember?.id) {
          setState(() { _selectedFamilyMember = val; _bannerMsg = null; _currentStep = 0; });
          fetchMemberData(val.memberId);
        }
      },
      decoration: _dec("सदस्य चुनें", icon: const Icon(Icons.group)),
    );
  }

  // Validators
  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'आवश्यक' : null;
  String? _mobile10(String? v) {
    final s = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (s.isEmpty) return 'मोबाइल आवश्यक';
    if (s.length != 10) return '10 अंकों का मोबाइल';
    return null;
  }
  String? _pincode6(String? v) {
    final s = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (s.isEmpty) return null;
    if (s.length != 6) return '6 अंकों का पिन कोड';
    return null;
  }
  String? _email(String? v) {
    if ((v ?? '').isEmpty) return null;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim());
    return ok ? null : 'ईमेल सही नहीं है';
  }
  String? _aadhaar12(String? v) {
    final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return null;
    if (d.length != 12) return '12 अंकों का आधार';
    return null;
  }

  // Steps
  Widget _stepGeneral() {
    return Form(
      key: _formKeys[0],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        DropdownButtonFormField<Relation>(
          isDense: true,
          isExpanded: true,
          value: selectedRelationModel,
          items: relationList.map((r) => DropdownMenuItem(value: r, child: Text("${r.relationUtf8} (${r.relation})"))).toList(),
          onChanged: (v) => setState(() => selectedRelationModel = v),
          validator: (v) => v == null ? 'आवश्यक' : null,
          decoration: _dec("सदस्य का मुखिया से रिश्ता", icon: const Icon(Icons.link)),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: firstNameController,
              decoration: _dec("प्रथम नाम", icon: const Icon(Icons.person)),
              textInputAction: TextInputAction.next,
              validator: _req,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: lastNameController,
              decoration: _dec("उपनाम"),
              textInputAction: TextInputAction.next,
              validator: _req,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: guardianNameController,
              decoration: _dec("पिता / पति का नाम", icon: const Icon(Icons.badge)),
              textInputAction: TextInputAction.next,
              validator: _req,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: genders.contains(selectedGender) ? selectedGender : null,
              items: genders.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => selectedGender = v),
              validator: (v) => v == null ? 'आवश्यक' : null,
              decoration: _dec("लिंग", icon: const Icon(Icons.wc)),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _stepEducation() {
    return Form(
      key: _formKeys[1],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        Row(children: [
          Expanded(
            child: TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: selectedDOB == null ? '' : "${selectedDOB!.day}-${selectedDOB!.month}-${selectedDOB!.year}",
              ),
              decoration: _dec("जन्म तिथि", icon: const Icon(Icons.cake)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDOB ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => selectedDOB = picked);
              },
              validator: (_) => selectedDOB == null ? 'आवश्यक' : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: educations.contains(selectedEducation) ? selectedEducation : null,
              items: educations.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => selectedEducation = v),
              validator: (v) => v == null ? 'आवश्यक' : null,
              decoration: _dec("शिक्षा", icon: const Icon(Icons.school)),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: professions.contains(selectedProfession) ? selectedProfession : null,
          items: professions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => selectedProfession = v),
          validator: (v) => v == null ? 'आवश्यक' : null,
          decoration: _dec("व्यवसाय", icon: const Icon(Icons.work)),
        ),
      ]),
    );
  }

  Widget _stepAddress() {
    return Form(
      key: _formKeys[2],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: jobTypes.contains(selectedJobType) ? selectedJobType : null,
          items: jobTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => selectedJobType = v),
          validator: (v) => v == null ? 'आवश्यक' : null,
          decoration: _dec("पते का प्रकार", icon: const Icon(Icons.home_work)),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextFormField(controller: address1Controller, decoration: _dec("पता 1", icon: const Icon(Icons.location_on)), validator: _req)),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(controller: address2Controller, decoration: _dec("पता 2"))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextFormField(controller: postController, decoration: _dec("पोस्ट"))),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(controller: cityController, decoration: _dec("शहर"))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextFormField(controller: districtController, decoration: _dec("जिला"))),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: pinCodeController,
              decoration: _dec("पिन कोड"),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              validator: _pincode6,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        DropdownButtonFormField<Country>(
          isExpanded: true,
          value: selectedCountryModel,
          items: countryList.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
          onChanged: (c) {
            setState(() {
              selectedCountryModel = c;
              selectedStateModel = null;
              stateList = [];
            });
            if (c != null) fetchStates(c.iso2);
          },
          validator: (v) => v == null ? 'आवश्यक' : null,
          decoration: _dec('देश', icon: const Icon(Icons.flag)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<StateModel>(
          isExpanded: true,
          value: selectedStateModel,
          items: stateList.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
          onChanged: (v) => setState(() => selectedStateModel = v),
          validator: (v) => v == null ? 'आवश्यक' : null,
          decoration: _dec('राज्य', icon: const Icon(Icons.map)),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextFormField(controller: originCityController, decoration: _dec("मूल शहर"))),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(controller: originStateController, decoration: _dec("मूल राज्य"))),
        ]),
      ]),
    );
  }

  Widget _stepOther() {
    return Form(
      key: _formKeys[3],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: mobileController,
              decoration: _dec("मोबाइल", icon: const Icon(Icons.phone)).copyWith(
                suffixIcon: mobileController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => setState(() => mobileController.clear()),
                        icon: Icon(Icons.clear), // <-- no const here
                      ),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              validator: _mobile10,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: alternateNumberController,
              decoration: _dec("वैकल्पिक फोन"),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: whatsappStatus.contains(selectedWhatsApp) ? selectedWhatsApp : null,
              items: whatsappStatus.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() {
                  selectedWhatsApp = v;
                  if (v == 'हाँ' && whatsappNumberController.text.isEmpty) {
                    whatsappNumberController.text = mobileController.text;
                  } else if (v == 'नहीं') {
                    whatsappNumberController.clear();
                  }
                });
              },
              validator: (v) => v == null ? 'आवश्यक' : null,
              decoration: _dec("WhatsApp Status", icon: const Icon(Icons.chat)), // <-- use chat icon
            ),
          ),
          const SizedBox(width: 12),
          if (selectedWhatsApp == 'हाँ')
            Expanded(
              child: TextFormField(
                controller: whatsappNumberController,
                decoration: _dec("WhatsApp नंबर"),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                validator: _mobile10,
              ),
            ),
        ]),
        const SizedBox(height: 12),
        TextFormField(
          controller: emailController,
          decoration: _dec("ईमेल", icon: const Icon(Icons.email)),
          keyboardType: TextInputType.emailAddress,
          validator: _email,
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextFormField(controller: adharNameController, decoration: _dec("नाम (आधार अनुसार)"))),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(controller: adharFatherNameController, decoration: _dec("पिता का नाम (आधार अनुसार)"))),
        ]),
        const SizedBox(height: 12),
        TextFormField(
          controller: adharController,
          decoration: _dec("आधार कार्ड नंबर", hint: "#### #### ####"),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12), AadhaarInputFormatter()],
          validator: _aadhaar12,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: religions.contains(selectedReligion) ? selectedReligion : null,
          items: religions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => selectedReligion = v),
          validator: (v) => v == null ? 'आवश्यक' : null,
          decoration: _dec("धार्मिक मान्यता", icon: const Icon(Icons.auto_awesome)),
        ),
      ]),
    );
  }

  List<Step> _steps() => [
        Step(title: const Text('सामान्य'), isActive: _currentStep >= 0, state: _currentStep > 0 ? StepState.complete : StepState.indexed, content: _stepGeneral()),
        Step(title: const Text('शिक्षा'), isActive: _currentStep >= 1, state: _currentStep > 1 ? StepState.complete : StepState.indexed, content: _stepEducation()),
        Step(title: const Text('पता'), isActive: _currentStep >= 2, state: _currentStep > 2 ? StepState.complete : StepState.indexed, content: _stepAddress()),
        Step(title: const Text('अन्य'), isActive: _currentStep >= 3, state: _currentStep > 3 ? StepState.complete : StepState.indexed, content: _stepOther()),
      ];

  bool _validateCurrentStep() {
    final key = _formKeys[_currentStep];
    final valid = key.currentState?.validate() ?? false;
    if (!valid) _toast(context, "कृपया आवश्यक फ़ील्ड भरें", color: Colors.orange);
    return valid;
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps();
    return Scaffold(
     appBar: AppBar(
  automaticallyImplyLeading: false,
  centerTitle: true, // center align
  toolbarHeight: 64, // a bit taller, looks premium
  title: const Text(
    "सामान्य विवरण",
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 28,          // bigger font
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
  ),
  backgroundColor: Colors.deepPurple,
  foregroundColor: Colors.white,
  // 👇 removed actions (refresh icon)
),

      body: SafeArea(
        child: Column(
          children: [
            if (_bannerMsg != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                decoration: BoxDecoration(
                  color: _bannerColor.withOpacity(0.1),
                  border: Border.all(color: _bannerColor, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_bannerMsg!, style: TextStyle(color: _bannerColor, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              ),
            if (_isHeadOfFamily)
              Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: _familyPill()),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const _Skeleton()
                  : Stepper(
                      type: StepperType.horizontal,
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      currentStep: _currentStep,
                      steps: steps,
                      onStepTapped: (i) {
                        if (i <= _currentStep || _validateCurrentStep()) {
                          setState(() => _currentStep = i);
                        }
                      },
                      controlsBuilder: (context, details) => const SizedBox.shrink(),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
          ),
          child: Row(
            children: [
              if (_currentStep > 0)
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : () => setState(() => _currentStep -= 1),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16)),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: _currentStep == steps.length - 1
                      ? (_isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check))
                      : const Icon(Icons.arrow_forward),
                  label: Text(_currentStep == steps.length - 1 ? "सबमिट करें" : "Next"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final isLast = _currentStep == steps.length - 1;
                          if (!isLast) {
                            if (_validateCurrentStep()) setState(() => _currentStep += 1);
                          } else {
                            final allValid = _formKeys.every((k) => (k.currentState?.validate() ?? false));
                            if (!allValid) { _toast(context, "कृपया सभी आवश्यक फ़ील्ड भरें", color: Colors.orange); return; }
                            await updateMemberDetails();
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- Skeleton Loader --------------------

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  Widget _bar() => Container(
        height: 16,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8), // ✅ FIXED
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: List.generate(10, (_) => _bar()),
    );
  }
}
