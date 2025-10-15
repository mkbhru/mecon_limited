import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/punch_data.dart';
import '../../services/api_service.dart';

class MantraAttendanceScreen extends StatefulWidget {
  const MantraAttendanceScreen({super.key});

  @override
  State<MantraAttendanceScreen> createState() => _MantraAttendanceScreenState();
}

class _MantraAttendanceScreenState extends State<MantraAttendanceScreen> {
  final TextEditingController _persNoController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  PunchDataResponse? _punchDataResponse;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _persNoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _fetchAttendance() async {
    if (_persNoController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a personnel number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _punchDataResponse = null;
    });

    try {
      final response = await ApiService.fetchPunchesOnDate(
        persNo: _persNoController.text.trim().toLowerCase(),
        year: _selectedDate.year,
        month: _selectedDate.month,
        day: _selectedDate.day,
      );

      setState(() {
        _punchDataResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch attendance data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantra Attendance'),
        backgroundColor: Colors.blue,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _persNoController,
                      decoration: const InputDecoration(
                        labelText: 'Personnel Number',
                        hintText: 'e.g., d1570',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.none,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Select Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _fetchAttendance,
                      icon: const Icon(Icons.search),
                      label: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Fetch Attendance'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_punchDataResponse != null) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _punchDataResponse!.message,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Employee: ${_punchDataResponse!.persNo.toUpperCase()}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            'Total Punches: ${_punchDataResponse!.count}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: _punchDataResponse!.data.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No punch records found for this date',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _punchDataResponse!.data.length,
                          itemBuilder: (context, index) {
                            final punch = _punchDataResponse!.data[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}.'.padLeft(3),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${punch.punchDate} | ${punch.punchTime}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
