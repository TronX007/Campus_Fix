import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/idea_provider.dart';
import '../../widgets/custom_cards.dart';
import '../../widgets/complaint_image_widget.dart';
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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Provider.of<AnalyticsProvider>(context, listen: false).fetchAnalytics();
        if (mounted) {
          await Provider.of<ComplaintProvider>(context, listen: false).loadAllComplaints();
        }
        if (mounted) {
          await Provider.of<IdeaProvider>(context, listen: false).loadIdeas();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'AU Fix - Admin' : 'Top Featured Ideas',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontSize: 20),
        ),
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
              if (_currentIndex == 0) {
                analytics.fetchAnalytics();
                complaintProvider.loadAllComplaints();
              } else {
                Provider.of<IdeaProvider>(context, listen: false).loadIdeas();
              }
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
          : AnimatedSwitcher(
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
                  ? _buildDashboardHome(context, analytics, complaintProvider)
                  : _buildFeaturedIdeasView(context),
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
                _buildNavItem(0, Icons.assignment_outlined, Icons.assignment, 'COMPLAINTS', AppColors.pastelMint),
                _buildNavItem(1, Icons.lightbulb_outline, Icons.lightbulb, 'TOP IDEAS', AppColors.pastelOrange),
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
                  : (isDark ? Colors.white54 : Colors.white70),
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHome(BuildContext context, AnalyticsProvider analytics, ComplaintProvider complaintProvider) {
    return SingleChildScrollView(
      key: const ValueKey('dashboard'),
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
              StatCard(title: 'Total', value: '${analytics.totalComplaints}', icon: Icons.analytics, color: AppColors.pastelPurple),
              StatCard(title: 'Pending', value: '${analytics.pendingComplaints}', icon: Icons.pending_actions, color: AppColors.pastelOrange),
              StatCard(title: 'Resolved', value: '${analytics.resolvedComplaints}', icon: Icons.check_circle, color: AppColors.pastelMint),
              StatCard(title: 'Critical', value: '${analytics.criticalComplaints}', icon: Icons.warning, color: AppColors.pastelRose),
              StatCard(title: 'Res. Rate', value: '${analytics.resolutionRate.toStringAsFixed(1)}%', icon: Icons.speed, color: AppColors.pastelTeal),
              StatCard(title: 'Avg Time', value: '${analytics.avgResolutionTimeHours.toStringAsFixed(1)} hrs', icon: Icons.timer, color: AppColors.pastelBlue),
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
    );
  }

  Widget _buildFeaturedIdeasView(BuildContext context) {
    final ideaProvider = Provider.of<IdeaProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (ideaProvider.isLoading && ideaProvider.ideas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Group and pick the top upvoted post per category
    final Map<String, IdeaModel> topIdeaPerCategory = {};
    for (final idea in ideaProvider.ideas) {
      final category = idea.category;
      final currentTop = topIdeaPerCategory[category];
      
      if (currentTop == null) {
        topIdeaPerCategory[category] = idea;
      } else {
        final currentUpvotes = currentTop.upvotes.length;
        final ideaUpvotes = idea.upvotes.length;
        if (ideaUpvotes > currentUpvotes) {
          topIdeaPerCategory[category] = idea;
        } else if (ideaUpvotes == currentUpvotes) {
          if (idea.timestamp.isAfter(currentTop.timestamp)) {
            topIdeaPerCategory[category] = idea;
          }
        }
      }
    }

    final topIdeas = topIdeaPerCategory.values.toList()
      ..sort((a, b) => b.upvotes.length.compareTo(a.upvotes.length));

    if (topIdeas.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ideaProvider.loadIdeas(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : AppColors.pastelYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2.5),
                ),
                child: Icon(Icons.lightbulb_outline, size: 64, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 24),
              Text(
                'No ideas found in the system yet.',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ideas posted by students in the Innovation Hub will appear here grouped by category highlights.',
                style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final borderColor = isDark ? Colors.white : Colors.black;
    final shadowColor = isDark ? Colors.white : Colors.black;

    return RefreshIndicator(
      onRefresh: () => ideaProvider.loadIdeas(),
      child: ListView.builder(
        key: const ValueKey('featured_ideas'),
        padding: const EdgeInsets.all(16.0),
        itemCount: topIdeas.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: AnimatedIllustrationCard(
                imagePath: 'assets/images/innovation_illustration.png',
                title: 'Innovation Hub Highlights',
                subtitle: 'Showing the most upvoted proposed idea from each active category. Use this to prioritize funding or approval.',
                cardColor: AppColors.pastelYellow,
              ),
            );
          }
          
          final idea = topIdeas[index - 1];
          final upvoteCount = idea.upvotes.length;
          final catColor = AppColors.getCategoryColor(idea.category);

          return Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E24) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 2.5),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: shadowColor,
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : catColor,
                      border: Border(bottom: BorderSide(color: borderColor, width: 2.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          idea.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black26 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Text(
                            'TOP POST',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          idea.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          idea.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (idea.imageBase64 != null && idea.imageBase64!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: borderColor, width: 2.0),
                                ),
                                child: ComplaintImageWidget(
                                  imageBase64: idea.imageBase64!,
                                  height: 180,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isDark ? Colors.white12 : AppColors.pastelRose,
                                  child: Icon(
                                    idea.isAnonymous ? Icons.lock_outline : Icons.person,
                                    color: isDark ? Colors.white : Colors.black,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  idea.isAnonymous ? 'Anonymous Student' : idea.postedByName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : AppColors.pastelMint,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor, width: 2.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.thumb_up,
                                    color: isDark ? Colors.white : Colors.black,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$upvoteCount upvotes',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
