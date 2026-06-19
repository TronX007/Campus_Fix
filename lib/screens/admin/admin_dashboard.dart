import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/custom_cards.dart';
import '../../theme/colors.dart';
import '../auth/login_screen.dart';
import 'admin_complaint_detail.dart';
import 'admin_clusters_screen.dart';
import 'heatmap_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Provider.of<AnalyticsProvider>(context, listen: false).fetchAnalytics();
        if (mounted) {
          await Provider.of<ComplaintProvider>(context, listen: false).loadAllComplaints();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Provider.of<ComplaintProvider>(context, listen: false).errorMessage ??
                    'Failed to load dashboard data: $e',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final analytics = Provider.of<AnalyticsProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AU Fix - Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.hub),
            tooltip: 'Manage Clusters',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminClustersScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Campus Heatmap',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HeatmapScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              analytics.fetchAnalytics();
              complaintProvider.loadAllComplaints();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          )
        ],
      ),
      body: analytics.isLoading || complaintProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard Overview', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.15,
                    children: [
                      StatCard(title: 'Total', value: '${analytics.totalComplaints}', icon: Icons.analytics, color: AppColors.primaryBlue),
                      StatCard(title: 'Pending', value: '${analytics.pendingComplaints}', icon: Icons.pending_actions, color: AppColors.statusPending),
                      StatCard(title: 'Resolved', value: '${analytics.resolvedComplaints}', icon: Icons.check_circle, color: AppColors.statusResolved),
                      StatCard(title: 'Critical', value: '${analytics.criticalComplaints}', icon: Icons.warning, color: AppColors.statusRejected),
                      StatCard(title: 'Res. Rate', value: '${analytics.resolutionRate.toStringAsFixed(1)}%', icon: Icons.speed, color: Colors.teal),
                      StatCard(title: 'Avg Time', value: '${analytics.avgResolutionTimeHours.toStringAsFixed(1)} hrs', icon: Icons.timer, color: Colors.indigo),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Complaint Status Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  if (analytics.totalComplaints > 0)
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: AppColors.statusResolved,
                              value: analytics.resolvedComplaints.toDouble(),
                              title: 'Resolved',
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: AppColors.statusPending,
                              value: analytics.pendingComplaints.toDouble(),
                              title: 'Pending',
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  const Text('Recent Complaints', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...complaintProvider.complaints.map((c) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${c.department} • ${c.priority.name.toUpperCase()}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AdminComplaintDetail(complaint: c)));
                      },
                    ),
                  )),
                ],
              ),
            ),
    );
  }
}
