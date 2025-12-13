import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/user_repository.dart';

/// Settings Screen
/// 
/// Displays app settings and user options.
/// Includes logout functionality.
class SettingsScreen extends StatelessWidget {
  final AuthService authService;
  final UserRepository userRepository;
  
  const SettingsScreen({
    Key? key,
    required this.authService,
    required this.userRepository,
  }) : super(key: key);

  /// Navigate to onboarding screen to edit user information
  void _navigateToOnboarding(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  /// Handle logout
  /// 
  /// Steps:
  /// 1. Call AuthService.logout() to clear session
  /// 2. Navigate to login screen
  /// 3. Show success message
  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    // If user confirmed logout
    if (shouldLogout == true) {
      try {
        // Clear authentication session
        await authService.logout();
        
        // Navigate to login screen
        // Using pushReplacementNamed to prevent going back
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Handle logout errors
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // User Information Section
          Text(
            'User Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Edit User Information'),
            subtitle: Text('Update your profile and goals'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateToOnboarding(context),
          ),
          Divider(),
          
          // Account Section
          SizedBox(height: 16),
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: Text('Sign out of your account'),
            onTap: () => _handleLogout(context),
          ),
          Divider(),
          
          // App Information Section
          SizedBox(height: 16),
          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('App Version'),
            subtitle: Text('1.0.3'),
          ),
        ],
      ),
    );
  }
}