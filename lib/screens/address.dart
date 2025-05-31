import 'package:flutter/material.dart';
import 'base_scaffold.dart';

class AddressScreen extends StatelessWidget {
  final List<Map<String, String>> savedAddresses = [
    {
      'address':
          '5-e-256, Jnv\nपोस्ट: BIKANER\nजिला: BIKANER\nपिन कोड: 334001\nराज्य: Rajasthan\nदेश: India',
      'type': 'Residential'
    },
    {
      'address':
          '5-d-130, JNV, Back Side Of Gramin Bank\nपोस्ट: Deshnok\nजिला: Jaipur\nपिन कोड: 334401\nराज्य: Jharkhand\nदेश: India',
      'type': 'Office/Business'
    },
    {
      'address':
          'Rampuria, Near kotwali\nपोस्ट: Deshnok\nजिला: Jaipur\nपिन कोड: 334401\nराज्य: Goa\nदेश: India',
      'type': 'Factory'
    },
    {
      'address':
          '4-o, Near SBBJ Bank\nपोस्ट: Bikaner\nजिला: Bikaner\nपिन कोड: 334005\nराज्य: Bihar\nदेश: India',
      'type': 'Other'
    }
  ];

  AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return BaseScaffold(
      selectedIndex: 2,
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.deepPurple.shade50,
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 24, vertical: 12),
              child: TabBar(
                labelColor: Colors.deepPurple.shade800,
                indicatorColor: Colors.deepPurple,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                tabs: const [
                  Tab(text: 'प्राथमिक पता'),
                  Tab(text: 'पता अपडेट करें'),
                  Tab(text: 'सहेजे गए पते'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    child: _buildPrimaryAddressSection(context, isSmallScreen),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    child: _buildAddressFormSection(context, isSmallScreen),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    child: _buildHorizontalAddressCards(context, isSmallScreen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryAddressSection(BuildContext context, bool isSmallScreen) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.cyan.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_pin, color: Colors.teal.shade900, size: isSmallScreen ? 24 : 30),
                const SizedBox(width: 12),
                Text(
                  "आपका प्राथमिक पता",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade900,
                        fontSize: isSmallScreen ? 18 : 22,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "जिस पर आप पत्राचार चाहते हैं।",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.teal.shade800,
                    fontWeight: FontWeight.w500,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
            ),
            const SizedBox(height: 20),
            _buildAddressDetail(
              icon: Icons.apartment,
              label: "पता का प्रकार",
              value: "Factory",
              color: Colors.teal.shade700,
              isSmallScreen: isSmallScreen,
            ),
            _buildAddressDetail(
              icon: Icons.home,
              label: "पता",
              value: "Rampuria",
              color: Colors.teal.shade700,
              isSmallScreen: isSmallScreen,
            ),
            _buildAddressDetail(
              icon: Icons.local_post_office,
              label: "पोस्ट",
              value: "Deshnok",
              color: Colors.teal.shade700,
              isSmallScreen: isSmallScreen,
            ),
            _buildAddressDetail(
              icon: Icons.location_city,
              label: "जिला",
              value: "Jaipur",
              color: Colors.teal.shade700,
              isSmallScreen: isSmallScreen,
            ),
            _buildAddressDetail(
              icon: Icons.pin,
              label: "पिन कोड",
              value: "334401",
              color: Colors.teal.shade700,
              isSmallScreen: isSmallScreen,
            ),
            _buildAddressDetail(
              icon: Icons.public,
              label: "राज्य",
              value: "Goa",
              color: Colors.teal.shade700,
              isSmallScreen: isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetail({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: isSmallScreen ? 18 : 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressFormSection(BuildContext context, bool isSmallScreen) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 24,
            vertical: isSmallScreen ? 20 : 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.indigo.shade700, size: isSmallScreen ? 24 : 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "नोट: सदस्यता पत्रिका में दिए गए पते के आधार पर आपसे संपर्क किया जायेगा।",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.indigo.shade800,
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              _buildTextField(context, "पता 1", isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
              _buildTextField(context, "पता 2", isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: isSmallScreen ? 12 : 16,
                mainAxisSpacing: isSmallScreen ? 12 : 16,
                childAspectRatio: isSmallScreen ? 2.8 : 2.5,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildTextField(context, "पोस्ट", isSmallScreen),
                  _buildTextField(context, "शहर", isSmallScreen),
                  _buildTextField(context, "जिला", isSmallScreen),
                  _buildTextField(context, "पिन कोड", isSmallScreen),
                  _buildTextField(context, "देश", isSmallScreen),
                  _buildTextField(context, "राज्य", isSmallScreen),
                ],
              ),
              SizedBox(height: isSmallScreen ? 24 : 32),
              Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      items: ['Factory', 'Residential', 'Office/Business', 'Other']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    color: Colors.indigo.shade800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (_) {},
                      decoration: InputDecoration(
                        labelText: "पता का प्रकार",
                        labelStyle: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.indigo.shade700,
                        ),
                        filled: true,
                        fillColor: Colors.indigo.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.indigo.shade200),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 20,
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Flexible(
                    flex: 1,
                    child: _coloredActionButton(
                      context,
                      label: "Update",
                      icon: Icons.save_alt,
                      color: Colors.indigo.shade600,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalAddressCards(BuildContext context, bool isSmallScreen) {
    return Column(
      children: savedAddresses.asMap().entries.map((entry) {
        int index = entry.key + 1;
        Map<String, String> address = entry.value;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.blue.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$index.",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade800,
                          fontSize: isSmallScreen ? 18 : 22,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address['address']!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.black87,
                                height: 1.5,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "पता का प्रकार: ${address['type']}",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Column(
                    children: [
                      _coloredActionButton(
                        context,
                        label: "Edit",
                        icon: Icons.edit,
                        color: Colors.amber.shade600,
                        isSmallScreen: isSmallScreen,
                      ),
                      const SizedBox(height: 12),
                      _coloredActionButton(
                        context,
                        label: "Delete",
                        icon: Icons.delete,
                        color: Colors.red.shade400,
                        isSmallScreen: isSmallScreen,
                      ),
                      const SizedBox(height: 12),
                      _coloredActionButton(
                        context,
                        label: "Primary",
                        icon: Icons.star,
                        color: Colors.green.shade600,
                        isSmallScreen: isSmallScreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _coloredActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required bool isSmallScreen,
  }) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: isSmallScreen ? 16 : 20, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 10 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        minimumSize: Size(isSmallScreen ? 80 : 100, isSmallScreen ? 36 : 40),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, bool isSmallScreen) {
    return TextField(
      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
          color: Colors.indigo.shade700,
        ),
        filled: true,
        fillColor: Colors.indigo.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 12 : 16,
        ),
      ),
    );
  }
}
