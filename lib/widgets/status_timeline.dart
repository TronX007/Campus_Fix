import 'package:flutter/material.dart';
import '../utils/enums.dart';
import '../theme/colors.dart';

class StatusTimeline extends StatelessWidget {
  final ComplaintStatus currentStatus;

  const StatusTimeline({Key? key, required this.currentStatus}) : super(key: key);

  int get _currentIndex {
    switch (currentStatus) {
      case ComplaintStatus.submitted: return 0;
      case ComplaintStatus.verified: return 1;
      case ComplaintStatus.assigned: return 2;
      case ComplaintStatus.inProgress: return 3;
      case ComplaintStatus.resolved: return 4;
      case ComplaintStatus.rejected: return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statuses = [
      ComplaintStatus.submitted,
      ComplaintStatus.verified,
      ComplaintStatus.assigned,
      ComplaintStatus.inProgress,
      currentStatus == ComplaintStatus.rejected ? ComplaintStatus.rejected : ComplaintStatus.resolved
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        final status = statuses[index];
        final isCompleted = index <= _currentIndex;
        final isLast = index == statuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppColors.primaryBlue : Colors.grey.shade300,
                  ),
                  child: isCompleted 
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? AppColors.primaryBlue : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  status.displayName,
                  style: TextStyle(
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black) : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
