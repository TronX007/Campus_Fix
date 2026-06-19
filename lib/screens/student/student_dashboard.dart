import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/custom_cards.dart';
import '../../theme/colors.dart';
import 'new_complaint_screen.dart';
import 'tracking_screen.dart';
import 'innovation_board_screen.dart';
import 'student_complaints_list_screen.dart';
import '../auth/login_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'AU Fix - Student' : 'Innovation Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardHome(context, complaintProvider, authProvider),
          const InnovationBoardScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            activeIcon: Icon(Icons.lightbulb),
            label: 'Innovations',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHome(
    BuildContext context,
    ComplaintProvider complaintProvider,
    AuthProvider authProvider,
  ) {
    return complaintProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${authProvider.user?.name ?? 'Student'}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    StatCard(
                      title: 'Total',
                      value: '${complaintProvider.complaints.length}',
                      icon: Icons.assignment,
                      color: AppColors.primaryBlue,
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
                      title: 'Resolved',
                      value:
                          '${complaintProvider.complaints.where((c) => c.status.name == 'resolved').length}',
                      icon: Icons.check_circle,
                      color: AppColors.statusResolved,
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
                const SizedBox(height: 32),
                const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NewComplaintScreen()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('New Complaint'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('Recent Complaints', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...complaintProvider.complaints.take(3).map((c) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(c.category),
                        trailing: Chip(
                          label: Text(
                            c.status.name.toUpperCase(),
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                          backgroundColor: c.status.name == 'resolved'
                              ? AppColors.statusResolved
                              : AppColors.statusPending,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TrackingScreen(complaint: c)),
                          );
                        },
                      ),
                    )),
              ],
            ),
          );
  }
}
