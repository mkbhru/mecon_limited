class PunchData {
  final String punchDate;
  final String punchTime;
  final String employeeId;
  final String enrollId;
  final String referenceId;
  final String companyLocation;
  final String punchMode;
  final String deviceId;

  PunchData({
    required this.punchDate,
    required this.punchTime,
    required this.employeeId,
    required this.enrollId,
    required this.referenceId,
    required this.companyLocation,
    required this.punchMode,
    required this.deviceId,
  });

  factory PunchData.fromJson(Map<String, dynamic> json) {
    return PunchData(
      punchDate: json['punchDate'] ?? '',
      punchTime: json['punchTime'] ?? '',
      employeeId: json['employeeId'] ?? '',
      enrollId: json['enrollId'] ?? '',
      referenceId: json['referenceId'] ?? '',
      companyLocation: json['companyLocation'] ?? '',
      punchMode: json['punchMode'] ?? '',
      deviceId: json['deviceId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'punchDate': punchDate,
      'punchTime': punchTime,
      'employeeId': employeeId,
      'enrollId': enrollId,
      'referenceId': referenceId,
      'companyLocation': companyLocation,
      'punchMode': punchMode,
      'deviceId': deviceId,
    };
  }
}

class PunchDataResponse {
  final String message;
  final List<PunchData> data;
  final int count;
  final String requestedDate;
  final String persNo;

  PunchDataResponse({
    required this.message,
    required this.data,
    required this.count,
    required this.requestedDate,
    required this.persNo,
  });

  factory PunchDataResponse.fromJson(Map<String, dynamic> json) {
    return PunchDataResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => PunchData.fromJson(item))
              .toList() ??
          [],
      count: json['count'] ?? 0,
      requestedDate: json['requested_date'] ?? '',
      persNo: json['pers_no'] ?? '',
    );
  }
}