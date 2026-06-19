import 'package:flutter/material.dart';
import '../../models/complaint_model.dart';
import '../../widgets/status_timeline.dart';
import 'package:intl/intl.dart';
import '../../utils/enums.dart';
import '../../widgets/full_screen_image_viewer.dart';
import '../../widgets/complaint_image_widget.dart';
import '../../theme/colors.dart';


class TrackingScreen extends StatelessWidget {
  final ComplaintModel complaint;

  const TrackingScreen({Key? key, required this.complaint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('TRACK COMPLAINT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complaint.title, 
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Submitted on ${DateFormat('MMM dd, yyyy - hh:mm a').format(complaint.createdAt)}', 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 28),
            
            Text(
              'TICKET STATUS',
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 14),
            StatusTimeline(currentStatus: complaint.status),
            const SizedBox(height: 32),

            // Original Issue Photo
            if (complaint.imageBase64 != null && complaint.imageBase64!.isNotEmpty) ...[
              Text(
                'SUBMITTED EVIDENCE PHOTO',
                style: TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
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
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2.5),
                    boxShadow: isDark
                        ? []
                        : const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13.5),
                    child: Container(
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
              ),
              const SizedBox(height: 32),
            ],

            Text(
              'TICKET DETAILS',
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 2.5),
                boxShadow: isDark
                    ? []
                    : const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Category', complaint.category),
                    Container(height: 1.5, color: isDark ? Colors.white24 : Colors.black12),
                    _buildDetailRow('Issue Type', complaint.issueType),
                    Container(height: 1.5, color: isDark ? Colors.white24 : Colors.black12),
                    _buildDetailRow('Department', complaint.department),
                    Container(height: 1.5, color: isDark ? Colors.white24 : Colors.black12),
                    _buildDetailRow('Building', complaint.building),
                    Container(height: 1.5, color: isDark ? Colors.white24 : Colors.black12),
                    _buildDetailRow('Floor', 'Floor ${complaint.floor}'),
                    Container(height: 1.5, color: isDark ? Colors.white24 : Colors.black12),
                    _buildDetailRow('Room / Area', 'Room ${complaint.room}'),
                    if (complaint.specificLocation.isNotEmpty) ...[
                      Container(height: 1.5, color: isDark ? Colors.white24 : Colors.black12),
                      _buildDetailRow('Specific Location', complaint.specificLocation),
                    ],
                    Container(height: 2.0, color: borderColor, margin: const EdgeInsets.symmetric(vertical: 8)),
                    Text(
                      'DESCRIPTION', 
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54, 
                        fontSize: 11, 
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complaint.description,
                      style: const TextStyle(fontWeight: FontWeight.bold, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
            
            // Admin Remarks for inProgress / rejected status
            if (complaint.status != ComplaintStatus.resolved && complaint.adminRemarks != null) ...[
              const SizedBox(height: 32),
              Text(
                'ADMIN REMARKS',
                style: TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E24) : AppColors.pastelPurple,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 2.5),
                  boxShadow: isDark
                      ? []
                      : const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  complaint.adminRemarks!,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],

            // Resolution Verification Details
            if (complaint.status == ComplaintStatus.resolved) ...[
              const SizedBox(height: 32),
              Text(
                'RESOLUTION VERIFICATION',
                style: TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E24) : AppColors.pastelMint,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 2.5),
                  boxShadow: isDark
                      ? []
                      : const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (complaint.resolvedAt != null)
                      Text(
                        'RESOLVED ON: ${DateFormat('MMM dd, yyyy - hh:mm a').format(complaint.resolvedAt!)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'REMARKS: ${complaint.adminRemarks ?? "No remarks provided."}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (complaint.resolutionImageBase64 != null && complaint.resolutionImageBase64!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'RESOLUTION PROOF PHOTO',
                        style: TextStyle(
                          fontWeight: FontWeight.w900, 
                          fontSize: 11, 
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
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
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13.5),
                            child: Container(
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
                      ),
                    ]
                  ],
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}


