import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint_model.dart';
import '../../utils/constants.dart';
import '../../theme/colors.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({Key? key}) : super(key: key);

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  String _selectedCategoryFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).loadAllComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComplaintProvider>(context);
    final complaints = provider.complaints;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter complaints by category if not 'All'
    final filteredComplaints = _selectedCategoryFilter == 'All'
        ? complaints
        : complaints.where((c) => c.category == _selectedCategoryFilter).toList();

    // Aggregate complaints by Building
    final Map<String, List<ComplaintModel>> buildingData = {};
    for (final c in filteredComplaints) {
      if (c.building.isNotEmpty) {
        buildingData[c.building] = (buildingData[c.building] ?? [])..add(c);
      }
    }

    // Sort buildings by complaint count descending (highest count = hotspot)
    final sortedBuildings = buildingData.keys.toList()
      ..sort((a, b) => (buildingData[b]?.length ?? 0).compareTo(buildingData[a]?.length ?? 0));

    // Calculate maximum complaints in any building for color density scale
    int maxComplaints = 0;
    for (final count in buildingData.values.map((list) => list.length)) {
      if (count > maxComplaints) {
        maxComplaints = count;
      }
    }

    final borderColor = isDark ? Colors.white : Colors.black;
    final shadowColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Complaint Heatmap'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visual Insight into Campus Hotspots',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buildings are sorted by complaint density. Red indicates high density of issues.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Filter Dropdown
                  Text(
                    'Filter Category',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryFilter,
                    isExpanded: true,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.lexend().fontFamily,
                    ),
                    dropdownColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
                    ),
                    items: ['All', ...AppConstants.complaintCategories].map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategoryFilter = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: sortedBuildings.isEmpty
                        ? const Center(
                            child: Text(
                              'No complaints matching criteria.',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: sortedBuildings.length,
                            itemBuilder: (context, index) {
                              final building = sortedBuildings[index];
                              final list = buildingData[building] ?? [];
                              final count = list.length;

                              // Calculate heat color and ratio
                              final ratio = maxComplaints > 0 ? count / maxComplaints : 0.0;
                              Color heatColor = AppColors.statusResolved; // Green for low
                              if (ratio > 0.7) {
                                heatColor = AppColors.priorityCritical; // Red
                              } else if (ratio > 0.3) {
                                heatColor = AppColors.statusPending; // Orange
                              } else if (ratio > 0.1) {
                                heatColor = Colors.yellow.shade700; // Yellow
                              }

                              // Calculate category breakdown inside this building
                              final Map<String, int> catCounts = {};
                              for (final comp in list) {
                                catCounts[comp.category] = (catCounts[comp.category] ?? 0) + 1;
                              }
                              final breakdownText = catCounts.entries
                                  .map((entry) => '${entry.key}: ${entry.value}')
                                  .join(', ');

                              // Text color for heat indicator circle to ensure contrast
                              final Color heatTextColor = (heatColor == AppColors.priorityCritical)
                                  ? Colors.white
                                  : Colors.black;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
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
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Circular heat indicator
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: heatColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: borderColor, width: 2.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$count',
                                            style: TextStyle(
                                              color: heatTextColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Building Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              building,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900, 
                                                fontSize: 18,
                                                color: isDark ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              breakdownText.isNotEmpty ? breakdownText : 'No categories',
                                              style: TextStyle(
                                                fontSize: 12, 
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white70 : Colors.black54,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Progress density bar
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        width: 70,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            LinearProgressIndicator(
                                              value: ratio,
                                              color: heatColor,
                                              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                              minHeight: 8,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${(ratio * 100).toInt()}% density',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white70 : Colors.black54,
                                              ),
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
                  ),
                ],
              ),
            ),
    );
  }
}
