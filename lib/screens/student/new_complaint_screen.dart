import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint_model.dart';
import '../../widgets/app_buttons.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';
import '../../utils/image_utils.dart';
import '../../theme/colors.dart';


class NewComplaintScreen extends StatefulWidget {
  const NewComplaintScreen({Key? key}) : super(key: key);

  @override
  State<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends State<NewComplaintScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _specificLocationController = TextEditingController();
  
  late String _selectedCategory;
  late String _selectedIssueType;
  String _selectedDepartment = AppConstants.departments.first;

  // Hierarchical Locations
  final List<String> _buildings = ['Block A', 'Block B', 'Block C', 'Block D', 'Block E', 'Block F', 'Block G', 'Block H', 'Block I'];
  final List<int> _floors = List.generate(10, (index) => index + 1);
  
  late String _selectedBuilding;
  late int _selectedFloor;
  late String _selectedRoom;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedBuilding = _buildings.first;
    _selectedFloor = _floors.first;
    _selectedRoom = '${_selectedFloor * 100 + 1}';
    _selectedCategory = AppConstants.complaintCategories.first;
    _selectedIssueType = AppConstants.categoryIssueTypes[_selectedCategory]!.first;
  }

  List<String> _getRoomsForFloor(int floor) {
    return List.generate(15, (index) => '${floor * 100 + (index + 1)}');
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 35,
        maxWidth: 600,
        maxHeight: 600,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        try {
          // Verify that it compresses and encodes successfully under the 300KB limit
          await ImageUtils.compressAndEncode(file);
          setState(() {
            _imageFile = file;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image Selected Successfully'), backgroundColor: Colors.green),
            );
          }
        } on ImageSizeExceededException catch (sizeErr) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(sizeErr.message), backgroundColor: Colors.red),
            );
          }
        } catch (e) {
          // Other error, fallback to selecting the file anyway
          setState(() {
            _imageFile = file;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to acquire image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: const Text('Cancel', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitComplaint() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user == null) return;
    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and description'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_imageFile == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Missing Image'),
          content: const Text('Would you like to continue without attaching an image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _checkSimilarAndSubmit();
              },
              child: const Text('Continue'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showImageSourceActionSheet();
              },
              child: const Text('Add Image'),
            ),
          ],
        ),
      );
    } else {
      _checkSimilarAndSubmit();
    }
  }

  void _checkSimilarAndSubmit() async {
    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final matches = await complaintProvider.checkForSimilarComplaints(
        category: _selectedCategory,
        issueType: _selectedIssueType,
        building: _selectedBuilding,
        floor: _selectedFloor.toString(),
        room: _selectedRoom,
      );
      
      if (mounted) Navigator.pop(context); // Dismiss loading spinner
      
      if (matches.isNotEmpty) {
        // Show similar complaint warning dialog
        final existing = matches.first;
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Similar complaint already exists.'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('We found an unresolved complaint at this location:'),
                  const SizedBox(height: 12),
                  Text('Title: ${existing.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Status: ${existing.status.displayName}', style: const TextStyle(color: Colors.blue)),
                  const SizedBox(height: 4),
                  Text('Affected Students: ${existing.affectedStudentCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Would you like to join this existing complaint to raise its priority, or submit a new ticket?'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Dismiss warning dialog
                    _executeSubmission(); // Submit new complaint
                  },
                  child: const Text('Create New Complaint'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Dismiss warning dialog
                    _joinExisting(existing.id);
                  },
                  child: const Text('Join Existing Complaint'),
                ),
              ],
            ),
          );
        }
      } else {
        _executeSubmission();
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Dismiss loading spinner
      _executeSubmission(); // Fallback to normal submission in case checking fails
    }
  }

  void _joinExisting(String complaintId) async {
    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      await complaintProvider.joinExistingComplaint(complaintId);
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined Similar Complaint Successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Go back to dashboard
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(complaintProvider.errorMessage ?? 'Failed to join complaint: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _executeSubmission() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);

    final newComplaint = ComplaintModel(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      issueType: _selectedIssueType,
      department: _selectedDepartment,
      building: _selectedBuilding,
      floor: _selectedFloor.toString(),
      room: _selectedRoom,
      specificLocation: _specificLocationController.text.trim(),
      priority: ComplaintPriority.medium,
      status: ComplaintStatus.submitted,
      // imageBase64 will be set by provider after compression
      studentId: authProvider.user!.uid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await complaintProvider.addComplaint(newComplaint, imageFile: _imageFile);
      if (mounted) {
        if (_imageFile != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image Uploaded Successfully'), backgroundColor: Colors.green),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint Submitted Successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(complaintProvider.errorMessage ?? 'Failed to submit complaint: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProviderLoading = Provider.of<ComplaintProvider>(context).isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('FILE A NEW COMPLAINT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report a Campus Issue 📢',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter issue details below. The system will automatically link similar reports to elevate priority.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 28),
            
            // Title
            TextField(
              controller: _titleController,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Issue Title (e.g. Broken Fan)'),
            ),
            const SizedBox(height: 20),
            
            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Category'),
              items: AppConstants.complaintCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCategory = val;
                    _selectedIssueType = AppConstants.categoryIssueTypes[val]!.first;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            
            // Issue Type
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedCategory),
              value: _selectedIssueType,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Issue Type'),
              items: AppConstants.categoryIssueTypes[_selectedCategory]!
                  .map((it) => DropdownMenuItem(value: it, child: Text(it)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedIssueType = val;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            
            // Department
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Responsible Department'),
              items: AppConstants.departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) { if (val != null) setState(() => _selectedDepartment = val); },
            ),
            const SizedBox(height: 20),
            
            // Building
            DropdownButtonFormField<String>(
              value: _selectedBuilding,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Building / Block'),
              items: _buildings.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (val) { if (val != null) setState(() => _selectedBuilding = val); },
            ),
            const SizedBox(height: 20),

            // Floor
            DropdownButtonFormField<int>(
              value: _selectedFloor,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Floor Number'),
              items: _floors.map((f) => DropdownMenuItem(value: f, child: Text('Floor $f'))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedFloor = val;
                    _selectedRoom = '${val * 100 + 1}';
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Room
            DropdownButtonFormField<String>(
              value: _selectedRoom,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Room / Area'),
              items: _getRoomsForFloor(_selectedFloor).map((r) => DropdownMenuItem(value: r, child: Text('Room $r'))).toList(),
              onChanged: (val) { if (val != null) setState(() => _selectedRoom = val); },
            ),
            const SizedBox(height: 20),

            // Specific details
            TextField(
              controller: _specificLocationController,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Specific Location Details (e.g., Near water cooler)'),
            ),
            const SizedBox(height: 20),
            
            // Description
            TextField(
              controller: _descriptionController,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Description of the Issue'),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            
            // Image Upload Section Header
            Text(
              'ATTACH EVIDENCE PHOTO',
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            
            if (_imageFile != null) ...[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 2.5),
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 2.0),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        onPressed: () => setState(() => _imageFile = null),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ] else ...[
              GestureDetector(
                onTap: _showImageSourceActionSheet,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2.5),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, color: isDark ? Colors.white : Colors.black, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'UPLOAD PHOTO EVIDENCE',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            PrimaryButton(
              text: 'Submit Complaint',
              onPressed: _submitComplaint,
              isLoading: isProviderLoading,
            ),
          ],
        ),
      ),
    );
  }
}

