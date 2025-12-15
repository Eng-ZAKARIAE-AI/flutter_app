import 'package:flutter/material.dart';

/// App Drawer Widget
/// 
/// A reusable drawer that shows all available pages in the app.
/// This drawer can be used across different screens.
class AppDrawer extends StatelessWidget {
  final int? currentScreenIndex;
  final Function(int)? onScreenSelected;
  final Function(String)? onRouteSelected;

  const AppDrawer({
    Key? key,
    this.currentScreenIndex,
    this.onScreenSelected,
    this.onRouteSelected,
  }) : super(key: key);

  void _navigateToRoute(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer
    if (onRouteSelected != null) {
      onRouteSelected!(route);
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  void _navigateToScreen(BuildContext context, int index) {
    Navigator.pop(context); // Close drawer
    if (onScreenSelected != null) {
      onScreenSelected!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  'Calorie Lens',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Track your calories',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            selected: currentScreenIndex == 0,
            onTap: () {
              Navigator.pop(context); // Close drawer
              // If not on home screen, navigate to main (which shows HomeScreen by default)
              if (currentScreenIndex != 0 && onScreenSelected != null) {
                onScreenSelected!(0);
              } else if (currentScreenIndex != 0) {
                Navigator.pushReplacementNamed(context, '/main');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Progress'),
            selected: currentScreenIndex == 1,
            onTap: () {
              Navigator.pop(context); // Close drawer
              // Use callback if available, otherwise navigate to main
              if (currentScreenIndex != 1 && onScreenSelected != null) {
                onScreenSelected!(1);
              } else if (currentScreenIndex != 1) {
                Navigator.pushReplacementNamed(context, '/main');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            selected: currentScreenIndex == 2,
            onTap: () {
              Navigator.pop(context); // Close drawer
              // Use callback if available, otherwise navigate to settings route
              if (currentScreenIndex != 2 && onScreenSelected != null) {
                onScreenSelected!(2);
              } else if (currentScreenIndex != 2) {
                Navigator.pushReplacementNamed(context, '/settings');
              }
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Onboarding'),
            onTap: () => _navigateToRoute(context, '/onboarding'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('About Calorie Lens'),
                  content: Text(
                    'A smart calorie tracking app to help you monitor your food intake and manage your health goals.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

