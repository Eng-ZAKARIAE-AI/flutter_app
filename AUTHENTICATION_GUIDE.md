# 🔐 Authentication Implementation Guide

## Overview

This guide explains how authentication works in your app and how to implement it step-by-step.

---

## 🎯 Current Implementation: Simple Local Auth

### What We Have

A **simple local authentication service** (`AuthService`) that:
- Stores user info in SharedPreferences (not secure, but good for learning)
- Creates user IDs from email addresses
- Manages login state

### How It Works

```dart
// Login
final authService = AuthService(prefs);
final userId = await authService.login('user@example.com', 'password123');

// Check if logged in
if (authService.isLoggedIn()) {
  final userId = authService.getCurrentUserId();
  // Use userId for database operations
}

// Logout
await authService.logout();
```

### Limitations

⚠️ **This is NOT secure!** It's for learning purposes only.
- Passwords are NOT encrypted
- No password verification
- No password reset
- No email verification
- Data stored locally only

---

## 🚀 Step 1: Create Login Screen

Create a new file: `lib/presentation/screens/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/user_repository.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final UserRepository userRepository;
  
  const LoginScreen({
    Key? key,
    required this.authService,
    required this.userRepository,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await widget.authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (userId != null) {
        // Create user in database if doesn't exist
        await widget.userRepository.createUser(
          userId,
          _emailController.text.trim(),
        );

        // Navigate to main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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
              SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Login'),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigate to register screen
                },
                child: Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

---

## 🚀 Step 2: Create Register Screen

Create a new file: `lib/presentation/screens/register_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/user_repository.dart';
import 'main_screen.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await widget.authService.register(
        _emailController.text.trim(),
        _passwordController.text,
        name: _nameController.text.trim().isEmpty 
            ? null 
            : _nameController.text.trim(),
      );

      if (userId != null) {
        // Create user in database
        await widget.userRepository.createUser(
          userId,
          _emailController.text.trim(),
          name: _nameController.text.trim().isEmpty 
              ? null 
              : _nameController.text.trim(),
        );

        // Navigate to onboarding or main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Registration failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Register'),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
```

---

## 🔥 Step 3: Upgrade to Firebase Authentication

### Why Firebase Auth?

- ✅ Secure password storage
- ✅ Email verification
- ✅ Password reset
- ✅ Multi-provider support (Google, Facebook, etc.)
- ✅ Free tier available

### Installation

1. **Add Firebase to your project** (follow Firebase Flutter setup guide)
2. **Add dependency to `pubspec.yaml`**:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
```

3. **Run**:
```bash
flutter pub get
```

### Create Firebase Auth Service

Create: `lib/data/services/firebase_auth_service.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  /// Register with email and password
  Future<String?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      print('Registration error: ${e.code} - ${e.message}');
      return null;
    }
  }

  /// Login with email and password
  Future<String?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.code} - ${e.message}');
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Password reset error: $e');
      return false;
    }
  }

  /// Listen to auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
```

### Update AuthService to Use Firebase

You can create an interface and switch implementations:

```dart
abstract class AuthServiceInterface {
  String? getCurrentUserId();
  bool isLoggedIn();
  Future<String?> login(String email, String password);
  Future<String?> register(String email, String password);
  Future<void> logout();
}

// Simple implementation (for development)
class SimpleAuthService implements AuthServiceInterface {
  // ... existing code
}

// Firebase implementation (for production)
class FirebaseAuthServiceAdapter implements AuthServiceInterface {
  final FirebaseAuthService _firebaseAuth;
  
  FirebaseAuthServiceAdapter(this._firebaseAuth);
  
  @override
  String? getCurrentUserId() => _firebaseAuth.getCurrentUserId();
  
  @override
  bool isLoggedIn() => _firebaseAuth.isLoggedIn();
  
  // ... implement other methods
}
```

---

## 🔄 Step 4: Update Main App to Check Auth

Update `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (if using Firebase)
  // await Firebase.initializeApp();
  
  await _loadEnvironmentFile();
  
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService(prefs);
  
  // Check if user is logged in
  final isLoggedIn = authService.isLoggedIn();
  final showOnboarding = !(prefs.getBool('onboarding_complete') ?? false);
  
  // Initialize repositories...
  
  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    showOnboarding: showOnboarding,
    // ... other dependencies
  ));
}
```

Update `MyApp`:

```dart
class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool showOnboarding;
  // ... other dependencies

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLoggedIn
          ? (showOnboarding ? OnboardingScreen() : MainScreen())
          : LoginScreen(), // Show login if not authenticated
      // ... routes
    );
  }
}
```

---

## 📝 Summary

### What We've Implemented

1. ✅ **SQLite Database** - Proper data storage
2. ✅ **Simple Auth Service** - Basic authentication (for learning)
3. ✅ **User-Data Relationships** - Food items linked to users
4. ✅ **Firebase Auth Guide** - Ready for production upgrade

### Next Steps

1. Create login/register screens (code provided above)
2. Update main.dart to check auth state
3. Add logout functionality to settings
4. (Optional) Upgrade to Firebase Auth for production

### Key Concepts

- **Authentication**: Verifying who the user is
- **Authorization**: What the user can do
- **Session Management**: Keeping user logged in
- **User ID**: Unique identifier for each user
- **Data Isolation**: Each user only sees their own data

---

## 🎓 Learning Points

1. **Why Auth?**
   - Multi-user support
   - Data security
   - Cloud sync capability
   - Personalization

2. **Simple vs Firebase**
   - Simple: Good for learning, prototyping
   - Firebase: Required for production apps

3. **Database + Auth**
   - User ID links all data to users
   - Foreign keys ensure data integrity
   - Queries filter by user ID

---

## 🚨 Security Notes

⚠️ **Current Simple Auth is NOT secure!**

For production, you MUST:
- Use Firebase Auth or your own secure backend
- Never store passwords in plain text
- Use HTTPS for all network requests
- Implement proper session management
- Add rate limiting
- Validate all inputs

