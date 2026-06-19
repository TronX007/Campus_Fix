import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint_model.dart';
import '../../models/complaint_cluster_model.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';

class AdminClustersScreen extends StatefulWidget {
  const AdminClustersScreen({Key? key}) : super(key: key);

  @override
  State<AdminClustersScreen> createState() => _AdminClustersScreenState();
}

class _AdminClustersScreenState extends State<AdminClustersScreen> {
  String _selectedCategory = AppConstants.complaintCategories.first;
  String _selectedDepartment = AppConstants.departments.first;
  final List<String> _selectedComplaintIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).loadAllComplaints();
      Provider.of<ComplaintProvider>(context, listen: false).loadClusters();
    });
  }

  // Note: Manual clustering has been replaced with the automated detection system in FirestoreService.addComplaint

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComplaintProvider>(context);
    final allComplaints = provider.complaints;
    final clusters = provider.clusters;

    // Filter complaints that are not already in a cluster
    final eligibleComplaints = allComplaints.where((c) =>
        (c.clusterId == null || c.clusterId!.isEmpty)).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Clusters'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.hub), text: 'Detected Clusters'),
              Tab(icon: Icon(Icons.info_outline), text: 'Unclustered Issues'),
            ],
          ),
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Tab 1: Existing Clusters
                  _buildClustersList(clusters, allComplaints),

                  // Tab 2: Automated Status & Unclustered Issues
                  _buildUnclusteredIssuesView(eligibleComplaints),
                ],
              ),
      ),
    );
  }

  Widget _buildClustersList(List<ComplaintClusterModel> clusters, List<ComplaintModel> allComplaints) {
    if (clusters.isEmpty) {
      return const Center(child: Text('No active clusters found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: clusters.length,
      itemBuilder: (context, index) {
        final cluster = clusters[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text('${cluster.category} - ${cluster.department}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Affected Students: ${cluster.affectedStudentCount} • Status: ${cluster.status.displayName}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Complaints in this Cluster:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...cluster.complaintIds.map((id) {
                      final comp = allComplaints.firstWhere((c) => c.id == id,
                          orElse: () => ComplaintModel(
                                id: id,
                                title: 'Unknown Title ($id)',
                                description: '',
                                category: '',
                                issueType: '',
                                department: '',
                                building: '',
                                floor: '',
                                room: '',
                                specificLocation: '',
                                priority: ComplaintPriority.low,
                                status: ComplaintStatus.submitted,
                                imageBase64: null,
                                resolutionImageBase64: null,
                                studentId: '',
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ));
                      return ListTile(
                        dense: true,
                        title: Text(comp.title),
                        subtitle: Text('${comp.building}, Floor ${comp.floor}, Room ${comp.room}'),
                        trailing: Chip(
                          label: Text(comp.status.displayName, style: const TextStyle(fontSize: 10)),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnclusteredIssuesView(List<ComplaintModel> eligibleComplaints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner showing automated clustering status
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue.shade700, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Automated Detection Active',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AU Fix automatically groups unresolved complaints with matching Category, Building, Floor, and Room into unified clusters. No manual action is required.',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Unique / Unclustered Complaints (${eligibleComplaints.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'These are individual issues that do not currently have overlapping duplicate complaints in the same location.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (eligibleComplaints.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text(
                  'No unclustered complaints found.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: eligibleComplaints.length,
              itemBuilder: (context, index) {
                final comp = eligibleComplaints[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.assignment_late, color: Colors.grey),
                    ),
                    title: Text(comp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${comp.building}, Floor ${comp.floor}, Room ${comp.room} • ${comp.category}'),
                    trailing: Chip(
                      label: Text(
                        comp.status.displayName,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
