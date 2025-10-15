import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserModel {
  final String persNo;
  final String fullName;
  final String email;
  final String role;
  final String department;
  final String designation;
  final String? location;
  final String? phoneNumber;

  UserModel({
    required this.persNo,
    required this.fullName,
    this.email = '',
    this.role = 'user',
    this.department = '',
    this.designation = '',
    this.location,
    this.phoneNumber,
  });

  // Create UserModel from JWT token
  factory UserModel.fromToken(String token) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // Extract persNo from 'sub' claim
      String persNo = decodedToken['sub'] ?? '';

      // Parse empInfo JSON string if it exists
      Map<String, dynamic> empInfo = {};
      if (decodedToken['empInfo'] != null && decodedToken['empInfo'].isNotEmpty) {
        empInfo = jsonDecode(decodedToken['empInfo']);
      }

      return UserModel(
        persNo: persNo,
        fullName: empInfo['FullName'] ?? empInfo['fullName'] ?? '',
        email: empInfo['Email'] ?? empInfo['email'] ?? decodedToken['email'] ?? '',
        role: empInfo['Role'] ?? empInfo['role'] ?? decodedToken['role'] ?? 'user',
        department: empInfo['Department'] ?? empInfo['department'] ?? '',
        designation: empInfo['Designation'] ?? empInfo['designation'] ?? '',
        location: empInfo['Location'] ?? empInfo['location'],
        phoneNumber: empInfo['PhoneNumber'] ?? empInfo['phoneNumber'],
      );
    } catch (e) {
      print('Error parsing token: $e');
      // Return empty user on error
      return UserModel(persNo: '', fullName: '');
    }
  }

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      persNo: json['persNo'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
      location: json['location'],
      phoneNumber: json['phoneNumber'],
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'persNo': persNo,
      'fullName': fullName,
      'email': email,
      'role': role,
      'department': department,
      'designation': designation,
      'location': location,
      'phoneNumber': phoneNumber,
    };
  }

  // Get first name
  String get firstName {
    List<String> nameParts = fullName.split(' ');
    return nameParts.isNotEmpty ? nameParts.first : fullName;
  }

  // Check if user is admin
  bool get isAdmin {
    return role.toLowerCase() == 'admin' || role.toLowerCase() == 'administrator';
  }

  // Check if user model is valid (has persNo)
  bool get isValid {
    return persNo.isNotEmpty;
  }

  // Convert to string for debugging
  @override
  String toString() {
    return 'UserModel(persNo: $persNo, fullName: $fullName, role: $role, department: $department)';
  }

  // Copy with method for immutability
  UserModel copyWith({
    String? persNo,
    String? fullName,
    String? email,
    String? role,
    String? department,
    String? designation,
    String? location,
    String? phoneNumber,
  }) {
    return UserModel(
      persNo: persNo ?? this.persNo,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
