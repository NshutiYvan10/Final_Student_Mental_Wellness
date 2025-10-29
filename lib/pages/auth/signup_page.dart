import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../models/user_profile.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  bool _loading = false;
  UserRole? _selectedRole;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get selected role from arguments
    if (_selectedRole == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _selectedRole = args?['selectedRole'] as UserRole?;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _displayNameCtrl.dispose();
    _schoolCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    
    try {
      if (!FirebaseService.isInitialized) {
        throw StateError('Firebase is not configured. Run FlutterFire and enable Email/Password auth.');
      }
      await AuthService.signUpWithEmail(
        _emailCtrl.text.trim(), 
        _passwordCtrl.text.trim(),
        displayName: _displayNameCtrl.text.trim(),
        school: _schoolCtrl.text.trim(),
        role: _selectedRole!,
      );
      
      if (!mounted) return;
      setState(() => _loading = false);
      
      // Navigate to dashboard after successful signup
      Navigator.pushReplacementNamed(context, '/dashboard');
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: ${_friendlyError(e)}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('weak-password')) {
      return 'Password is too weak.';
    }
    if (msg.contains('email-already-in-use')) {
      return 'That email is already in use.';
    }
    if (msg.contains('invalid-email')) {
      return 'Email address is invalid.';
    }
    if (msg.contains('Firebase is not configured')) {
      return 'App not connected to Firebase. See README to configure Firebase.';
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Role selector (required)
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: UserRole.student, child: Text('Student')),
                  DropdownMenuItem(value: UserRole.mentor, child: Text('Mentor')),
                ],
                onChanged: _loading
                    ? null
                    : (role) {
                        setState(() => _selectedRole = role);
                      },
                validator: (role) => role == null ? 'Please select a role' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayNameCtrl,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Display name required',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v != null && v.contains('@') ? null : 'Invalid email',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => (v != null && v.length >= 6) ? null : 'Min 6 chars',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _schoolCtrl,
                decoration: const InputDecoration(labelText: 'School/Institution'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'School required',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  child: _loading ? const CircularProgressIndicator() : const Text('Create account'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context, 
                  '/login',
                  arguments: {'selectedRole': _selectedRole},
                ),
                child: const Text('I have an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


