import '../utils/enums.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? rollNumber;
  final String? department;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.rollNumber,
    this.department,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.student,
      rollNumber: map['rollNumber'],
      department: map['department'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'rollNumber': rollNumber,
      'department': department,
    };
  }
}
