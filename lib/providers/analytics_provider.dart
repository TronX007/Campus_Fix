import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../utils/enums.dart';

class AnalyticsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _isLoading = false;
  int _totalComplaints = 0;
  int _resolvedComplaints = 0;
  int _pendingComplaints = 0;
  int _criticalComplaints = 0;
  double _resolutionRate = 0.0;
  double _avgResolutionTimeHours = 0.0;
  
  Map<String, int> _categoryDistribution = {};
  Map<String, int> _departmentDistribution = {};
  Map<String, int> _issueTypeDistribution = {};

  bool get isLoading => _isLoading;
  int get totalComplaints => _totalComplaints;
  int get resolvedComplaints => _resolvedComplaints;
  int get pendingComplaints => _pendingComplaints;
  int get criticalComplaints => _criticalComplaints;
  double get resolutionRate => _resolutionRate;
  double get avgResolutionTimeHours => _avgResolutionTimeHours;
  Map<String, int> get categoryDistribution => _categoryDistribution;
  Map<String, int> get departmentDistribution => _departmentDistribution;
  Map<String, int> get issueTypeDistribution => _issueTypeDistribution;

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    notifyListeners();

    try {
      final complaints = await _firestoreService.getAllComplaints();
      
      _totalComplaints = complaints.length;
      _resolvedComplaints = complaints.where((c) => c.status == ComplaintStatus.resolved).length;
      _pendingComplaints = complaints.where((c) => c.status != ComplaintStatus.resolved && c.status != ComplaintStatus.rejected).length;
      _criticalComplaints = complaints.where((c) => c.priority == ComplaintPriority.critical).length;

      // Resolution Rate
      _resolutionRate = _totalComplaints > 0 
          ? (_resolvedComplaints / _totalComplaints) * 100 
          : 0.0;

      // Average Resolution Time (in Hours)
      final resolvedList = complaints.where((c) => c.status == ComplaintStatus.resolved && c.resolvedAt != null).toList();
      if (resolvedList.isNotEmpty) {
        final totalDuration = resolvedList.fold<Duration>(
          Duration.zero,
          (sum, c) => sum + c.resolvedAt!.difference(c.createdAt),
        );
        _avgResolutionTimeHours = totalDuration.inMinutes / (60.0 * resolvedList.length);
      } else {
        _avgResolutionTimeHours = 0.0;
      }

      // Distributions
      _categoryDistribution = {};
      _departmentDistribution = {};
      _issueTypeDistribution = {};

      for (final c in complaints) {
        _categoryDistribution[c.category] = (_categoryDistribution[c.category] ?? 0) + 1;
        _departmentDistribution[c.department] = (_departmentDistribution[c.department] ?? 0) + 1;
        _issueTypeDistribution[c.issueType] = (_issueTypeDistribution[c.issueType] ?? 0) + 1;
      }
    } catch (e) {
      debugPrint("Failed to fetch analytics: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

