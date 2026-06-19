import '../models/user_model.dart';
import '../utils/enums.dart';

class MockAuthService {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    if (email.contains('admin')) {
      _currentUser = UserModel(
        uid: 'admin_123',
        name: 'Admin User',
        email: email,
        role: UserRole.admin,
        department: 'Administration',
      );
    } else {
      _currentUser = UserModel(
        uid: 'student_123',
        name: 'John Doe',
        email: email,
        role: UserRole.student,
        rollNumber: '19CS01',
        department: 'Computer Science',
      );
    }
    return _currentUser!;
  }

  Future<UserModel> register(String name, String email, String password, String rollNumber, String department) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: email.contains('admin') ? UserRole.admin : UserRole.student,
      rollNumber: rollNumber,
      department: email.contains('admin') ? 'Administration' : department,
    );
    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }
}
