import 'package:flutter/material.dart';

class EmploymentScreen extends StatefulWidget {
  const EmploymentScreen({super.key});

  @override
  State<EmploymentScreen> createState() => _EmploymentScreenState();
}

class _EmploymentScreenState extends State<EmploymentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController startYearController = TextEditingController();
  final TextEditingController endYearController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String selectedOccupation = '';
  String selectedIndustry = '';
  String selectedBusinessType = '';

  final List<String> occupations = ['Private Job', 'Teacher', 'Business', 'Other'];
  final List<String> industryCategories = ['IT', 'Education', 'Health', 'Others'];
  final List<String> businessTypes = ['Small', 'Medium', 'Large'];

  List<Map<String, dynamic>> employmentData = [];

  bool isEditing = false;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void clearForm() {
    nameController.clear();
    roleController.clear();
    startYearController.clear();
    endYearController.clear();
    locationController.clear();
    selectedOccupation = '';
    selectedIndustry = '';
    selectedBusinessType = '';
    isEditing = false;
    editingIndex = null;
  }

  void addOrUpdateProfile() {
    if (nameController.text.isEmpty || selectedOccupation.isEmpty) return;

    final newData = {
      'type': selectedOccupation,
      'name': nameController.text,
      'role': roleController.text,
      'start': startYearController.text,
      'end': endYearController.text,
      'location': locationController.text,
      'industry': selectedIndustry,
      'business': selectedBusinessType,
    };

    setState(() {
      if (isEditing && editingIndex != null) {
        // Update existing entry
        employmentData[editingIndex!] = newData;
      } else {
        // Add new entry
        employmentData.add(newData);
      }
      clearForm();
      _tabController.animateTo(1); // Switch to list tab after adding/updating
    });
  }

  void editProfile(int index) {
    final data = employmentData[index];
    setState(() {
      selectedOccupation = data['type'] ?? '';
      nameController.text = data['name'] ?? '';
      roleController.text = data['role'] ?? '';
      startYearController.text = data['start'] ?? '';
      endYearController.text = data['end'] ?? '';
      locationController.text = data['location'] ?? '';
      selectedIndustry = data['industry'] ?? '';
      selectedBusinessType = data['business'] ?? '';
      isEditing = true;
      editingIndex = index;
      _tabController.animateTo(0); // Switch to form tab for editing
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('व्यवसाय प्रोफ़ाइल'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'प्रोफ़ाइल जोड़ें'),
            Tab(text: 'सूची'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: FORM
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 6,
              shadowColor: Colors.deepPurple.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? "📝 व्यवसाय विवरण संपादित करें" : "🧾 व्यवसाय विवरण जोड़ें",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 20),

                    // Occupation Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedOccupation.isEmpty ? null : selectedOccupation,
                      items: occupations.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (value) => setState(() => selectedOccupation = value!),
                      decoration: InputDecoration(
                        labelText: '🛠 पेशा *',
                        labelStyle: const TextStyle(color: Colors.indigo),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.work_outline, color: Colors.indigo),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Name
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: '👤 नाम',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.person, color: Colors.teal),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Role
                    TextField(
                      controller: roleController,
                      decoration: InputDecoration(
                        labelText: '📌 भूमिका',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.assignment_ind, color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Start and End Year
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startYearController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '🔰 आरंभ वर्ष',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.calendar_today, color: Colors.purple),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: endYearController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '🏁 समाप्ति वर्ष',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.calendar_month, color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Location
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: '📍 स्थान',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.location_on, color: Colors.brown),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Industry Category Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedIndustry.isEmpty ? null : selectedIndustry,
                      items: industryCategories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (value) => setState(() => selectedIndustry = value!),
                      decoration: InputDecoration(
                        labelText: '🏭 औद्योगिक श्रेणी',
                        labelStyle: const TextStyle(color: Colors.indigo),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.category_outlined, color: Colors.indigo),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Business Type Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedBusinessType.isEmpty ? null : selectedBusinessType,
                      items: businessTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (value) => setState(() => selectedBusinessType = value!),
                      decoration: InputDecoration(
                        labelText: '🏢 व्यापार वर्ग',
                        labelStyle: const TextStyle(color: Colors.indigo),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.business_center, color: Colors.blueAccent),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Add/Update Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: addOrUpdateProfile,
                        icon: Icon(isEditing ? Icons.save : Icons.add_circle_outline, size: 24),
                        label: Text(isEditing ? 'अपडेट करें' : 'प्रोफ़ाइल में जोड़ें'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),

                    if (isEditing)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            clearForm();
                          });
                        },
                        child: const Text('संपादन रद्द करें', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // TAB 2: LIST
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: employmentData.isEmpty
                ? const Center(child: Text('कोई डेटा उपलब्ध नहीं है'))
                : ListView.builder(
                    itemCount: employmentData.length,
                    itemBuilder: (context, index) {
                      final data = employmentData[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['type'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('नाम: ${data['name'] ?? '-'}'),
                              Text('भूमिका: ${data['role'] ?? '-'}'),
                              Text('कार्यकाल: ${data['start'] ?? '-'} से ${data['end'] ?? '-'}'),
                              Text('स्थान: ${data['location'] ?? '-'}'),
                              Text('औद्योगिक श्रेणी: ${data['industry'] ?? '-'}'),
                              Text('व्यापार वर्ग: ${data['business'] ?? '-'}'),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.deepPurple),
                                  onPressed: () => editProfile(index),
                                  tooltip: 'संपादित करें',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
