import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeSearchScreen extends StatefulWidget {
  const EmployeeSearchScreen({super.key});

  @override
  State<EmployeeSearchScreen> createState() => _EmployeeSearchScreenState();
}

class _EmployeeSearchScreenState extends State<EmployeeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _searchEmployees(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _employees = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://careers.meconlimited.co.in/m_app/api/employee/employee-search?query=${Uri.encodeComponent(query)}',
        ),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _employees = data.map((e) => Employee.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch employees';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Search'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or personnel number...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchEmployees('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: _searchEmployees,
              textInputAction: TextInputAction.search,
            ),
          ),

          // Search Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _searchEmployees(_searchController.text),
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Results
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (_employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Search for employees',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a name or personnel number',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _employees.length,
      itemBuilder: (context, index) {
        final employee = _employees[index];
        final isOffRoll = employee.onRoll != 'Y';
        final textColor = isOffRoll ? Colors.red : Colors.black87;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOffRoll
                ? const BorderSide(color: Colors.red, width: 1.5)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with PersNo and OnRoll status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOffRoll
                                ? Colors.red.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            employee.persNo,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isOffRoll ? Colors.red : Colors.blue.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildCopyButton(employee.persNo),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => EmployeeDetailsPopup.show(context, employee),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.list_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isOffRoll)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OFF ROLL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Employee Name
                Text(
                  employee.empNm,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),

                // Email with Mail Button
                if (employee.email.isNotEmpty)
                  _buildEmailRow(employee.email, textColor),

                // Mobile Number with Call Button
                if (employee.mobileNo.isNotEmpty)
                  _buildPhoneRow(employee.mobileNo, textColor),

                // SAP Perno
                if (employee.sapPersNo.isNotEmpty)
                  _buildInfoRowWithCopy(
                    Icons.badge_outlined,
                    employee.sapPersNo,
                    employee.sapPersNo,
                    textColor,
                  ),

                // Date of Birth
                if (employee.dob != null)
                  _buildInfoRowWithCopy(
                    Icons.cake_outlined,
                    DateFormat('dd MMM yyyy').format(employee.dob!),
                    DateFormat('dd MMM yyyy').format(employee.dob!),
                    textColor,
                  ),

                const SizedBox(height: 12),

                // View Full Details Button
                // SizedBox(
                //   width: double.infinity,
                //   child: OutlinedButton.icon(
                //     onPressed: () => EmployeeDetailsPopup.show(context, employee),
                //     icon: const Icon(Icons.info_outline, size: 18),
                //     label: const Text('View Full Details'),
                //     style: OutlinedButton.styleFrom(
                //       foregroundColor: Colors.red.shade700,
                //       side: BorderSide(color: Colors.red.shade700),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRowWithCopy(IconData icon, String text, String copyText, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.9),
              ),
            ),
          ),
          _buildCopyButton(copyText),
        ],
      ),
    );
  }

  Widget _buildEmailRow(String email, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(Icons.email_outlined,
              size: 18, color: textColor.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.9),
              ),
            ),
          ),
          _buildCopyButton(email),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendEmail(email),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.mail,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRow(String phoneNumber, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(Icons.phone_outlined,
              size: 18, color: textColor.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              phoneNumber,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.9),
              ),
            ),
          ),
          _buildCopyButton(phoneNumber),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _makePhoneCall(phoneNumber),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.call,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyButton(String text) {
    return GestureDetector(
      onTap: () => _copyToClipboard(text),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.copy,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email client')),
        );
      }
    }
  }
}

class Employee {
  final String persNo;
  final String sapPersNo;
  final String empNm;
  final String email;
  final String mobileNo;
  final DateTime? dob;
  final String onRoll;
  final Map<String, dynamic> rawData;

  Employee({
    required this.persNo,
    required this.sapPersNo,
    required this.empNm,
    required this.email,
    required this.mobileNo,
    this.dob,
    required this.onRoll,
    required this.rawData,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDob;
    if (json['DOB'] != null && json['DOB'].toString().isNotEmpty) {
      try {
        parsedDob = DateTime.parse(json['DOB']);
      } catch (_) {}
    }

    return Employee(
      persNo: json['PersNo'] ?? '',
      sapPersNo: json['Sap_persno'] ?? '',
      empNm: json['EmpNm'] ?? '',
      email: json['Email'] ?? '',
      mobileNo: json['MobileNo'] ?? '',
      dob: parsedDob,
      onRoll: json['OnRoll'] ?? 'Y',
      rawData: json,
    );
  }
}

class EmployeeDetailsPopup extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailsPopup({super.key, required this.employee});

  static void show(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (context) => EmployeeDetailsPopup(employee: employee),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldLabels = {
      'PersNo': 'Personnel No',
      'Sap_persno': 'SAP Perno',
      'EmpNm': 'Employee Name',
      'Email': 'Email',
      'MobileNo': 'Mobile No',
      'Blood': 'Blood Group',
      'DOB': 'Date of Birth',
      'DOJ': 'Date of Joining',
      'DOS': 'Date of Superannuation',
      'DesgCd': 'Designation Code',
      'SecCd': 'Section Code',
      'LocCd': 'Location Code',
      'OnRoll': 'On Roll',
    };

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Employee Details',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: employee.rawData.entries.map((entry) {
                  final label = fieldLabels[entry.key] ?? entry.key;
                  String value = entry.value?.toString() ?? '';

                  if ((entry.key == 'DOB' || entry.key == 'DOJ' || entry.key == 'DOS') &&
                      value.isNotEmpty) {
                    try {
                      final date = DateTime.parse(value);
                      value = DateFormat('dd MMM yyyy').format(date);
                    } catch (_) {}
                  }

                  if (entry.key == 'OnRoll') {
                    value = value == 'Y' ? 'Yes' : 'No';
                  }

                  return _DetailRow(label: label, value: value);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $value'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          if (value.isNotEmpty)
            GestureDetector(
              onTap: () => _copyToClipboard(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.copy,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}