// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class Calendar extends StatelessWidget {
//    Calendar({super.key});
//
//   // Sample data: You can replace this with actual API data
//   final List<Map<String, String>> calendarData = [
//     {
//       "year": "2024",
//       "region": "India",
//       "pdf_url":
//           "https://careers.meconlimited.co.in/api/download?file=20250224_171439_Calendar.pdf"
//     },
//     {
//       "year": "2025",
//       "region": "India",
//       "pdf_url":
//           "https://careers.meconlimited.co.in/api/download?file=20250224_171439_Calendar.pdf"
//     },
//   ];
//
//   // Function to open URL
//   void _launchURL(String url) async {
//     Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       debugPrint("Could not launch $url");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Calendar")),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal, // Allow horizontal scrolling
//             child: DataTable(
//               columns: const [
//                 DataColumn(
//                     label: Text("Year",
//                         style: TextStyle(fontWeight: FontWeight.bold))),
//                 DataColumn(
//                     label: Text("Region",
//                         style: TextStyle(fontWeight: FontWeight.bold))),
//                 DataColumn(
//                     label: Text("PDF Link",
//                         style: TextStyle(fontWeight: FontWeight.bold))),
//               ],
//               rows: calendarData.map((entry) {
//                 return DataRow(cells: [
//                   DataCell(Text(entry["year"]!)), // Year column
//                   DataCell(Text(entry["region"]!)), // Region column
//                   DataCell(
//                     InkWell(
//                       onTap: () => _launchURL(entry["pdf_url"]!), // Open PDF
//                       child: const Text(
//                         "Download PDF",
//                         style: TextStyle(
//                           color: Colors.blue,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ]);
//               }).toList(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calendar")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Show events for the selected day
          Expanded(
            child: _selectedDay == null
                ? Center(child: Text("Select a date to see events"))
                : ListView(
              children: (_events[_selectedDay] ?? [])
                  .map((event) => Card(
                margin: EdgeInsets.symmetric(
                    vertical: 5, horizontal: 10),
                child: ListTile(
                  leading: Icon(Icons.event),
                  title: Text(event),
                ),
              ))
                  .toList(),
            ),
          ),
        ],
      ),

      floatingActionButton: _selectedDay != null
          ? FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddEventDialog();
        },
      )
          : null,
    );
  }

  void _showAddEventDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Event"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter event name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _events[_selectedDay!] = _events[_selectedDay] ?? [];
                  _events[_selectedDay!]!.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }
}
