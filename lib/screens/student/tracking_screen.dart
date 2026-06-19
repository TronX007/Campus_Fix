import 'package:flutter/material.dart';
import '../../models/complaint_model.dart';
import '../../widgets/status_timeline.dart';
import 'package:intl/intl.dart';
import '../../utils/enums.dart';
import '../../widgets/full_screen_image_viewer.dart';
import '../../widgets/complaint_image_widget.dart';

class TrackingScreen extends StatelessWidget {
  final ComplaintModel complaint;

  const TrackingScreen({Key? key, required this.complaint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Complaint')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(complaint.title, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text('Submitted on ${DateFormat('MMM dd, yyyy - hh:mm a').format(complaint.createdAt)}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            
            const Text('Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StatusTimeline(currentStatus: complaint.status),
            const SizedBox(height: 32),

            // Original Issue Photo
            if (complaint.imageBase64 != null && complaint.imageBase64!.isNotEmpty) ...[
              const Text('Submitted Issue Photo:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImageViewer(
                        imageUrl: complaint.imageBase64!,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: ComplaintImageWidget(
                      imageUrl: complaint.imageBase64!,
                      fit: BoxFit.cover,
                      errorWidget: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 36),
                            SizedBox(height: 8),
                            Text('Failed to load image evidence', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Category', complaint.category),
                    const Divider(),
                    _buildDetailRow('Issue Type', complaint.issueType),
                    const Divider(),
                    _buildDetailRow('Department', complaint.department),
                    const Divider(),
                    _buildDetailRow('Building', complaint.building),
                    const Divider(),
                    _buildDetailRow('Floor', 'Floor ${complaint.floor}'),
                    const Divider(),
                    _buildDetailRow('Room / Area', 'Room ${complaint.room}'),
                    if (complaint.specificLocation.isNotEmpty) ...[
                      const Divider(),
                      _buildDetailRow('Specific Location', complaint.specificLocation),
                    ],
                    const Divider(),
                    const Text('Description', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(complaint.description),
                  ],
                ),
              ),
            ),
            
            // Admin Remarks for inProgress / rejected status
            if (complaint.status != ComplaintStatus.resolved && complaint.adminRemarks != null) ...[
              const SizedBox(height: 32),
              const Text('Admin Remarks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(complaint.adminRemarks!),
                ),
              ),
            ],

            // Resolution Verification Details
            if (complaint.status == ComplaintStatus.resolved) ...[
              const SizedBox(height: 32),
              const Text('Resolution Verification Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (complaint.resolvedAt != null)
                        Text(
                          'Resolved on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(complaint.resolvedAt!)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 8),
                      Text('Remarks: ${complaint.adminRemarks ?? "No remarks provided."}'),
                      if (complaint.resolutionImageBase64 != null && complaint.resolutionImageBase64!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('Resolution Proof Photo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageViewer(
                                  imageUrl: complaint.resolutionImageBase64!,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: ComplaintImageWidget(
                                imageUrl: complaint.resolutionImageBase64!,
                                fit: BoxFit.cover,
                                errorWidget: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red, size: 36),
                                      SizedBox(height: 8),
                                      Text('Failed to load resolution proof photo', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

