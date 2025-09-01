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

  String formatTimestamp(String? date, String? time) {
    if (date == null || time == null) return "N/A";
    return "$date $time";
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
          color: Colors.black,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "PUNCH LOG",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    iconSize: 18,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black,
                child: isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "LOADING LOG...",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.green,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const CircularProgressIndicator(color: Colors.green),
                        ],
                      )
                    : punches == null || punches!.isEmpty
                        ? const Center(
                            child: Text(
                              "NO PUNCH RECORDS FOUND",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontFamily: 'monospace',
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: punches!.length,
                            itemBuilder: (context, index) {
                              final punch = punches![index];
                              
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${index + 1}.'.padLeft(3),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${formatTimestamp(punch['punchDate'], punch['punchTime'])} | ${punch['employeeId']} | ${punch['companyLocation']} | DEV:${punch['deviceId']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
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
          ],
        ),
      ),
    );
  }
}