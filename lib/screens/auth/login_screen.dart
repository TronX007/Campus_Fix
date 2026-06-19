import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_buttons.dart';
import '../../theme/colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // App Logo styling
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : AppColors.pastelYellow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2.0),
                ),
                child: Text(
                  'AU FIX',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'WELCOME BACK', 
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.w900, 
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to continue to your campus dashboard', 
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              
              // Role Selector ChoiceChips
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.0),
                          child: Text('STUDENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                        ),
                      ),
                      selected: _selectedRole == 'student',
                      selectedColor: isDark ? AppColors.secondaryBlue : AppColors.pastelOrange,
                      backgroundColor: isDark ? Colors.white10 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: borderColor, width: 2.0),
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedRole = 'student');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.0),
                          child: Text('ADMIN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                        ),
                      ),
                      selected: _selectedRole == 'admin',
                      selectedColor: isDark ? AppColors.secondaryBlue : AppColors.pastelMint,
                      backgroundColor: isDark ? Colors.white10 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: borderColor, width: 2.0),
                      ),

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
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email, color: Colors.black),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.black),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                text: 'Login',
                onPressed: _login,
                isLoading: authProvider.isLoading,
              ),
              const SizedBox(height: 24),
              
              // Only show registration option if Student Login is selected
              if (_selectedRole == 'student')
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrationScreen()));
                    },
                    child: Text(
                      "DON'T HAVE AN ACCOUNT? REGISTER",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: isDark ? AppColors.secondaryBlue : AppColors.primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

  }
}

