// shiksha.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShikshaStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final DateTime? selectedDOB;
  final ValueChanged<DateTime?> onDobChanged;

  final List<String> educations;
  final String? selectedEducation;
  final ValueChanged<String?> onEducationChanged;

  final List<String> professions;
  final String? selectedProfession;
  final ValueChanged<String?> onProfessionChanged;

  const ShikshaStep({
    super.key,
    required this.formKey,
    required this.selectedDOB,
    required this.onDobChanged,
    required this.educations,
    required this.selectedEducation,
    required this.onEducationChanged,
    required this.professions,
    required this.selectedProfession,
    required this.onProfessionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(children: [
        Row(children: [
          Expanded(
            child: TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: selectedDOB == null ? '' : "${selectedDOB!.day}-${selectedDOB!.month}-${selectedDOB!.year}",
              ),
              decoration: InputDecoration(
                labelText: "जन्म तिथि",
                prefixIcon: const Icon(Icons.cake),
                filled: true,
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDOB ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                onDobChanged(picked);
              },
              validator: (_) => null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: educations.contains(selectedEducation) ? selectedEducation : null,
              items: educations.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onEducationChanged,
              decoration: InputDecoration(
                labelText: "शिक्षा",
                prefixIcon: const Icon(Icons.school),
                filled: true,
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: professions.contains(selectedProfession) ? selectedProfession : null,
          items: professions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onProfessionChanged,
          decoration: InputDecoration(
            labelText: "व्यवसाय",
            prefixIcon: const Icon(Icons.work),
            filled: true,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]),
    );
  }
}
