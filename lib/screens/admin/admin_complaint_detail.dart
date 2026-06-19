import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/complaint_model.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../utils/enums.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/full_screen_image_viewer.dart';
import '../../widgets/complaint_image_widget.dart';
import '../../utils/image_utils.dart';

class AdminComplaintDetail extends StatefulWidget {
  final ComplaintModel complaint;

  const AdminComplaintDetail({Key? key, required this.complaint}) : super(key: key);

  @override
  State<AdminComplaintDetail> createState() => _AdminComplaintDetailState();
}

class _AdminComplaintDetailState extends State<AdminComplaintDetail> {
  late ComplaintStatus _selectedStatus;
  late ComplaintPriority _selectedPriority;
  final _remarksController = TextEditingController();

  File? _resolutionImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.complaint.status;
    _selectedPriority = widget.complaint.priority;
    _remarksController.text = widget.complaint.adminRemarks ?? '';
  }

  Future<void> _pickResolutionImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 35,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      try {
        await ImageUtils.compressAndEncode(file);
        setState(() {
          _resolutionImageFile = file;
        });
      } on ImageSizeExceededException catch (sizeErr) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(sizeErr.message), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        setState(() {
          _resolutionImageFile = file;
        });
      }
    }
  }

  void _updateComplaint() async {
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    
    try {
      await provider.updateComplaintStatus(
        widget.complaint.id,
        _selectedStatus,
        remarks: _remarksController.text,
        priority: _selectedPriority,
        resolutionImageFile: _resolutionImageFile,
      );
      
      if (mounted) {
        Provider.of<AnalyticsProvider>(context, listen: false).fetchAnalytics();
        
        // Show Image Upload success if a resolution image was uploaded
        if (_resolutionImageFile != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image Uploaded Successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        String successMessage = 'Complaint Updated Successfully';
        if (_selectedStatus == ComplaintStatus.resolved) {
          successMessage = 'Complaint Marked as Resolved';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to update complaint: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProviderLoading = Provider.of<ComplaintProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Complaint')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.complaint.title, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text('ID: ${widget.complaint.id}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            
            if (widget.complaint.imageBase64 != null && widget.complaint.imageBase64!.isNotEmpty) ...[
              const Text('Original Issue Photo:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImageViewer(
                        imageUrl: widget.complaint.imageBase64!,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: ComplaintImageWidget(
                      imageUrl: widget.complaint.imageBase64!,
                      fit: BoxFit.cover,
                      errorWidget: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 36),
                            SizedBox(height: 8),
                            Text('Failed to load image evidence', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Complaint Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    _buildInfoRow('Category', widget.complaint.category),
                    _buildInfoRow('Issue Type', widget.complaint.issueType),
                    const Divider(),
                    const Text('Location Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    _buildInfoRow('Building', widget.complaint.building),
                    _buildInfoRow('Floor', 'Floor ${widget.complaint.floor}'),
                    _buildInfoRow('Room / Area', 'Room ${widget.complaint.room}'),
                    _buildInfoRow('Specifics', widget.complaint.specificLocation),
                    const Divider(),
                    const Text('Description', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(widget.complaint.description),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<ComplaintStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: ComplaintStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))).toList(),
                      onChanged: (val) { if (val != null) setState(() => _selectedStatus = val); },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ComplaintPriority>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                      items: ComplaintPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.displayName))).toList(),
                      onChanged: (val) { if (val != null) setState(() => _selectedPriority = val); },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _remarksController,
                      decoration: const InputDecoration(labelText: 'Admin Remarks', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_selectedStatus == ComplaintStatus.resolved) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Resolution Proof Photo:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _pickResolutionImage,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            icon: const Icon(Icons.photo_camera, size: 16),
                            label: const Text('Add Proof'),
                          ),
                        ],
                      ),
                      if (_resolutionImageFile != null) ...[
                        const SizedBox(height: 12),
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(image: FileImage(_resolutionImageFile!), fit: BoxFit.cover),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => setState(() => _resolutionImageFile = null),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (widget.complaint.resolutionImageBase64 != null && widget.complaint.resolutionImageBase64!.isNotEmpty) ...[
              const Text('Resolution Proof Photo:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImageViewer(
                        imageUrl: widget.complaint.resolutionImageBase64!,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: ComplaintImageWidget(
                      imageUrl: widget.complaint.resolutionImageBase64!,
                      fit: BoxFit.cover,
                      errorWidget: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 36),
                            SizedBox(height: 8),
                            Text('Failed to load resolution proof photo', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            PrimaryButton(
              text: 'Save Changes',
              onPressed: _updateComplaint,
              isLoading: isProviderLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
