import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/user_repository.dart';

/// Register Screen
/// 
/// Allows new users to create an account.
/// Validates inputs and ensures passwords match.
/// Creates user in SQLite database and auto-logs in after registration.
class RegisterScreen extends StatefulWidget {
  final AuthService authService;
  final UserRepository userRepository;
  
  const RegisterScreen({
    Key? key,
    required this.authService,
    required this.userRepository,
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Loading state
  bool _isLoading = false;

  /// Handle register button press
  /// 
  /// Steps:
  /// 1. Validate form inputs
  /// 2. Check if passwords match
  /// 3. Register user with AuthService
  /// 4. Create user in SQLite database via UserRepository
  /// 5. Auto-login the user
  /// 6. Navigate to home on success
  /// 7. Show error on failure
  Future<void> _handleRegister() async {
    // Validate form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if passwords match (additional validation)
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match. Please try again.');
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Register with AuthService
      // This creates the authentication session
      final userId = await widget.authService.register(
        _emailController.text.trim(),
        _passwordController.text,
        name: _nameController.text.trim().isEmpty 
            ? null 
            : _nameController.text.trim(),
      );

      if (userId == null) {
        // Registration failed
        if (mounted) {
          _showError('Registration failed. Please try again.');
        }
        return;
      }

      // Step 2: Create user in SQLite database
      // This stores the user account information
      try {
        await widget.userRepository.createUser(
          userId,
          _emailController.text.trim(),
          name: _nameController.text.trim().isEmpty 
              ? null 
              : _nameController.text.trim(),
        );
      } catch (dbError) {
        // If database operation fails, still allow login
        // but log the error for debugging
        print('Warning: Failed to save user to database: $dbError');
        // Continue with navigation - user is already logged in via AuthService
      }

      // Step 3: Registration successful - check onboarding status
      // User is already logged in by AuthService.register()
      if (mounted) {
        // Check if onboarding is complete (should be false for new users)
        final prefs = await SharedPreferences.getInstance();
        final isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;
        
        // Navigate to onboarding if first time, otherwise to main screen
        Navigator.pushReplacementNamed(
          context, 
          isOnboardingComplete ? '/main' : '/onboarding'
        );
      }
    } catch (e) {
      // Handle any unexpected errors
      if (mounted) {
        _showError('Registration failed: ${e.toString()}');
      }
    } finally {
      // Always reset loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show error message using SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Navigate back to login screen
  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo/Title
                  Icon(
                    Icons.person_add,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign up to start tracking your calories',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48),
                  
                  // Name field (optional)
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Name (Optional)',
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    // No validation - name is optional
                  ),
                  SizedBox(height: 16),
                  
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    // Validation: Check if email is not empty and has valid format
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // Basic email format validation
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true, // Hide password characters
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    // Validation: Check password strength
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true, // Hide password characters
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleRegister(), // Submit on enter
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    // Validation: Check if passwords match
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),
                  
                  // Register button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  SizedBox(height: 16),
                  
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: _navigateToLogin,
                        child: Text('Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

