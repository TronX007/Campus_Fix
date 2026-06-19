import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_buttons.dart';
import '../../theme/colors.dart';
import '../student/student_dashboard.dart';

import '../admin/admin_dashboard.dart';
import '../../utils/enums.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rollNumberController = TextEditingController();
  String _selectedDepartment = 'Computer Science';

  final List<String> _departments = [
    'Computer Science', 'Electronics', 'Mechanical', 'Civil', 'Electrical'
  ];

  void _register() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _rollNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _rollNumberController.text.trim(),
        _selectedDepartment,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful'), backgroundColor: Colors.green),
        );
        if (authProvider.user?.role == UserRole.admin) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('CREATE ACCOUNT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join AU Fix 🚀',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w900, 
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign up to report and track campus issues',
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Email Address'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _rollNumberController,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Roll Number'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Department'),
              items: _departments.map((dep) => DropdownMenuItem(value: dep, child: Text(dep))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDepartment = val);
              },
            ),
            const SizedBox(height: 36),
            PrimaryButton(
              text: 'Register',
              onPressed: _register,
              isLoading: authProvider.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

