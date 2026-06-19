import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_buttons.dart';
import '../student/student_dashboard.dart';
import '../admin/admin_dashboard.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'student'; // 'student' or 'admin'

  void _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in email and password'), backgroundColor: Colors.red),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        selectedRole: _selectedRole,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful'), backgroundColor: Colors.green),
        );
        if (_selectedRole == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentDashboard()));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('Welcome Back', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32)),
              const SizedBox(height: 8),
              Text('Sign in to continue to AU Fix', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              
              // Role Selector ChoiceChips
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Student Login', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      selected: _selectedRole == 'student',
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedRole = 'student');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ChoiceChip(
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Admin Login', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      selected: _selectedRole == 'admin',
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedRole = 'admin');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Login',
                onPressed: _login,
                isLoading: authProvider.isLoading,
              ),
              const SizedBox(height: 16),
              
              // Only show registration option if Student Login is selected
              if (_selectedRole == 'student')
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrationScreen()));
                    },
                    child: const Text("Don't have an account? Register"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

