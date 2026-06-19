import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/idea_provider.dart';
import '../../models/idea_model.dart';
import '../../widgets/app_buttons.dart';
import '../../utils/constants.dart';
import '../../utils/image_utils.dart';

class NewIdeaScreen extends StatefulWidget {
  const NewIdeaScreen({Key? key}) : super(key: key);

  @override
  State<NewIdeaScreen> createState() => _NewIdeaScreenState();
}

class _NewIdeaScreenState extends State<NewIdeaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late String _selectedCategory;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = AppConstants.ideaCategories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  void _submitIdea() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ideaProvider = Provider.of<IdeaProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User session not found.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String ideaId = 'i_${DateTime.now().millisecondsSinceEpoch}';
      final newIdea = IdeaModel(
        id: ideaId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        postedByUid: authProvider.user!.uid,
        postedByName: authProvider.user!.name,
        isAnonymous: _isAnonymous,
        upvotes: [],
        timestamp: DateTime.now(),
        status: 'Open',
      );

      await ideaProvider.addIdea(newIdea, imageFile: _imageFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Idea Posted Successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ideaProvider.errorMessage ?? 'Failed to post idea: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Campus Idea'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Got an idea to make campus life better?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Submit improvement suggestions, facility requests, or community initiatives here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Idea Title',
                  hintText: 'e.g., Solar charging stations in gardens',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.ideaCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Describe your idea',
                  hintText: 'Explain the benefits and details of this idea...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Post Anonymously'),
                subtitle: const Text('Hide your name and roll number from the feed'),
                value: _isAnonymous,
                activeColor: Theme.of(context).primaryColor,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Add Visual Reference (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_imageFile != null)
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.red.withOpacity(0.8),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _imageFile = null;
                            });
                          },
                        ),
                      ),
                    )
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: _showImageSourceActionSheet,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Upload Image'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Publish Idea',
                onPressed: _submitIdea,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
