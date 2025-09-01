import 'package:flutter/material.dart';
import '../services/attendance_service.dart';

class PunchesPopup extends StatefulWidget {
  const PunchesPopup({super.key});

  @override
  PunchesPopupState createState() => PunchesPopupState();
}

class PunchesPopupState extends State<PunchesPopup> {
  List<Map<String, dynamic>>? punches;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPunches();
  }

  Future<void> fetchPunches() async {
    final data = await ApiService().fetchLatestPunches();
    if (mounted) {
      setState(() {
        punches = data;
        isLoading = false;
      });
    }
  }

  String formatDateTime(dynamic dateTimeString) {
    if (dateTimeString == null) return "N/A";
    try {
      DateTime dateTime = DateTime.parse(dateTimeString.toString());
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Invalid date";
    }
  }

  IconData getPunchIcon(String? punchType) {
    switch (punchType?.toLowerCase()) {
      case 'in':
        return Icons.login;
      case 'out':
        return Icons.logout;
      default:
        return Icons.access_time;
    }
  }

  Color getPunchColor(String? punchType) {
    switch (punchType?.toLowerCase()) {
      case 'in':
        return Colors.green;
      case 'out':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Punches",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : punches == null || punches!.isEmpty
                      ? const Center(
                          child: Text(
                            "No punches found for today",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: punches!.length,
                          itemBuilder: (context, index) {
                            final punch = punches![index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: getPunchColor(punch['PunchType']),
                                  child: Icon(
                                    getPunchIcon(punch['PunchType']),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  punch['PunchType']?.toString().toUpperCase() ?? 'UNKNOWN',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  formatDateTime(punch['PunchTime']),
                                ),
                                trailing: punch['Location'] != null
                                    ? Text(
                                        punch['Location'].toString(),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}