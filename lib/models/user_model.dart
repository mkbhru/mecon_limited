import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  final bool isAdminFlag; // Store the is_admin flag from JWT
  final String? sapPersno;
  final String? dob;
  final String? sex;
  final String? doj;
  final String? dos;

  UserModel({
    required this.persNo,
    required this.fullName,
    this.email = '',
    this.role = 'user',
    this.department = '',
    this.designation = '',
    this.location,
    this.phoneNumber,
    this.isAdminFlag = false,
    this.sapPersno,
    this.dob,
    this.sex,
    this.doj,
    this.dos,
  });

  // Create UserModel from JWT token
  factory UserModel.fromToken(String token) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // Extract persNo from 'sub' claim (convert to uppercase)
      String persNo = (decodedToken['sub'] ?? '').toString().toUpperCase();

      // Parse empInfo JSON string if it exists
      Map<String, dynamic> empInfo = {};
      if (decodedToken['empInfo'] != null && decodedToken['empInfo'].isNotEmpty) {
        empInfo = jsonDecode(decodedToken['empInfo']);
      }

      // Extract is_admin flag (handle both boolean and string values)
      bool isAdmin = false;
      if (empInfo['is_admin'] != null) {
        if (empInfo['is_admin'] is bool) {
          isAdmin = empInfo['is_admin'];
        } else if (empInfo['is_admin'] is String) {
          isAdmin = empInfo['is_admin'].toString().toLowerCase() == 'true';
        }
      }

      return UserModel(
        persNo: empInfo['PersNo']?.toString().toUpperCase() ?? persNo,
        fullName: empInfo['FullName'] ?? empInfo['fullName'] ?? '',
        email: empInfo['Email'] ?? empInfo['email'] ?? decodedToken['email'] ?? '',
        role: empInfo['Role'] ?? empInfo['role'] ?? (isAdmin ? 'admin' : 'user'),
        department: empInfo['Department'] ?? empInfo['department'] ?? '',
        designation: empInfo['Designation'] ?? empInfo['designation'] ?? '',
        location: empInfo['Location'] ?? empInfo['location'],
        phoneNumber: empInfo['PhoneNumber'] ?? empInfo['phoneNumber'],
        isAdminFlag: isAdmin,
        sapPersno: empInfo['Sap_persno']?.toString(),
        dob: empInfo['DOB']?.toString(),
        sex: empInfo['Sex']?.toString(),
        doj: empInfo['DOJ']?.toString(),
        dos: empInfo['DOS']?.toString(),
      );
    } catch (e) {
      debugPrint('Error parsing token: $e');
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
      isAdminFlag: json['isAdminFlag'] ?? false,
      sapPersno: json['sapPersno'],
      dob: json['dob'],
      sex: json['sex'],
      doj: json['doj'],
      dos: json['dos'],
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
      'isAdminFlag': isAdminFlag,
      'sapPersno': sapPersno,
      'dob': dob,
      'sex': sex,
      'doj': doj,
      'dos': dos,
    };
  }

  // Get first name
  String get firstName {
    List<String> nameParts = fullName.split(' ');
    return nameParts.isNotEmpty ? nameParts.first : fullName;
  }

  // Check if user is admin
  bool get isAdmin {
    // Prioritize the is_admin flag from JWT, fallback to role check
    return isAdminFlag || role.toLowerCase() == 'admin' || role.toLowerCase() == 'administrator';
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
    bool? isAdminFlag,
    String? sapPersno,
    String? dob,
    String? sex,
    String? doj,
    String? dos,
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
      isAdminFlag: isAdminFlag ?? this.isAdminFlag,
      sapPersno: sapPersno ?? this.sapPersno,
      dob: dob ?? this.dob,
      sex: sex ?? this.sex,
      doj: doj ?? this.doj,
      dos: dos ?? this.dos,
    );
  }
}
