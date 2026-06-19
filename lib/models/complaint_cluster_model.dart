import '../utils/enums.dart';

class ComplaintClusterModel {
  final String id;
  final String category;
  final String department;
  final List<String> complaintIds;
  final ComplaintStatus status;
  final DateTime createdAt;
  final int affectedStudentCount;

  ComplaintClusterModel({
    required this.id,
    required this.category,
    required this.department,
    required this.complaintIds,
    required this.status,
    required this.createdAt,
    this.affectedStudentCount = 0,
  });

  factory ComplaintClusterModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ComplaintClusterModel(
      id: documentId,
      category: map['category'] ?? '',
      department: map['department'] ?? '',
      complaintIds: List<String>.from(map['complaintIds'] ?? []),
      status: ComplaintStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ComplaintStatus.submitted,
      ),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      affectedStudentCount: map['affectedStudentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'department': department,
      'complaintIds': complaintIds,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'affectedStudentCount': affectedStudentCount,
    };
  }
}

