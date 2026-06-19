import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/complaint_model.dart';
import '../models/complaint_cluster_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../utils/enums.dart';

class ComplaintProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  
  List<ComplaintModel> _complaints = [];
  List<ComplaintClusterModel> _clusters = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ComplaintModel> get complaints => _complaints;
  List<ComplaintClusterModel> get clusters => _clusters;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStudentComplaints(String studentId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _complaints = await _firestoreService.getComplaintsForStudent(studentId);
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint("loadStudentComplaints error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllComplaints() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _complaints = await _firestoreService.getAllComplaints();
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint("loadAllComplaints error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addComplaint(ComplaintModel complaint, {File? imageFile}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      String? imageBase64;
      if (imageFile != null) {
        try {
          imageBase64 = await _storageService
              .uploadComplaintImage(complaint.id, imageFile)
              .timeout(const Duration(seconds: 15));
        } catch (e) {
          debugPrint("Image upload failed: $e");
          throw FirebaseException(
            plugin: 'firebase_storage',
            code: 'upload-failed',
            message: 'Upload failed.',
          );
        }
      }
      
      final updatedComplaint = complaint.copyWith(imageBase64: imageBase64);
      print("[Firestore] Starting document write for complaint ID: ${updatedComplaint.id}");
      await _firestoreService.addComplaint(updatedComplaint);
      print("[Firestore] Document write completed successfully.");
      // Re-load student complaints to get auto-clustering updates (e.g. clusterId)
      try {
        _complaints = await _firestoreService.getComplaintsForStudent(updatedComplaint.studentId);
      } catch (loadErr) {
        _complaints.insert(0, updatedComplaint);
      }
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint("addComplaint error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<ComplaintModel>> checkForSimilarComplaints({
    required String category,
    required String issueType,
    required String building,
    required String floor,
    required String room,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final matches = await _firestoreService.findSimilarUnresolvedComplaints(
        category: category,
        issueType: issueType,
        building: building,
        floor: floor,
        room: room,
      );
      return matches;
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint("checkForSimilarComplaints error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> joinExistingComplaint(String complaintId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      print("[Firestore] Incrementing affected student count for complaint ID: $complaintId");
      await _firestoreService.incrementAffectedStudentCount(complaintId);
      print("[Firestore] Increment completed successfully.");
      
      // Locally update the list
      final index = _complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        _complaints[index] = _complaints[index].copyWith(
          affectedStudentCount: _complaints[index].affectedStudentCount + 1,
          updatedAt: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint("joinExistingComplaint error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateComplaintStatus(
    String complaintId,
    ComplaintStatus status, {
    String? remarks,
    ComplaintPriority? priority,
    File? resolutionImageFile,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      String? resolutionImageBase64;
      DateTime? resolvedAt;
      
      if (status == ComplaintStatus.resolved) {
        resolvedAt = DateTime.now();
        if (resolutionImageFile != null) {
          try {
            resolutionImageBase64 = await _storageService
                .uploadResolutionImage(complaintId, resolutionImageFile)
                .timeout(const Duration(seconds: 15));
          } catch (e) {
            debugPrint("Resolution proof image upload failed: $e");
            throw FirebaseException(
              plugin: 'firebase_storage',
              code: 'upload-failed',
              message: 'Upload failed.',
            );
          }
        }
      }
      
      await _firestoreService.updateComplaintStatus(
        complaintId,
        status,
        remarks: remarks,
        newPriority: priority,
        resolutionImageBase64: resolutionImageBase64,
        resolvedAt: resolvedAt,
      );
      
      final index = _complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        _complaints[index] = _complaints[index].copyWith(
          status: status,
          adminRemarks: remarks ?? _complaints[index].adminRemarks,
          priority: priority ?? _complaints[index].priority,
          resolutionImageBase64: resolutionImageBase64 ?? _complaints[index].resolutionImageBase64,
          resolvedAt: resolvedAt ?? _complaints[index].resolvedAt,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint("updateComplaintStatus error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Clustering Actions
  Future<void> loadClusters() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _clusters = await _firestoreService.getClusters();
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint("loadClusters error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> groupComplaintsIntoCluster(
    String clusterId,
    String category,
    String department,
    List<String> complaintIds,
  ) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final newCluster = ComplaintClusterModel(
        id: clusterId,
        category: category,
        department: department,
        complaintIds: complaintIds,
        status: ComplaintStatus.submitted,
        createdAt: DateTime.now(),
        affectedStudentCount: complaintIds.length,
      );
      
      await _firestoreService.createOrUpdateCluster(newCluster);
      _clusters.insert(0, newCluster);
      
      // Locally update the clusterId on the complaints
      for (var i = 0; i < _complaints.length; i++) {
        if (complaintIds.contains(_complaints[i].id)) {
          _complaints[i] = _complaints[i].copyWith(clusterId: clusterId);
        }
      }
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint("groupComplaintsIntoCluster error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String _parseError(dynamic e) {
    if (e is TimeoutException) {
      return "Operation timed out. Please check database connectivity.";
    }
    if (e is FirebaseException) {
      if (e.code == 'upload-failed') {
        return "Upload failed.";
      }
      if (e.code == 'permission-denied') {
        return "Database error occurred.";
      }
      if (e.code == 'network-request-failed') {
        return "Network connection lost. Please check your internet.";
      }
      return e.message ?? "A database error occurred.";
    }
    final str = e.toString().toLowerCase();
    if (str.contains('permission') || str.contains('denied')) {
      return "Database error occurred.";
    }
    if (str.contains('network') || str.contains('timeout') || str.contains('offline')) {
      return "Network connection lost.";
    }
    return e.toString();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

