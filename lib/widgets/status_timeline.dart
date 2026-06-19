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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;

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
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted 
                        ? (isDark ? AppColors.secondaryBlue : AppColors.pastelMint)
                        : (isDark ? Colors.white10 : Colors.white),
                    border: Border.all(color: borderColor, width: 2.5),
                  ),
                  child: isCompleted 
                    ? Icon(
                        status == ComplaintStatus.rejected ? Icons.close : Icons.check, 
                        size: 16, 
                        color: isDark ? Colors.white : Colors.black,
                      )
                    : null,
                ),
                if (!isLast)
                  Container(
                    width: 3,
                    height: 40,
                    color: isCompleted ? borderColor : Colors.grey.shade400,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  status.displayName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.5,
                    fontWeight: isCompleted ? FontWeight.w900 : FontWeight.bold,
                    color: isCompleted 
                        ? (isDark ? Colors.white : Colors.black) 
                        : Colors.grey.shade500,
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

