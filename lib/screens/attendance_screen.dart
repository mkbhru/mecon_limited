// lib/screens/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../services/amonth_service.dart'; // API service file
import 'package:mecon_limited/generated/l10n.dart'; // ✅ Localization

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<dynamic> attendanceData = [];
  bool isLoading = false;
  bool isTimeout = false; // Track timeout

  // Dropdown options
  final List<int> years = [2025];
  final Map<int, String> months = {
    1: "January",
    2: "February",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "August",
    9: "September",
    10: "October",
    11: "November",
    12: "December"
  };

  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = now.year;
    selectedMonth = now.month;

    fetchAttendance();
  }

  String formatTime(dynamic dateTimeString) {
    if (dateTimeString == null) return "--";
    String dateTime = dateTimeString.toString();
    return (dateTime.length >= 11) ? dateTime.substring(11) : "--";
  }

  String formatDate(dynamic dateTimeString) {
    if (dateTimeString == null) return "--";
    String dateTime = dateTimeString.toString();
    return (dateTime.length >= 10) ? dateTime.substring(0, 10) : "--";
  }

  Future<void> fetchAttendance() async {
    setState(() {
      isLoading = true;
      isTimeout = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final persNo = prefs.getString("persNo") ?? 'd1525';

      final data = await Future.any([
        ApiService().fetchAttendance(persNo, selectedYear, selectedMonth),
        Future.delayed(const Duration(seconds: 10),
                () => throw TimeoutException("Request timed out")),
      ]);

      setState(() => attendanceData = data);
    } on TimeoutException {
      setState(() {
        isTimeout = true;
        attendanceData = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = const TextStyle(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).attendanceSummary)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Year & Month Dropdown Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedYear,
                    decoration: InputDecoration(
                      labelText: S.of(context).selectYear,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedYear = value ?? selectedYear);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedMonth,
                    decoration: InputDecoration(
                      labelText: S.of(context).selectMonth,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: months.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedMonth = value ?? selectedMonth);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: fetchAttendance,
                  child: Text(S.of(context).refresh),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Loading / Timeout / No Data
            if (isLoading)
              const CircularProgressIndicator()
            else if (isTimeout)
              Text(
                S.of(context).serverBusy,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              )
            else if (attendanceData.isEmpty)
                Text(
                  S.of(context).noData,
                  style: const TextStyle(fontSize: 16),
                )
              else
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTableTheme(
                          data: DataTableThemeData(
                            headingRowColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.blue.shade100),
                            dataRowColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.white),
                          ),
                          child: DataTable(
                            columnSpacing: 20,
                            headingRowHeight: 50,
                            dataRowHeight: 45,
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            columns: [
                              DataColumn(
                                  label: Text(S.of(context).date,
                                      style: headerStyle)),
                              DataColumn(
                                  label: Text(S.of(context).firstIn,
                                      style: headerStyle)),
                              DataColumn(
                                  label: Text(S.of(context).lunchOut,
                                      style: headerStyle)),
                              DataColumn(
                                  label: Text(S.of(context).lunchIn,
                                      style: headerStyle)),
                              DataColumn(
                                  label: Text(S.of(context).lastOut,
                                      style: headerStyle)),
                            ],
                            rows: attendanceData.map<DataRow>((data) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(formatDate(data["TrDt"]))),
                                  DataCell(Text(formatTime(data["FirstIn"]))),
                                  DataCell(Text(formatTime(data["LunchOUT"]))),
                                  DataCell(Text(formatTime(data["LunchIN"]))),
                                  DataCell(Text(formatTime(data["LastOut"]))),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
