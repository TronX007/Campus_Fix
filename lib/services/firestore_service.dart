import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_model.dart';
import '../models/complaint_cluster_model.dart';
import '../models/idea_model.dart';
import '../utils/enums.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch complaints for a specific student
  Future<List<ComplaintModel>> getComplaintsForStudent(String studentId) async {
    final querySnapshot = await _db
        .collection(AppConstants.complaintsCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .get()
        .timeout(const Duration(seconds: 10));

    return querySnapshot.docs
        .map((doc) => ComplaintModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Fetch all complaints for admin
  Future<List<ComplaintModel>> getAllComplaints() async {
    final querySnapshot = await _db
        .collection(AppConstants.complaintsCollection)
        .orderBy('createdAt', descending: true)
        .get()
        .timeout(const Duration(seconds: 10));

    return querySnapshot.docs
        .map((doc) => ComplaintModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Add a new complaint and auto-cluster it if similar unresolved complaints exist
  Future<void> addComplaint(ComplaintModel complaint) async {
    // 1. Write the complaint document to Firestore first
    await _db
        .collection(AppConstants.complaintsCollection)
        .doc(complaint.id)
        .set(complaint.toMap())
        .timeout(const Duration(seconds: 10));

    try {
      // 2. Query other unresolved complaints with matching category, building, floor, room
      final similar = await findSimilarUnresolvedComplaints(
        category: complaint.category,
        issueType: complaint.issueType,
        building: complaint.building,
        floor: complaint.floor,
        room: complaint.room,
      );

      // Filter out the newly created complaint from matches
      final otherSimilar = similar.where((c) => c.id != complaint.id).toList();

      if (otherSimilar.isNotEmpty) {
        print("[AutoCluster] Found ${otherSimilar.length} similar unresolved complaints.");
        
        // Check if any of these similar complaints is already in an existing cluster
        String? existingClusterId;
        for (final sim in otherSimilar) {
          if (sim.clusterId != null && sim.clusterId!.isNotEmpty) {
            existingClusterId = sim.clusterId;
            break;
          }
        }

        if (existingClusterId != null) {
          print("[AutoCluster] Adding to existing cluster ID: $existingClusterId");
          final clusterRef = _db.collection(AppConstants.complaintClustersCollection).doc(existingClusterId);
          
          await _db.runTransaction((transaction) async {
            final snapshot = await transaction.get(clusterRef);
            if (snapshot.exists) {
              final data = snapshot.data();
              if (data != null) {
                final complaintIds = List<String>.from(data['complaintIds'] ?? []);
                if (!complaintIds.contains(complaint.id)) {
                  complaintIds.add(complaint.id);
                  transaction.update(clusterRef, {
                    'complaintIds': complaintIds,
                    'affectedStudentCount': complaintIds.length,
                  });
                  // Update current complaint's clusterId field in DB
                  transaction.update(
                    _db.collection(AppConstants.complaintsCollection).doc(complaint.id),
                    {'clusterId': existingClusterId},
                  );
                }
              }
            }
          }).timeout(const Duration(seconds: 10));
        } else {
          // No existing cluster. Create a new auto-detected cluster with all matching unclustered complaints + current one
          final newClusterId = 'cluster_${DateTime.now().millisecondsSinceEpoch}';
          print("[AutoCluster] Creating a new cluster ID: $newClusterId");
          
          final allComplaintIds = otherSimilar.map((c) => c.id).toList();
          allComplaintIds.add(complaint.id);

          final newCluster = ComplaintClusterModel(
            id: newClusterId,
            category: complaint.category,
            department: complaint.department,
            complaintIds: allComplaintIds,
            status: ComplaintStatus.submitted,
            createdAt: DateTime.now(),
            affectedStudentCount: allComplaintIds.length,
          );

          final batch = _db.batch();
          batch.set(_db.collection(AppConstants.complaintClustersCollection).doc(newClusterId), newCluster.toMap());
          for (final id in allComplaintIds) {
            batch.update(_db.collection(AppConstants.complaintsCollection).doc(id), {'clusterId': newClusterId});
          }
          await batch.commit().timeout(const Duration(seconds: 15));
        }
      }
    } catch (e) {
      // Catch error so complaint submission itself does not fail due to auto-clustering failure
      print("[AutoCluster] Error during automated cluster detection: $e");
    }
  }

  // Delete a complaint
  Future<void> deleteComplaint(String complaintId) async {
    await _db
        .collection(AppConstants.complaintsCollection)
        .doc(complaintId)
        .delete()
        .timeout(const Duration(seconds: 10));
  }

  // Update complaint status, priority, admin remarks, and resolution proof
  Future<void> updateComplaintStatus(
    String complaintId,
    ComplaintStatus newStatus, {
    String? remarks,
    ComplaintPriority? newPriority,
    String? resolutionImageBase64,
    DateTime? resolvedAt,
  }) async {
    final Map<String, dynamic> data = {
      'status': newStatus.name,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (remarks != null) {
      data['adminRemarks'] = remarks;
    }
    if (newPriority != null) {
      data['priority'] = newPriority.name;
    }
    if (resolutionImageBase64 != null) {
      data['resolutionImageBase64'] = resolutionImageBase64;
    }
    if (resolvedAt != null) {
      data['resolvedAt'] = resolvedAt.toIso8601String();
    }

    await _db
        .collection(AppConstants.complaintsCollection)
        .doc(complaintId)
        .update(data)
        .timeout(const Duration(seconds: 10));
  }

  // Fetch all complaint clusters
  Future<List<ComplaintClusterModel>> getClusters() async {
    final querySnapshot = await _db
        .collection(AppConstants.complaintClustersCollection)
        .orderBy('createdAt', descending: true)
        .get()
        .timeout(const Duration(seconds: 10));

    return querySnapshot.docs
        .map((doc) => ComplaintClusterModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Create or update a complaint cluster
  Future<void> createOrUpdateCluster(ComplaintClusterModel cluster) async {
    await _db
        .collection(AppConstants.complaintClustersCollection)
        .doc(cluster.id)
        .set(cluster.toMap())
        .timeout(const Duration(seconds: 10));

    // Also update all complaints in this cluster to point to this clusterId
    final batch = _db.batch();
    for (final id in cluster.complaintIds) {
      final docRef = _db.collection(AppConstants.complaintsCollection).doc(id);
      batch.update(docRef, {'clusterId': cluster.id});
    }
    await batch.commit().timeout(const Duration(seconds: 15));
  }

  // Find similar unresolved complaints by building, floor, room, category, and issueType
  Future<List<ComplaintModel>> findSimilarUnresolvedComplaints({
    required String category,
    required String issueType,
    required String building,
    required String floor,
    required String room,
  }) async {
    final querySnapshot = await _db
        .collection(AppConstants.complaintsCollection)
        .where('building', isEqualTo: building)
        .get()
        .timeout(const Duration(seconds: 10));

    return querySnapshot.docs
        .map((doc) => ComplaintModel.fromMap(doc.data(), doc.id))
        .where((c) =>
            c.floor == floor &&
            c.room == room &&
            c.category == category &&
            c.issueType == issueType &&
            c.status != ComplaintStatus.resolved &&
            c.status != ComplaintStatus.rejected)
        .toList();
  }

  // Increment affected student count
  Future<void> incrementAffectedStudentCount(String complaintId) async {
    await _db
        .collection(AppConstants.complaintsCollection)
        .doc(complaintId)
        .update({
          'affectedStudentCount': FieldValue.increment(1),
          'updatedAt': DateTime.now().toIso8601String(),
        })
        .timeout(const Duration(seconds: 10));
  }

  // --- Innovation Board Methods ---

  // Fetch all ideas
  Future<List<IdeaModel>> getIdeas() async {
    final querySnapshot = await _db
        .collection(AppConstants.ideasCollection)
        .orderBy('timestamp', descending: true)
        .get()
        .timeout(const Duration(seconds: 10));

    return querySnapshot.docs
        .map((doc) => IdeaModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Fetch ideas stream (live feed)
  Stream<List<IdeaModel>> getIdeasStream() {
    return _db
        .collection(AppConstants.ideasCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IdeaModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add a new idea
  Future<void> addIdea(IdeaModel idea) async {
    await _db
        .collection(AppConstants.ideasCollection)
        .doc(idea.id)
        .set(idea.toMap())
        .timeout(const Duration(seconds: 10));
  }

  // Toggle upvote for an idea
  Future<void> toggleUpvoteIdea(String ideaId, String userId, bool upvote) async {
    await _db
        .collection(AppConstants.ideasCollection)
        .doc(ideaId)
        .update({
          'upvotes': upvote
              ? FieldValue.arrayUnion([userId])
              : FieldValue.arrayRemove([userId]),
        })
        .timeout(const Duration(seconds: 10));
  }

  // Delete an idea
  Future<void> deleteIdea(String ideaId) async {
    await _db
        .collection(AppConstants.ideasCollection)
        .doc(ideaId)
        .delete()
        .timeout(const Duration(seconds: 10));
  }
}

