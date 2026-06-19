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

    return Scaffold(
      appBar: AppBar(title: const Text('New Complaint')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedCategory),
              value: _selectedIssueType,
              decoration: const InputDecoration(labelText: 'Issue Type', border: OutlineInputBorder()),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
              items: AppConstants.departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) { if (val != null) setState(() => _selectedDepartment = val); },
            ),
            const SizedBox(height: 16),
            
            // Building selection
            DropdownButtonFormField<String>(
              value: _selectedBuilding,
              decoration: const InputDecoration(labelText: 'Building / Block', border: OutlineInputBorder()),
              items: _buildings.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (val) { if (val != null) setState(() => _selectedBuilding = val); },
            ),
            const SizedBox(height: 16),

            // Floor selection
            DropdownButtonFormField<int>(
              value: _selectedFloor,
              decoration: const InputDecoration(labelText: 'Floor Number', border: OutlineInputBorder()),
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
            const SizedBox(height: 16),

            // Room selection
            DropdownButtonFormField<String>(
              value: _selectedRoom,
              decoration: const InputDecoration(labelText: 'Room / Area', border: OutlineInputBorder()),
              items: _getRoomsForFloor(_selectedFloor).map((r) => DropdownMenuItem(value: r, child: Text('Room $r'))).toList(),
              onChanged: (val) { if (val != null) setState(() => _selectedRoom = val); },
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _specificLocationController,
              decoration: const InputDecoration(labelText: 'Specific Location Details (e.g., Near water cooler)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description of the Issue', border: OutlineInputBorder()),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            
            // Image Upload Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Attach Photo:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _showImageSourceActionSheet,
                  icon: const Icon(Icons.add_a_photo),
                  label: Text(_imageFile == null ? 'Add Image' : 'Replace Image'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_imageFile != null) ...[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                    onPressed: () => setState(() => _imageFile = null),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
