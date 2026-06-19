import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/idea_provider.dart';
import '../../models/idea_model.dart';
import '../../widgets/complaint_image_widget.dart';
import '../../widgets/full_screen_image_viewer.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import 'new_idea_screen.dart';

class InnovationBoardScreen extends StatefulWidget {
  const InnovationBoardScreen({Key? key}) : super(key: key);

  @override
  State<InnovationBoardScreen> createState() => _InnovationBoardScreenState();
}

class _InnovationBoardScreenState extends State<InnovationBoardScreen> {
  String _selectedCategory = 'All';
  String _selectedSort = 'Newest'; // 'Newest' or 'Most Upvoted'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IdeaProvider>(context, listen: false).loadIdeas();
    });
  }

  String _getRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  List<IdeaModel> _getFilteredAndSortedIdeas(List<IdeaModel> rawIdeas) {
    // 1. Filter by category
    List<IdeaModel> filtered = rawIdeas;
    if (_selectedCategory != 'All') {
      filtered = rawIdeas.where((idea) => idea.category == _selectedCategory).toList();
    }

    // 2. Sort
    if (_selectedSort == 'Newest') {
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else if (_selectedSort == 'Most Upvoted') {
      filtered.sort((a, b) => b.upvotes.length.compareTo(a.upvotes.length));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final ideaProvider = Provider.of<IdeaProvider>(context);
    final currentUserId = authProvider.user?.uid ?? '';

    final filteredIdeas = _getFilteredAndSortedIdeas(ideaProvider.ideas);

    return Scaffold(
      body: Column(
        children: [
          // Filter Chips and Sort Dropdown Header
          _buildFiltersHeader(context),
          const Divider(height: 1),

          // Main Feed Section
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ideaProvider.loadIdeas();
              },
              child: ideaProvider.isLoading && ideaProvider.ideas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredIdeas.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          itemCount: filteredIdeas.length,
                          itemBuilder: (context, index) {
                            final idea = filteredIdeas[index];
                            return _buildIdeaCard(context, idea, currentUserId, ideaProvider);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewIdeaScreen()),
          );
        },
        child: const Icon(Icons.lightbulb),
      ),
    );
  }

  Widget _buildFiltersHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category horizontal scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedCategory == 'All',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = 'All';
                      });
                    }
                  },
                ),
                ...AppConstants.ideaCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Sort Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ideas Feed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedSort,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.sort),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  items: <String>['Newest', 'Most Upvoted'].map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedSort = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdeaCard(
    BuildContext context,
    IdeaModel idea,
    String currentUserId,
    IdeaProvider provider,
  ) {
    final hasUpvoted = idea.upvotes.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: idea.isAnonymous ? Colors.grey[300] : AppColors.primaryBlue.withOpacity(0.1),
                  child: Icon(
                    idea.isAnonymous ? Icons.person_outline : Icons.person,
                    color: idea.isAnonymous ? Colors.grey[600] : AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        idea.isAnonymous ? 'Anonymous Student' : idea.postedByName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getRelativeTime(idea.timestamp),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Category Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    idea.category,
                    style: const TextStyle(
                      color: AppColors.secondaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (idea.postedByUid == currentUserId) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, idea, provider);
                    },
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Idea Title & Description
            Text(
              idea.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              idea.description,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),

            // Image attachment if any
            if (idea.imageBase64 != null && idea.imageBase64!.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageViewer(imageUrl: idea.imageBase64!),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ComplaintImageWidget(
                      imageUrl: idea.imageBase64!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            // Card Action Buttons
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                // Upvote Button
                InkWell(
                  onTap: () async {
                    if (currentUserId.isNotEmpty) {
                      await provider.toggleUpvote(idea.id, currentUserId);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: hasUpvoted ? AppColors.primaryOrange.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: hasUpvoted ? AppColors.primaryOrange : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                          size: 16,
                          color: hasUpvoted ? AppColors.primaryOrange : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${idea.upvotes.length} Upvotes',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: hasUpvoted ? AppColors.primaryOrange : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No ideas found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to post a new suggestion for our campus!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    IdeaModel idea,
    IdeaProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Idea'),
        content: const Text('Are you sure you want to delete this idea? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              try {
                await provider.deleteIdea(idea.id);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Idea deleted successfully'), backgroundColor: Colors.green),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete idea: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
