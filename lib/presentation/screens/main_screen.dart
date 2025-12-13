import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'graph_screen.dart';
import 'settings_screen.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/user_repository.dart';

class MainScreen extends StatefulWidget {
  final AuthService authService;
  final UserRepository userRepository;

  const MainScreen({
    Key? key,
    required this.authService,
    required this.userRepository,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      GraphScreen(),
      SettingsScreen(
        authService: widget.authService,
        userRepository: widget.userRepository,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}