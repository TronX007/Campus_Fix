import '../models/complaint_model.dart';
import '../utils/enums.dart';

class MockFirestoreService {
  final List<ComplaintModel> _complaints = [
    ComplaintModel(
      id: 'c1',
      title: 'Leaking Pipe in Block A',
      description: 'There is a severe water leak in the washroom on the 2nd floor.',
      category: 'Water Supply',
      issueType: 'Water Leakage',
      department: 'Hostel Management',
      building: 'Block A',
      floor: '2',
      room: '205',
      specificLocation: 'Washroom',
      priority: ComplaintPriority.high,
      status: ComplaintStatus.inProgress,
      imageBase64: null,
      resolutionImageBase64: null,
      studentId: 'student_123',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ComplaintModel(
      id: 'c2',
      title: 'Wi-Fi not working in CS Lab',
      description: 'The router in CS Lab 3 is down since morning.',
      category: 'Wi-Fi & IT Support',
      issueType: 'Wi-Fi Access Issue',
      department: 'Computer Science',
      building: 'Block C',
      floor: '1',
      room: '103',
      specificLocation: 'CS Lab 3',
      priority: ComplaintPriority.medium,
      status: ComplaintStatus.submitted,
      imageBase64: null,
      resolutionImageBase64: null,
      studentId: 'student_123',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  Future<List<ComplaintModel>> getComplaintsForStudent(String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _complaints.where((c) => c.studentId == studentId).toList();
  }

  Future<List<ComplaintModel>> getAllComplaints() async {
    await Future.delayed(const Duration(seconds: 1));
    return _complaints;
  }

  Future<void> addComplaint(ComplaintModel complaint) async {
    await Future.delayed(const Duration(seconds: 1));
    _complaints.insert(0, complaint);
  }

  Future<void> updateComplaintStatus(String complaintId, ComplaintStatus newStatus, {String? remarks, ComplaintPriority? newPriority}) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _complaints.indexWhere((c) => c.id == complaintId);
    if (index != -1) {
      _complaints[index] = _complaints[index].copyWith(
        status: newStatus,
        adminRemarks: remarks ?? _complaints[index].adminRemarks,
        priority: newPriority ?? _complaints[index].priority,
      );
    }
  }
}
