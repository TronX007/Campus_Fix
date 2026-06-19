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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontSize: 18),
        ),
      ),
      body: filteredComplaints.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredComplaints.length,
              itemBuilder: (context, index) {
                final c = filteredComplaints[index];
                final Color catColor = AppColors.getCategoryColor(c.category);
                final Color statusColor = c.status == ComplaintStatus.resolved
                    ? AppColors.statusResolved
                    : c.status == ComplaintStatus.rejected
                        ? AppColors.statusRejected
                        : c.status == ComplaintStatus.inProgress
                            ? AppColors.statusInProgress
                            : AppColors.statusPending;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2.5),
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
                    borderRadius: BorderRadius.circular(17),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TrackingScreen(complaint: c)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Left icon
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : catColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2.0),
                                ),
                                child: Icon(
                                  c.status == ComplaintStatus.resolved ? Icons.check : Icons.error_outline,
                                  color: isDark ? Colors.white : Colors.black,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Middle text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.white12 : catColor.withOpacity(0.4),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: isDark ? Colors.white54 : Colors.black, width: 1.0),
                                          ),
                                          child: Text(
                                            c.category,
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Right side status pill & action arrow icon
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isDark ? Colors.white : Colors.black, width: 1.5),
                                    ),
                                    child: Text(
                                      c.status.displayName.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isDark ? Colors.white54 : Colors.black38, width: 1.5),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
