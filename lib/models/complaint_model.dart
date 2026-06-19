import '../utils/enums.dart';

class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String issueType;
  final String department;
  final String building;
  final String floor;
  final String room;
  final String specificLocation;
  final ComplaintPriority priority;
  final ComplaintStatus status;
  final String? imageBase64;
  final String studentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? clusterId;
  final String? adminRemarks;
  final String? resolutionImageBase64;
  final DateTime? resolvedAt;
  final int affectedStudentCount;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.issueType,
    required this.department,
    required this.building,
    required this.floor,
    required this.room,
    required this.specificLocation,
    required this.priority,
    required this.status,
    this.imageBase64,
    required this.studentId,
    required this.createdAt,
    required this.updatedAt,
    this.clusterId,
    this.adminRemarks,
    this.resolutionImageBase64,
    this.resolvedAt,
    this.affectedStudentCount = 1,
  });

  factory ComplaintModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ComplaintModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      issueType: map['issueType'] ?? 'General',
      department: map['department'] ?? '',
      building: map['building'] ?? map['location'] ?? '', // Fallback to location if present
      floor: map['floor'] ?? '',
      room: map['room'] ?? '',
      specificLocation: map['specificLocation'] ?? '',
      priority: ComplaintPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => ComplaintPriority.low,
      ),
      status: ComplaintStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ComplaintStatus.submitted,
      ),
      imageBase64: map['imageBase64'],
      studentId: map['studentId'] ?? map['createdBy'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
      clusterId: map['clusterId'],
      adminRemarks: map['adminRemarks'],
      resolutionImageBase64: map['resolutionImageBase64'],
      resolvedAt: map['resolvedAt'] != null ? DateTime.parse(map['resolvedAt']) : null,
      affectedStudentCount: map['affectedStudentCount'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'issueType': issueType,
      'department': department,
      'building': building,
      'floor': floor,
      'room': room,
      'specificLocation': specificLocation,
      'priority': priority.name,
      'status': status.name,
      'imageBase64': imageBase64,
      'studentId': studentId,
      'createdBy': studentId, // To support both field structures
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'clusterId': clusterId,
      'adminRemarks': adminRemarks,
      'resolutionImageBase64': resolutionImageBase64,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'affectedStudentCount': affectedStudentCount,
    };
  }
  
  ComplaintModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? issueType,
    String? department,
    String? building,
    String? floor,
    String? room,
    String? specificLocation,
    ComplaintPriority? priority,
    ComplaintStatus? status,
    String? imageBase64,
    String? studentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? clusterId,
    String? adminRemarks,
    String? resolutionImageBase64,
    DateTime? resolvedAt,
    int? affectedStudentCount,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      issueType: issueType ?? this.issueType,
      department: department ?? this.department,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      room: room ?? this.room,
      specificLocation: specificLocation ?? this.specificLocation,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      imageBase64: imageBase64 ?? this.imageBase64,
      studentId: studentId ?? this.studentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clusterId: clusterId ?? this.clusterId,
      adminRemarks: adminRemarks ?? this.adminRemarks,
      resolutionImageBase64: resolutionImageBase64 ?? this.resolutionImageBase64,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      affectedStudentCount: affectedStudentCount ?? this.affectedStudentCount,
    );
  }
}
