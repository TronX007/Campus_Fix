import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/idea_provider.dart';
import '../../models/idea_model.dart';
import '../../widgets/complaint_image_widget.dart';
import '../../widgets/full_screen_image_viewer.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_cards.dart';
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
      Provider.of<IdeaProvider>(context, listen: false).startListeningToIdeas();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredIdeas = _getFilteredAndSortedIdeas(ideaProvider.ideas);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Filter Chips and Sort Dropdown Header
          _buildFiltersHeader(context),
          Container(height: 2.5, color: isDark ? Colors.white : Colors.black),

          // Main Feed Section
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ideaProvider.startListeningToIdeas();
              },
              child: ideaProvider.isLoading && ideaProvider.ideas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredIdeas.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          itemCount: filteredIdeas.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: 16.0),
                                child: AnimatedIllustrationCard(
                                  imagePath: 'assets/images/innovation_illustration.png',
                                  title: 'Campus Innovation',
                                  subtitle: 'Propose ideas to make campus life better. Upvote popular suggestions to get them funded!',
                                  cardColor: AppColors.pastelOrange,
                                ),
                              );
                            }
                            final idea = filteredIdeas[index - 1];
                            return _buildIdeaCard(context, idea, currentUserId, ideaProvider);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.secondaryBlue : AppColors.primaryOrange,
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
        child: FloatingActionButton(
          elevation: 0,
          highlightElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewIdeaScreen()),
            );
          },
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildFiltersHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category horizontal scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('ALL'),
                  selected: _selectedCategory == 'All',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = 'All';
                      });
                    }
                  },
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.pastelMint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? Colors.white : Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
                ...AppConstants.ideaCategories.map((category) {
                  final Color catColor = AppColors.getCategoryColor(category);
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ChoiceChip(
                      label: Text(category.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                      backgroundColor: Colors.white,
                      selectedColor: catColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isDark ? Colors.white : Colors.black,
                          width: 2.0,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),

          ),
          const SizedBox(height: 12),
          // Sort Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'IDEAS FEED',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2.0),
                  ),
                  height: 38,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                      style: const TextStyle(
                        color: Colors.black, 
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                      items: <String>['Newest', 'Most Upvoted'].map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val.toUpperCase()),
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
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasUpvoted = idea.upvotes.contains(currentUserId);
    final Color catColor = AppColors.getCategoryColor(idea.category);
    final Color borderColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(24),
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
        borderRadius: BorderRadius.circular(21.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Category ribbon
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
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: Colors.black,
                    ),
                  ),
                  if (idea.postedByUid == currentUserId)
                    GestureDetector(
                      onTap: () {
                        _showDeleteConfirmationDialog(context, idea, provider);
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'DELETE',
                            style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
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
                  // User Details Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isDark ? Colors.white12 : AppColors.pastelRose,
                        child: Icon(
                          idea.isAnonymous ? Icons.lock_outline : Icons.person,
                          color: isDark ? Colors.white : Colors.black,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              idea.isAnonymous ? 'Anonymous Student' : idea.postedByName,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getRelativeTime(idea.timestamp),
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Idea Title & Description
                  Text(
                    idea.title,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    idea.description,
                    style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),

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
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 2.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: ComplaintImageWidget(
                            imageUrl: idea.imageBase64!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),
                  
                  // Upvote Capsule Button
                  GestureDetector(
                    onTap: () async {
                      if (currentUserId.isNotEmpty) {
                        await provider.toggleUpvote(idea.id, currentUserId);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: hasUpvoted
                            ? (isDark ? Colors.white10 : AppColors.primaryOrange)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 2.0),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: hasUpvoted ? const Offset(0, 0) : const Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 16,
                            color: hasUpvoted 
                                ? (isDark ? AppColors.primaryOrange : Colors.white)
                                : Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${idea.upvotes.length} UPVOTES',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: hasUpvoted
                                  ? (isDark ? Colors.white : Colors.white)
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'NO IDEAS FOUND',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to post a new suggestion for our campus!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 2.5),
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Idea', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to delete this idea? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}

