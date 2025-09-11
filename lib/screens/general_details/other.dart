// other.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtherStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController mobileController;
  final TextEditingController alternateNumberController;
  final TextEditingController whatsappNumberController;
  final TextEditingController emailController;
  final TextEditingController adharNameController;
  final TextEditingController adharFatherNameController;
  final TextEditingController adharController;

  final String? selectedWhatsApp;
  final List<String> whatsappStatus;
  final ValueChanged<String?> onWhatsAppChanged;

  final String? selectedReligion;
  final List<String> religions;
  final ValueChanged<String?> onReligionChanged;

  final ValueChanged<String?> onMobileChanged;
  final String? Function(String?)? mobileValidator;
  final String? Function(String?)? aadhaarValidator;
  final String? Function(String?)? emailValidator;

  const OtherStep({
    super.key,
    required this.formKey,
    required this.mobileController,
    required this.alternateNumberController,
    required this.whatsappNumberController,
    required this.emailController,
    required this.adharNameController,
    required this.adharFatherNameController,
    required this.adharController,
    required this.selectedWhatsApp,
    required this.whatsappStatus,
    required this.onWhatsAppChanged,
    required this.selectedReligion,
    required this.religions,
    required this.onReligionChanged,
    required this.onMobileChanged,
    this.mobileValidator,
    this.aadhaarValidator,
    this.emailValidator,
  });

  @override
  Widget build(BuildContext context) {
    final _dec = (String label, {Widget? icon, String? hint}) => InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon,
          filled: true,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        );

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: mobileController,
              decoration: _dec("मोबाइल", icon: const Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              validator: mobileValidator,
              onChanged: onMobileChanged,
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
              onChanged: onWhatsAppChanged,
              decoration: _dec("WhatsApp Status", icon: const Icon(Icons.chat)),
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
                validator: mobileValidator,
              ),
            ),
        ]),
        const SizedBox(height: 12),
        TextFormField(
          controller: emailController,
          decoration: _dec("ईमेल", icon: const Icon(Icons.email)),
          keyboardType: TextInputType.emailAddress,
          validator: emailValidator,
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
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
          validator: aadhaarValidator,
        ),
       
      ]),
    );
  }
}
