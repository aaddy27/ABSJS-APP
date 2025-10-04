// lib/screens/general_details/address.dart
import 'package:flutter/material.dart';

class AddressStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  // address fields controllers
  final TextEditingController address1Controller;
  final TextEditingController address2Controller;
  final TextEditingController postController;
  final TextEditingController cityController;
  final TextEditingController districtController;
  final TextEditingController pinCodeController;

  // NEW: origin controllers (मूल शहर / मूल राज्य)
  final TextEditingController originCityController;
  final TextEditingController originStateController;

  final String? selectedJobType;
  final List<String> jobTypes;
  final ValueChanged<String?> onJobTypeChanged;

  final List<dynamic> countryList; // Country objects
  final dynamic selectedCountryModel;
  final List<dynamic> stateList; // StateModel objects
  final dynamic selectedStateModel;
  final ValueChanged<dynamic> onCountryChanged;
  final ValueChanged<dynamic> onStateChanged;
  final ValueChanged<String?> onPinChanged;

  const AddressStep({
    super.key,
    required this.formKey,
    required this.address1Controller,
    required this.address2Controller,
    required this.postController,
    required this.cityController,
    required this.districtController,
    required this.pinCodeController,
    required this.originCityController,
    required this.originStateController,
    required this.selectedJobType,
    required this.jobTypes,
    required this.onJobTypeChanged,
    required this.countryList,
    required this.selectedCountryModel,
    required this.stateList,
    required this.selectedStateModel,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.onPinChanged,
  });

  @override
  Widget build(BuildContext context) {
    InputDecoration dec(String label, {Widget? icon}) => InputDecoration(
          labelText: label,
          prefixIcon: icon,
          filled: true,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        );

    String nameOf(dynamic item) {
      try {
        if (item == null) return '';
        final v = item.name;
        if (v is String && v.isNotEmpty) return v;
      } catch (_) {}
      return item?.toString() ?? '';
    }

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: jobTypes.contains(selectedJobType) ? selectedJobType : null,
          items: jobTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onJobTypeChanged,
          decoration: dec("पते का प्रकार", icon: const Icon(Icons.home_work)),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextFormField(controller: address1Controller, decoration: dec("पता 1", icon: const Icon(Icons.location_on)))),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(controller: address2Controller, decoration: dec("पता 2"))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextFormField(controller: postController, decoration: dec("पोस्ट"))),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(controller: cityController, decoration: dec("शहर"))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextFormField(controller: districtController, decoration: dec("जिला"))),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: pinCodeController,
              decoration: dec("पिन कोड"),
              keyboardType: TextInputType.number,
              onChanged: onPinChanged,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        DropdownButtonFormField<dynamic>(
          isExpanded: true,
          value: countryList.contains(selectedCountryModel) ? selectedCountryModel : null,
          items: countryList
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(nameOf(c)),
                  ))
              .toList(),
          onChanged: onCountryChanged,
          decoration: dec('देश', icon: const Icon(Icons.flag)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<dynamic>(
          isExpanded: true,
          value: stateList.contains(selectedStateModel) ? selectedStateModel : null,
          items: stateList
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(nameOf(s)),
                  ))
              .toList(),
          onChanged: onStateChanged,
          decoration: dec('राज्य', icon: const Icon(Icons.map)),
        ),
       
      ]),
    );
  }
}
