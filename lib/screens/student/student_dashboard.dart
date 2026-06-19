import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/custom_cards.dart';
import '../../widgets/app_buttons.dart';
import '../../theme/colors.dart';
import 'new_complaint_screen.dart';
import 'tracking_screen.dart';
import 'innovation_board_screen.dart';
import 'student_complaints_list_screen.dart';
import '../auth/login_screen.dart';
import 'profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        try {
          await Provider.of<ComplaintProvider>(context, listen: false)
              .loadStudentComplaints(authProvider.user!.uid);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Provider.of<ComplaintProvider>(context, listen: false).errorMessage ??
                      'Failed to load complaints: $e',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'AU FIX'
              : _currentIndex == 1
                  ? 'INNOVATION BOARD'
                  : 'MY PROFILE',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 20),
        ),
        elevation: 0,
        actions: _currentIndex == 2
            ? []
            : [
                Container(
                  margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : AppColors.pastelPink,
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2.0),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout, size: 18),
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                  ),
                )
              ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInBack,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final slideIn = Tween<Offset>(
            begin: const Offset(0.0, 0.08),
            end: Offset.zero,
          ).animate(animation);
          
          return SlideTransition(
            position: slideIn,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: _currentIndex == 0
            ? Container(
                key: const ValueKey('dashboard'),
                child: _buildDashboardHome(context, complaintProvider, authProvider),
              )
            : _currentIndex == 1
                ? const InnovationBoardScreen(key: ValueKey('innovation'))
                : const ProfileScreen(key: ValueKey('profile')),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0, top: 8.0),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E24) : Colors.black,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: isDark ? Colors.white : Colors.black,
                width: 2.5,
              ),
              boxShadow: isDark
                  ? []
                  : const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'DASHBOARD', AppColors.pastelMint),
                _buildNavItem(1, Icons.lightbulb_outline, Icons.lightbulb, 'INNOVATIONS', AppColors.pastelOrange),
                _buildNavItem(2, Icons.person_outline, Icons.person, 'PROFILE', AppColors.pastelPink),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData inactiveIcon, IconData activeIcon, String label, Color activeBgColor) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? Colors.white12 : activeBgColor)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected 
              ? Border.all(color: isDark ? Colors.white : Colors.black, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected 
                  ? (isDark ? Colors.white : Colors.black) 
                  : (isDark ? Colors.grey : Colors.white70),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHome(
    BuildContext context,
    ComplaintProvider complaintProvider,
    AuthProvider authProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String formattedDate = DateFormat('EEE, d MMMM').format(DateTime.now());

    return complaintProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium profile welcome header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: isDark ? Colors.white12 : AppColors.pastelPink,
                        child: Icon(
                          Icons.face,
                          color: isDark ? Colors.white : Colors.black,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${authProvider.user?.name ?? 'Student'} 👋',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : AppColors.pastelYellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2.0),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.notifications_none,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notification Center coming soon!'),
                                backgroundColor: Colors.black,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const AnimatedIllustrationCard(
                  imagePath: 'assets/images/complaint_illustration.png',
                  title: 'Got Campus Complaints?',
                  subtitle: 'Report maintenance, Wi-Fi, or hostel issues, and our team will resolve them promptly!',
                  cardColor: AppColors.pastelYellow,
                ),
                const SizedBox(height: 24),
                
                // Stat Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    StatCard(
                      title: 'Total Filed',
                      value: '${complaintProvider.complaints.length}',
                      icon: Icons.assignment,
                      color: AppColors.pastelPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudentComplaintsListScreen(
                              title: 'All Filed Complaints',
                              onlyResolved: false,
                            ),
                          ),
                        );
                      },
                    ),
                    StatCard(
                      title: 'Resolved Tickets',
                      value:
                          '${complaintProvider.complaints.where((c) => c.status.name == 'resolved').length}',
                      icon: Icons.check_circle,
                      color: AppColors.pastelMint,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudentComplaintsListScreen(
                              title: 'Resolved Complaints',
                              onlyResolved: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                
                // Quick Actions Box
                Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'File a New Complaint',
                  color: AppColors.primaryBlue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewComplaintScreen()),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Recent Complaints
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT COMPLAINTS',
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    if (complaintProvider.complaints.length > 3)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StudentComplaintsListScreen(
                                title: 'All Filed Complaints',
                                onlyResolved: false,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'VIEW ALL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.secondaryBlue : AppColors.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (complaintProvider.complaints.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2.5),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text(
                          'No complaints filed yet.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                else
                  ...complaintProvider.complaints.take(3).map((c) {
                    final Color catColor = AppColors.getCategoryColor(c.category);
                    final Color statusColor = c.status.name == 'resolved'
                        ? AppColors.statusResolved
                        : c.status.name == 'rejected'
                            ? AppColors.statusRejected
                            : c.status.name == 'inProgress'
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
                                  // Left side category colored circle indicator
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white10 : catColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2.0),
                                    ),
                                    child: Icon(
                                      c.status.name == 'resolved' ? Icons.check : Icons.error_outline,
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
                                            // Category label chip style
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
                                          c.status.name.toUpperCase(),
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
                  }),
              ],
            ),
          );
  }
}

