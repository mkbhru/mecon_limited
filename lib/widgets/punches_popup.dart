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

  String formatDateTime(String? date, String? time) {
    if (date == null || time == null) return "N/A";
    try {
      return "$date $time";
    } catch (e) {
      return "Invalid date";
    }
  }

  String formatTime(String? time) {
    if (time == null) return "--:--";
    return time.substring(0, 5); // Show HH:MM format
  }

  IconData getPunchIcon(int index, int total) {
    // Determine punch type based on sequence
    if (index == 0) return Icons.login; // First punch is IN
    if (index == total - 1 && total > 1) return Icons.logout; // Last punch is OUT
    return Icons.access_time; // Middle punches
  }

  Color getPunchColor(int index, int total) {
    // Determine punch color based on sequence
    if (index == 0) return Colors.green; // First punch is IN
    if (index == total - 1 && total > 1) return Colors.red; // Last punch is OUT
    return Colors.orange; // Middle punches
  }

  String getPunchType(int index, int total) {
    if (index == 0) return "CHECK IN";
    if (index == total - 1 && total > 1) return "CHECK OUT";
    return index % 2 == 0 ? "CHECK IN" : "CHECK OUT";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Punches",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "fetching punch data..",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const CircularProgressIndicator(),
                        ],
                      )
                    : punches == null || punches!.isEmpty
                        ? const Center(
                            child: Text(
                              "No punches found for today",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: punches!.length,
                            itemBuilder: (context, index) {
                              final punch = punches![index];
                              final totalPunches = punches!.length;
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor: getPunchColor(index, totalPunches),
                                    child: Icon(
                                      getPunchIcon(index, totalPunches),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    getPunchType(index, totalPunches),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatTime(punch['punchTime']),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        punch['companyLocation'] ?? 'Unknown Location',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Device ${punch['deviceId'] ?? 'N/A'}',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        punch['punchMode'] ?? 'DEFAULT',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}