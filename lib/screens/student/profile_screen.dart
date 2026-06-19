import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/idea_provider.dart';
import '../../models/idea_model.dart';
import '../../models/complaint_model.dart';
import '../../widgets/app_buttons.dart';
import '../../theme/colors.dart';
import '../auth/login_screen.dart';
import 'tracking_screen.dart';
import '../../utils/enums.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedSubTab = 0; // 0 = Ideas, 1 = Complaints

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final ideaProvider = Provider.of<IdeaProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userId = authProvider.user?.uid ?? '';

    // Filter user's complaints and ideas
    final myComplaints = complaintProvider.complaints
        .where((c) => c.studentId == userId)
        .toList();
    final myIdeas = ideaProvider.ideas
        .where((idea) => idea.postedByUid == userId)
        .toList();

    // Calculate total upvotes received across all ideas
    int totalUpvotes = 0;
    for (var idea in myIdeas) {
      totalUpvotes += idea.upvotes.length;
    }

    return Stack(
      children: [
        // Looping animated background character
        Positioned(
          bottom: -20,
          right: -40,
          child: IgnorePointer(
            child: LoopingAnimatedCharacter(
              imagePath: 'assets/images/splash_illustration.png',
              height: 340,
              opacity: isDark ? 0.08 : 0.12,
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instagram Style Header Area
          Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2.5),
                  boxShadow: isDark
                      ? []
                      : const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: isDark ? Colors.white10 : AppColors.pastelPink,
                  child: Icon(
                    Icons.face_retouching_natural,
                    size: 48,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Filed', '${myComplaints.length}', isDark),
                    _buildStatItem('Proposed', '${myIdeas.length}', isDark),
                    _buildStatItem('Upvotes', '$totalUpvotes', isDark),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Bio Info
          Text(
            authProvider.user?.name ?? 'Student User',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            authProvider.user?.email ?? 'student@university.edu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : AppColors.pastelYellow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? Colors.white : Colors.black, width: 1.5),
            ),
            child: Text(
              'STUDENT MEMBER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Actions Row (Logout)
          PrimaryButton(
            text: 'Logout from App',
            color: AppColors.pastelRose,
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
          const SizedBox(height: 28),

          // Instagram Style Grid / List Tab Bar switcher
          Row(
            children: [
              Expanded(
                child: _buildSubTabItem(
                  index: 0,
                  icon: Icons.lightbulb,
                  label: 'My Ideas',
                  isSelected: _selectedSubTab == 0,
                  activeColor: AppColors.pastelOrange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSubTabItem(
                  index: 1,
                  icon: Icons.assignment_outlined,
                  label: 'My Complaints',
                  isSelected: _selectedSubTab == 1,
                  activeColor: AppColors.pastelMint,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tab Content
          _selectedSubTab == 0
              ? _buildIdeasTab(context, myIdeas, ideaProvider, isDark)
              : _buildComplaintsTab(context, myComplaints, isDark),
        ],
      ),
    ),
  ],
);
}

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color activeColor,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSubTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white12 : activeColor)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? Colors.white24 : Colors.black12),
            width: 2.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdeasTab(
    BuildContext context,
    List<IdeaModel> ideas,
    IdeaProvider ideaProvider,
    bool isDark,
  ) {
    if (ideas.isEmpty) {
      return _buildEmptyState(
        icon: Icons.lightbulb_outline,
        title: 'No Ideas Proposed Yet',
        subtitle: 'Share your ideas in the Innovation Board tab to make campus life better.',
        isDark: isDark,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ideas.length,
      itemBuilder: (context, index) {
        final idea = ideas[index];
        final catColor = AppColors.getCategoryColor(idea.category);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E24) : Colors.white,
            borderRadius: BorderRadius.circular(16),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : catColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white : Colors.black, width: 1.5),
                    ),
                    child: Text(
                      idea.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  // Delete Button
                  GestureDetector(
                    onTap: () => _confirmDeleteIdea(context, idea, ideaProvider),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red[900]!, width: 1.5),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red[900],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                idea.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                idea.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.thumb_up_alt_outlined,
                    size: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${idea.upvotes.length} upvotes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComplaintsTab(
    BuildContext context,
    List<ComplaintModel> complaints,
    bool isDark,
  ) {
    if (complaints.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_late_outlined,
        title: 'No Filed Complaints',
        subtitle: 'If you encounter any issues on campus, file a new complaint on the Dashboard.',
        isDark: isDark,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final c = complaints[index];
        final catColor = AppColors.getCategoryColor(c.category);
        final statusColor = c.status == ComplaintStatus.resolved
            ? AppColors.pastelMint
            : c.status == ComplaintStatus.rejected
                ? AppColors.pastelRose
                : AppColors.pastelYellow;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TrackingScreen(complaint: c)),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E24) : Colors.white,
              borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : catColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white : Colors.black, width: 1.5),
                      ),
                      child: Text(
                        c.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : statusColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.white : Colors.black, width: 1.5),
                      ),
                      child: Text(
                        c.status.displayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  c.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Location: ${c.building} - Room ${c.room}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white30 : Colors.black26,
          width: 2.0,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: isDark ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteIdea(
    BuildContext context,
    IdeaModel idea,
    IdeaProvider ideaProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isDark ? Colors.white : Colors.black, width: 2.5),
          ),
          backgroundColor: isDark ? const Color(0xFF1E1E24) : AppColors.backgroundLight,
          title: Text(
            'Delete Idea?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to permanently delete "${idea.title}"? This action cannot be undone.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await ideaProvider.deleteIdea(idea.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Idea deleted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete idea: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black, width: 1.5),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class LoopingAnimatedCharacter extends StatefulWidget {
  final String imagePath;
  final double height;
  final double opacity;

  const LoopingAnimatedCharacter({
    Key? key,
    required this.imagePath,
    required this.height,
    required this.opacity,
  }) : super(key: key);

  @override
  State<LoopingAnimatedCharacter> createState() => _LoopingAnimatedCharacterState();
}

class _LoopingAnimatedCharacterState extends State<LoopingAnimatedCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _yAnimation = Tween<double>(begin: 0.0, end: -15.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _yAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: child,
          ),
        );
      },
      child: Opacity(
        opacity: widget.opacity,
        child: Image.asset(
          widget.imagePath,
          height: widget.height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
