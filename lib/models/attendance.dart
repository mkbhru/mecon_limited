class Attendance {
  final String date;
  final String firstIn;
  final String lunchIn;
  final String lunchOut;
  final String lastOut;

  Attendance({
    required this.date,
    required this.firstIn,
    required this.lunchIn,
    required this.lunchOut,
    required this.lastOut,
  });

  // Convert JSON response into an Attendance object
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      date: json['date'],
      firstIn: json['firstIn'],
      lunchIn: json['lunchIn'],
      lunchOut: json['lunchOut'],
      lastOut: json['lastOut'],
    );
  }
}
