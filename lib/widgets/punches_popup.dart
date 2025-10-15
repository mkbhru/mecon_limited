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
    return "$date | $time";
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Punch Log",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.black87),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "loading punch data..",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const CircularProgressIndicator(color: Colors.blue),
                        ],
                      )
                    : punches == null || punches!.isEmpty
                        ? Center(
                            child: Text(
                              "No punches found for today",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
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
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        formatTimestamp(punch['punchDate'], punch['punchTime']),
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
          ],
        ),
      ),
    );
  }
}