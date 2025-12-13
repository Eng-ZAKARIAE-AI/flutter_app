import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

/// Login Screen
/// 
/// Allows users to log in with email and password.
/// On successful login, navigates to the home screen.
/// Shows error messages using SnackBar on failure.
class LoginScreen extends StatefulWidget {
  final AuthService authService;
  
  const LoginScreen({
    Key? key,
    required this.authService,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Loading state
  bool _isLoading = false;

  /// Handle login button press
  /// 
  /// Steps:
  /// 1. Validate form inputs
  /// 2. Call AuthService.login()
  /// 3. Navigate to home on success
  /// 4. Show error on failure
  Future<void> _handleLogin() async {
    // Validate form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set loading state to show progress indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to login using AuthService
      // This is a simple auth - in production, use Firebase Auth
      final userId = await widget.authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Check if login was successful
      if (userId != null && mounted) {
        // Login successful - navigate to home screen
        // Using pushReplacementNamed to prevent going back to login
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Login failed - show error message
        if (mounted) {
          _showError('Invalid email or password. Please try again.');
        }
      }
    } catch (e) {
      // Handle any unexpected errors
      if (mounted) {
        _showError('Login failed: ${e.toString()}');
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
  /// 
  /// SnackBar is a Material Design component for showing brief messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Navigate to register screen
  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
                    Icons.restaurant_menu,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to continue tracking your calories',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48),
                  
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
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(), // Submit on enter
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
                    // Validation: Check if password is not empty
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),
                  
                  // Login button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  SizedBox(height: 16),
                  
                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: _navigateToRegister,
                        child: Text('Register'),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

