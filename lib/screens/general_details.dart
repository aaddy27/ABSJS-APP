// general_details.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// BaseScaffold: adjust relative path if your project places it elsewhere.
import 'base_scaffold.dart';

// Step widgets (placed under lib/screens/general_details/)
import 'general_details/shiksha.dart';
import 'general_details/address.dart';
import 'general_details/other.dart';

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Relation && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country && runtimeType == other.runtimeType && iso2 == other.iso2;

  @override
  int get hashCode => iso2.hashCode;
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

  // Master lists (jobTypes mutable, so not final)
  final List<String> genders = ['पुरुष', 'महिला'];
  final List<String> educations = [
    "Less than SSC","SSC","HSC","CA","Doctor","Engineer","Software Engineer","LLB","MBA","PHD","Graduate","Post Graduate","Professional Degree","Other"
  ];
  final List<String> professions = [
    'Teacher','Engineer','Doctor','Housewife','Business','Farmer','CA','Advocate','Self Employed','Other'
  ];
  List<String> jobTypes = ['घर', 'व्यवसाये', 'Business', 'Other'];
  final List<String> whatsappStatus = ['हाँ', 'नहीं'];
  final List<String> religions = ['Sadhumargi', 'Jain', 'Other'];

  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];

  // Networking: single reusable client
  final http.Client _httpClient = http.Client();
  static const int _cacheTtlSeconds = 60 * 60 * 24; // 24 hours

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
    _httpClient.close();
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

    // Kick off fetches in parallel
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

  // Background JSON parse helper
  Future<dynamic> _parseJsonInBackground(String body) {
    return compute(jsonDecode, body);
  }

  // -------------------- API --------------------

  Future<void> fetchFamilyMembers(String familyId, String headMemberId) async {
    try {
      final url = Uri.parse('https://mrmapi.sadhumargi.in/api/family-members/$familyId');
      final response = await _httpClient.get(url, headers: {'member_id': headMemberId}).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final responseData = await _parseJsonInBackground(response.body) as Map<String, dynamic>;
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
      final response = await _httpClient.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        // DEBUG: show raw response to help map keys
        debugPrint('--- fetchMemberData response for $memberId ---');
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Raw body: ${response.body}');

        final map = await _parseJsonInBackground(response.body) as Map<String, dynamic>;
        // DEBUG: print parsed keys and some important fields
        debugPrint('Parsed keys: ${map.keys.toList()}');
        debugPrint('first_name: ${map['first_name']}, origin_city: ${map['origin_city']}, address_type: ${map['address_type']}');

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
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cache_countries');
      final ts = prefs.getInt('cache_countries_ts') ?? 0;
      final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

      // If cached and not expired -> load from cache (deduped), then refresh in background
      if (cached != null && (now - ts) < _cacheTtlSeconds) {
        final List data = jsonDecode(cached);
        if (!mounted) return;
        // dedupe by iso2 while preserving order
        final seen = <String>{};
        final deduped = <Country>[];
        for (final e in data) {
          final c = Country.fromJson(Map<String, dynamic>.from(e));
          if (!seen.contains(c.iso2)) {
            seen.add(c.iso2);
            deduped.add(c);
          }
        }
        setState(() => countryList = deduped);
        // refresh in background (non-blocking)
        _refreshCountriesInBackground();
        return;
      }

      final uri = Uri.parse('https://api.countrystatecity.in/v1/countries');
      final response = await _httpClient
          .get(uri, headers: {'X-CSCAPI-KEY': 'S2dBYnJldWtmRFM4U2VUdG9Fd0hiRXp2RjhpTm81YlhVVThiWEdiTA=='})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final parsed = await _parseJsonInBackground(response.body);
        final rawList = List.from(parsed);

        // dedupe by iso2 while preserving order
        final seen = <String>{};
        final deduped = <Country>[];
        for (final e in rawList) {
          final c = Country.fromJson(Map<String, dynamic>.from(e));
          if (!seen.contains(c.iso2)) {
            seen.add(c.iso2);
            deduped.add(c);
          }
        }

        if (!mounted) return;
        setState(() => countryList = deduped);

        // cache original raw list and ts
        final prefs2 = await SharedPreferences.getInstance();
        prefs2.setString('cache_countries', jsonEncode(rawList));
        prefs2.setInt('cache_countries_ts', now);
      } else {
        _toast(context, 'देश सूची लोड नहीं हो सकी: ${response.statusCode}', color: Colors.red);
      }
    } catch (e) {
      _toast(context, 'देश सूची में नेटवर्क समस्या', color: Colors.red);
    }
  }

  Future<void> _refreshCountriesInBackground() async {
    try {
      final uri = Uri.parse('https://api.countrystatecity.in/v1/countries');
      final response = await _httpClient
          .get(uri, headers: {'X-CSCAPI-KEY': 'S2dBYnJldWtmRFM4U2VUdG9Fd0hiRXp2RjhpTm81YlhVVThiWEdiTA=='})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final parsed = await _parseJsonInBackground(response.body);
        final rawList = List.from(parsed);

        // update cache
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        prefs.setString('cache_countries', jsonEncode(rawList));
        prefs.setInt('cache_countries_ts', now);

        // dedupe and set state
        final seen = <String>{};
        final deduped = <Country>[];
        for (final e in rawList) {
          final c = Country.fromJson(Map<String, dynamic>.from(e));
          if (!seen.contains(c.iso2)) {
            seen.add(c.iso2);
            deduped.add(c);
          }
        }
        if (!mounted) return;
        setState(() => countryList = deduped);
      }
    } catch (_) {
      // ignore silently - background refresh
    }
  }

  Future<void> fetchRelations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cache_relations');
      final ts = prefs.getInt('cache_relations_ts') ?? 0;
      final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

      if (cached != null && (now - ts) < _cacheTtlSeconds) {
        final List data = jsonDecode(cached);
        if (!mounted) return;
        // dedupe by id while preserving order
        final seen = <int>{};
        final deduped = <Relation>[];
        for (final e in data) {
          final r = Relation.fromJson(Map<String, dynamic>.from(e));
          if (!seen.contains(r.id)) {
            seen.add(r.id);
            deduped.add(r);
          }
        }
        setState(() => relationList = deduped);
        _refreshRelationsInBackground();
        return;
      }

      final uri = Uri.parse('https://mrmapi.sadhumargi.in/api/relations');
      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final parsed = await _parseJsonInBackground(response.body);
        final list = List.from(parsed);
        // dedupe
        final seen = <int>{};
        final deduped = <Relation>[];
        for (final e in list) {
          final r = Relation.fromJson(Map<String, dynamic>.from(e));
          if (!seen.contains(r.id)) {
            seen.add(r.id);
            deduped.add(r);
          }
        }
        if (!mounted) return;
        setState(() => relationList = deduped);
        prefs.setString('cache_relations', jsonEncode(list));
        prefs.setInt('cache_relations_ts', now);
      } else {
        _toast(context, "रिश्ते लोड नहीं हो सके: ${response.statusCode}", color: Colors.red);
      }
    } catch (e) {
      _toast(context, "रिश्ते लोड करने में नेटवर्क समस्या", color: Colors.red);
    }
  }

  Future<void> _refreshRelationsInBackground() async {
    try {
      final uri = Uri.parse('https://mrmapi.sadhumargi.in/api/relations');
      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final parsed = await _parseJsonInBackground(response.body);
        final list = List.from(parsed);
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        prefs.setString('cache_relations', jsonEncode(list));
        prefs.setInt('cache_relations_ts', now);
        // dedupe and set state
        final seen = <int>{};
        final deduped = <Relation>[];
        for (final e in list) {
          final r = Relation.fromJson(Map<String, dynamic>.from(e));
          if (!seen.contains(r.id)) {
            seen.add(r.id);
            deduped.add(r);
          }
        }
        if (!mounted) return;
        setState(() => relationList = deduped);
      }
    } catch (_) {}
  }

  Future<void> fetchStates(String iso2) async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('https://api.countrystatecity.in/v1/countries/$iso2/states'),
            headers: {'X-CSCAPI-KEY': 'S2dBYnJldWtmRFM4U2VUdG9Fd0hiRXp2RjhpTm81YlhVVThiWEdiTA=='},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final parsed = await _parseJsonInBackground(response.body);
        final List data = List.from(parsed);
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

    // DEBUG: show incoming keys briefly
    debugPrint('--- _populateForm incoming keys: ${data.keys.toList()}');

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

      // origin fields
      originCityController.text = (data['origin_city'] ?? data['originCity'] ?? '').toString();
      originStateController.text = (data['origin_state'] ?? data['originState'] ?? '').toString();

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
      // removed old direct assignment for selectedJobType - handled below (outside setState)
      selectedReligion = religions.contains(data['rel_faith']) ? data['rel_faith'] : null;
      selectedWhatsApp = ((data['whatsapp_number'] ?? '').toString().isNotEmpty) ? 'हाँ' : 'नहीं';
      selectedDOB = data['birth_day'] != null ? DateTime.tryParse(data['birth_day'].toString()) : null;
    });

    // handle address_type (map API -> local display, ensure dropdown contains it)
    try {
      final apiAddrType = (data['address_type'] ?? data['addressType'] ?? '').toString();
      debugPrint('API provided address_type: $apiAddrType');
      if (apiAddrType.isNotEmpty) {
        final local = _apiToLocalAddressType(apiAddrType);
        if (!jobTypes.contains(local)) {
          setState(() {
            jobTypes.insert(0, local);
            selectedJobType = local;
          });
        } else {
          setState(() {
            selectedJobType = local;
          });
        }
      } else {
        // if API didn't provide, keep existing selectedJobType as-is (or null)
      }
    } catch (e) {
      debugPrint('Error handling address_type in _populateForm: $e');
    }

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

  // Helper: map localized dropdown value -> API value
  String? _localToApiAddressType(String? local) {
    if (local == null) return null;
    switch (local) {
      case 'घर':
      case 'Residential':
        return 'Residential';
      case 'व्यवसाये':
      case 'Business':
        return 'Business';
      case 'Other':
      case 'अन्य':
        return 'Other';
      default:
        return local;
    }
  }

  // Helper: map API value -> local display
  String _apiToLocalAddressType(String api) {
    switch (api) {
      case 'Residential':
        return 'घर';
      case 'Business':
        return 'व्यवसाये';
      case 'Other':
        return 'Other';
      default:
        return api;
    }
  }

  Future<void> updateMemberDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final memberIdToUpdate = _isHeadOfFamily ? _selectedFamilyMember?.memberId : _loggedInMemberId;
    if (token.isEmpty || memberIdToUpdate == null || memberIdToUpdate.isEmpty) {
      setState(() {
        _bannerMsg = '🔑 सदस्य आईडी या लॉगिन टोकन गायब है।';
        _bannerColor = Colors.red;
      });
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
      // send API-friendly address_type
      "address_type": _localToApiAddressType(selectedJobType),
      "address": address1Controller.text.isEmpty ? null : address1Controller.text,
      "address2": address2Controller.text.isEmpty ? null : address2Controller.text,
      "post": postController.text.isEmpty ? null : postController.text,
      "city": cityController.text.isEmpty ? null : cityController.text,
      "district": districtController.text.isEmpty ? null : districtController.text,
    };

    // DEBUG: print request body (remove sensitive fields as needed)
    debugPrint('--- updateMemberDetails request for member: $memberIdToUpdate ---');
    debugPrint(jsonEncode(body));

    setState(() => _isSaving = true);
    try {
      final url = Uri.parse('https://mrmapi.sadhumargi.in/api/member/$memberIdToUpdate/update');
      debugPrint('POST $url');

      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 20));

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      dynamic parsed;
      try {
        parsed = jsonDecode(response.body);
      } catch (_) {
        parsed = null;
      }

      if (response.statusCode == 200) {
        final message = parsed is Map && parsed['message'] != null ? parsed['message'].toString() : 'सर्वर ने 200 भेजा।';
        final successFlag = parsed is Map && (parsed['success'] == true || parsed['status'] == 'success');

        if (successFlag || parsed == null) {
          setState(() {
            _bannerMsg = message;
            _bannerColor = Colors.green;
          });
          _toast(context, _bannerMsg!, color: Colors.green);

          // REFRESH: fetch updated data from server to reflect stored values
          await fetchMemberData(memberIdToUpdate);
        } else {
          setState(() {
            _bannerMsg = message;
            _bannerColor = Colors.orange;
          });
          _toast(context, _bannerMsg!, color: Colors.orange);
        }
      } else if (response.statusCode == 422 || response.statusCode == 400) {
        String msg = 'वैलिडेशन त्रुटि: ${response.statusCode}';
        if (parsed is Map && parsed['errors'] != null) {
          msg = parsed['message'] ?? parsed['errors'].toString();
        } else if (parsed is Map && parsed['message'] != null) {
          msg = parsed['message'];
        } else {
          msg = response.body;
        }
        setState(() {
          _bannerMsg = '❌ $msg';
          _bannerColor = Colors.red;
        });
        _toast(context, _bannerMsg!, color: Colors.red);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() {
          _bannerMsg = 'प्राधिकरण समस्या: कृपया लॉगिन पुनः करें। (${response.statusCode})';
          _bannerColor = Colors.red;
        });
        _toast(context, _bannerMsg!, color: Colors.red);
      } else {
        String msg = 'सर्वर त्रुटि: ${response.statusCode}';
        if (parsed is Map && parsed['message'] != null) msg = parsed['message'];
        setState(() {
          _bannerMsg = '❌ $msg';
          _bannerColor = Colors.red;
        });
        _toast(context, _bannerMsg!, color: Colors.red);
      }
    } catch (e, st) {
      debugPrint('Exception in updateMemberDetails: $e\n$st');
      setState(() {
        _bannerMsg = '❌ सहेजने में त्रुटि हुई: $e';
        _bannerColor = Colors.red;
      });
      _toast(context, _bannerMsg!, color: Colors.red);
    } finally {
      if (!mounted) return;
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

  // Validators - optional (none required)
  String? _req(String? v) => null;
  String? _mobile10(String? v) {
    final s = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (s.isEmpty) return null; // allow empty
    if (s.length != 10) return '10 अंकों का मोबाइल';
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

  // Steps now use imported widgets for modularity
  List<Step> _steps() => [
        Step(
          title: const Text('सामान्य'),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          content: _stepGeneral(),
        ),
        Step(
          title: const Text('शिक्षा'),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          content: ShikshaStep(
            formKey: _formKeys[1],
            selectedDOB: selectedDOB,
            onDobChanged: (d) => setState(() => selectedDOB = d),
            educations: educations,
            selectedEducation: selectedEducation,
            onEducationChanged: (v) => setState(() => selectedEducation = v),
            professions: professions,
            selectedProfession: selectedProfession,
            onProfessionChanged: (v) => setState(() => selectedProfession = v),
          ),
        ),
        Step(
          title: const Text('पता'),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          content: AddressStep(
            formKey: _formKeys[2],
            address1Controller: address1Controller,
            address2Controller: address2Controller,
            postController: postController,
            cityController: cityController,
            districtController: districtController,
            pinCodeController: pinCodeController,
            originCityController: originCityController,
            originStateController: originStateController,
            selectedJobType: selectedJobType,
            jobTypes: jobTypes,
            onJobTypeChanged: (v) => setState(() => selectedJobType = v),
            countryList: countryList,
            selectedCountryModel: selectedCountryModel,
            stateList: stateList,
            selectedStateModel: selectedStateModel,
            onCountryChanged: (c) {
              setState(() {
                selectedCountryModel = c;
                selectedStateModel = null;
                stateList = [];
              });
              if (c != null) fetchStates(c.iso2);
            },
            onStateChanged: (s) => setState(() => selectedStateModel = s),
            onPinChanged: (s) {},
          ),
        ),
        Step(
          title: const Text('अन्य'),
          isActive: _currentStep >= 3,
          state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          content: OtherStep(
            formKey: _formKeys[3],
            mobileController: mobileController,
            alternateNumberController: alternateNumberController,
            whatsappNumberController: whatsappNumberController,
            emailController: emailController,
            adharNameController: adharNameController,
            adharFatherNameController: adharFatherNameController,
            adharController: adharController,
            selectedWhatsApp: selectedWhatsApp,
            whatsappStatus: whatsappStatus,
            onWhatsAppChanged: (v) {
              setState(() {
                selectedWhatsApp = v;
                if (v == 'हाँ' && whatsappNumberController.text.isEmpty) {
                  whatsappNumberController.text = mobileController.text;
                } else if (v == 'नहीं') {
                  whatsappNumberController.clear();
                }
              });
            },
            selectedReligion: selectedReligion,
            religions: religions,
            onReligionChanged: (v) => setState(() => selectedReligion = v),
            onMobileChanged: (s) {
              if (selectedWhatsApp == 'हाँ' && whatsappNumberController.text.isEmpty) {
                whatsappNumberController.text = s ?? '';
              }
            },
            mobileValidator: _mobile10,
            aadhaarValidator: _aadhaar12,
            emailValidator: _email,
          ),
        ),
      ];

  Widget _stepGeneral() {
    return Form(
      key: _formKeys[0],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
       DropdownButtonFormField<Relation>(
  isDense: true,
  isExpanded: true,
  value: relationList.contains(selectedRelationModel) ? selectedRelationModel : null,
  items: relationList.map((r) => DropdownMenuItem(value: r, child: Text("${r.relationUtf8} (${r.relation})"))).toList(),
  onChanged: (v) => setState(() => selectedRelationModel = v),
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
              decoration: _dec("लिंग", icon: const Icon(Icons.wc)),
            ),
          ),
        ]),
      ]),
    );
  }

  bool _validateCurrentStep() {
    final key = _formKeys[_currentStep];
    final valid = key.currentState?.validate() ?? true;
    if (!valid) _toast(context, "कृपया आवश्यक फ़ील्ड भरें", color: Colors.orange);
    return valid;
  }

  @override
  Widget build(BuildContext context) {
    // Build the content that previously was in Scaffold.body
    final content = SafeArea(
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
                    steps: _steps(),
                    onStepTapped: (i) {
                      if (i <= _currentStep || _validateCurrentStep()) {
                        setState(() => _currentStep = i);
                      }
                    },
                    // ← custom controls: Back / Next / Submit
                    controlsBuilder: (BuildContext context, ControlsDetails details) {
                      final isLast = _currentStep == _steps().length - 1;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                                icon: isLast
                                    ? (_isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check))
                                    : const Icon(Icons.arrow_forward),
                                label: Text(isLast ? "सबमिट करें" : "Next"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _isSaving
                                    ? null
                                    : () async {
                                        if (!isLast) {
                                          if (_validateCurrentStep()) setState(() => _currentStep += 1);
                                        } else {
                                          final allValid = _formKeys.every((k) => (k.currentState?.validate() ?? true));
                                          if (!allValid) {
                                            _toast(context, "कृपया सभी आवश्यक फ़ील्ड भरें", color: Colors.orange);
                                            return;
                                          }
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
    );

    // Use BaseScaffold so AppBar + BottomNav come from there.
    // selectedIndex set to -1 (you can change to appropriate tab).
    return BaseScaffold(selectedIndex: -1, body: content);
  }
}

// -------------------- Skeleton Loader --------------------

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  Widget _bar() => Container(
        height: 16,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
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
