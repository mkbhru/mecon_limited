import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Calendar extends StatelessWidget {
   Calendar({super.key});

  // Sample data: You can replace this with actual API data
  final List<Map<String, String>> calendarData = [
    {
      "year": "2024",
      "region": "India",
      "pdf_url":
          "https://careers.meconlimited.co.in/api/download?file=20250224_171439_Calendar.pdf"
    },
    {
      "year": "2025",
      "region": "India",
      "pdf_url":
          "https://careers.meconlimited.co.in/api/download?file=20250224_171439_Calendar.pdf"
    },
  ];

  // Function to open URL
  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Allow horizontal scrolling
            child: DataTable(
              columns: const [
                DataColumn(
                    label: Text("Year",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text("Region",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text("PDF Link",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: calendarData.map((entry) {
                return DataRow(cells: [
                  DataCell(Text(entry["year"]!)), // Year column
                  DataCell(Text(entry["region"]!)), // Region column
                  DataCell(
                    InkWell(
                      onTap: () => _launchURL(entry["pdf_url"]!), // Open PDF
                      child: const Text(
                        "Download PDF",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
