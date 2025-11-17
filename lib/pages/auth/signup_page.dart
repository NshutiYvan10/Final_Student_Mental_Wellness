import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../models/user_profile.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  UserRole? _selectedRole;
  
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated bubble background
          Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundPainter(
                animation: _floatAnimation,
                isDark: isDark,
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: theme.colorScheme.onSurface,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Welcome text
                    Text(
                      'Create\nAccount',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Join us to start your wellness journey',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Glassmorphism form card
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.white.withValues(alpha: 0.05),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.9),
                                  Colors.white.withValues(alpha: 0.7),
                                ],
                        ),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Role selector
                                  Text(
                                    'I am a',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.black.withValues(alpha: 0.03),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.1)
                                            : Colors.black.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: DropdownButtonFormField<UserRole>(
                                      value: _selectedRole,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.person_outline_rounded,
                                          color: theme.colorScheme.primary.withValues(alpha: 0.7),
                                        ),
                                      ),
                                      dropdownColor: theme.colorScheme.surface,
                                      hint: Text(
                                        'Select your role',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          value: UserRole.student,
                                          child: Text(
                                            'Student',
                                            style: TextStyle(color: theme.colorScheme.onSurface),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: UserRole.mentor,
                                          child: Text(
                                            'Mentor',
                                            style: TextStyle(color: theme.colorScheme.onSurface),
                                          ),
                                        ),
                                      ],
                                      onChanged: _loading
                                          ? null
                                          : (role) {
                                              setState(() => _selectedRole = role);
                                            },
                                      validator: (role) => role == null ? 'Please select a role' : null,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Display Name field
                                  _buildModernTextField(
                                    controller: _displayNameCtrl,
                                    label: 'Display Name',
                                    hint: 'Enter your name',
                                    icon: Icons.badge_outlined,
                                    validator: (v) => v != null && v.isNotEmpty 
                                        ? null 
                                        : 'Display name is required',
                                    theme: theme,
                                    isDark: isDark,
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Email field
                                  _buildModernTextField(
                                    controller: _emailCtrl,
                                    label: 'Email',
                                    hint: 'Enter your email',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) => v != null && v.contains('@') 
                                        ? null 
                                        : 'Please enter a valid email',
                                    theme: theme,
                                    isDark: isDark,
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Password field
                                  _buildModernTextField(
                                    controller: _passwordCtrl,
                                    label: 'Password',
                                    hint: 'Create a password',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    validator: (v) => (v != null && v.length >= 6) 
                                        ? null 
                                        : 'Password must be at least 6 characters',
                                    theme: theme,
                                    isDark: isDark,
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      icon: Icon(
                                        _obscurePassword 
                                            ? Icons.visibility_off_outlined 
                                            : Icons.visibility_outlined,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // School field
                                  _buildModernTextField(
                                    controller: _schoolCtrl,
                                    label: 'School/Institution',
                                    hint: 'Enter your school name',
                                    icon: Icons.school_outlined,
                                    validator: (v) => v != null && v.isNotEmpty 
                                        ? null 
                                        : 'School/Institution is required',
                                    theme: theme,
                                    isDark: isDark,
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Sign Up button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _signup,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                                      ),
                                      child: _loading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              'Create Account',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Login link
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/login',
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            children: [
                              const TextSpan(text: "Already have an account? "),
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              icon,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;

  _BackgroundPainter({required this.animation, required this.isDark})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Animated gradient orbs
    final colors = [
      isDark ? const Color(0xFF6366F1).withValues(alpha: 0.08) : const Color(0xFF6366F1).withValues(alpha: 0.05),
      isDark ? const Color(0xFFEC4899).withValues(alpha: 0.08) : const Color(0xFFEC4899).withValues(alpha: 0.05),
      isDark ? const Color(0xFF8B5CF6).withValues(alpha: 0.08) : const Color(0xFF8B5CF6).withValues(alpha: 0.05),
    ];

    // Orb 1
    final center1 = Offset(
      size.width * 0.2 + animation.value * 2,
      size.height * 0.3 + math.sin(animation.value * 0.5) * 20,
    );
    paint.color = colors[0];
    canvas.drawCircle(center1, 150, paint);

    // Orb 2
    final center2 = Offset(
      size.width * 0.8 - animation.value * 1.5,
      size.height * 0.6 + math.cos(animation.value * 0.3) * 30,
    );
    paint.color = colors[1];
    canvas.drawCircle(center2, 200, paint);

    // Orb 3
    final center3 = Offset(
      size.width * 0.5 + math.sin(animation.value * 0.2) * 40,
      size.height * 0.8 - animation.value,
    );
    paint.color = colors[2];
    canvas.drawCircle(center3, 120, paint);
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) => true;
}


