import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint_model.dart';
import '../../utils/constants.dart';

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
                  const Text(
                    'Visual Insight into Campus Hotspots',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Buildings are sorted by complaint density. Red indicates high density of issues.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Filter Dropdown
                  Row(
                    children: [
                      const Text('Filter Category: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategoryFilter,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                          items: ['All', ...AppConstants.complaintCategories].map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategoryFilter = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: sortedBuildings.isEmpty
                        ? const Center(child: Text('No complaints matching criteria.'))
                        : ListView.builder(
                            itemCount: sortedBuildings.length,
                            itemBuilder: (context, index) {
                              final building = sortedBuildings[index];
                              final list = buildingData[building] ?? [];
                              final count = list.length;

                              // Calculate heat color
                              final ratio = maxComplaints > 0 ? count / maxComplaints : 0.0;
                              Color heatColor = Colors.green;
                              if (ratio > 0.7) {
                                heatColor = Colors.red;
                              } else if (ratio > 0.3) {
                                heatColor = Colors.orange;
                              } else if (ratio > 0.0) {
                                heatColor = Colors.yellow.shade700;
                              }

                              // Calculate category breakdown inside this building
                              final Map<String, int> catCounts = {};
                              for (final comp in list) {
                                catCounts[comp.category] = (catCounts[comp.category] ?? 0) + 1;
                              }
                              final breakdownText = catCounts.entries
                                  .map((entry) => '${entry.key}: ${entry.value}')
                                  .join(', ');

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      // Heat indicator
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: heatColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$count',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
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
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              breakdownText.isNotEmpty ? breakdownText : 'No categories',
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Progress density bar
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        width: 60,
                                        child: LinearProgressIndicator(
                                          value: ratio,
                                          color: heatColor,
                                          backgroundColor: Colors.grey.shade200,
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
