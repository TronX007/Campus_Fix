import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint_model.dart';
import '../../theme/colors.dart';
import '../../utils/enums.dart';
import 'tracking_screen.dart';

class StudentComplaintsListScreen extends StatelessWidget {
  final String title;
  final bool onlyResolved;

  const StudentComplaintsListScreen({
    Key? key,
    required this.title,
    this.onlyResolved = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final List<ComplaintModel> filteredComplaints = onlyResolved
        ? complaintProvider.complaints
            .where((c) => c.status == ComplaintStatus.resolved)
            .toList()
        : complaintProvider.complaints;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: filteredComplaints.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredComplaints.length,
              itemBuilder: (context, index) {
                final c = filteredComplaints[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      c.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.category_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(c.category, style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ),
                    trailing: Chip(
                      label: Text(
                        c.status.displayName.toUpperCase(),
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: c.status == ComplaintStatus.resolved
                          ? AppColors.statusResolved
                          : c.status == ComplaintStatus.rejected
                              ? AppColors.statusRejected
                              : c.status == ComplaintStatus.inProgress
                                  ? AppColors.statusInProgress
                                  : AppColors.statusPending,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TrackingScreen(complaint: c)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              onlyResolved ? 'No resolved complaints' : 'No complaints filed yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              onlyResolved
                  ? 'None of your complaints have been marked as resolved yet.'
                  : 'Get started by filing a new complaint for any campus issues.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
