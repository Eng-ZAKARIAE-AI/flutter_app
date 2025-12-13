import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/repositories/food_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/food_service.dart';
import 'data/services/auth_service.dart';
import 'data/local/daos/food_item_dao.dart';
import 'data/local/daos/user_data_dao.dart';
import 'data/local/daos/user_dao.dart';
import 'presentation/cubit/food_log_cubit.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';

Future<void> _loadEnvironmentFile() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Error loading .env file: $e');
    // Provide a fallback or handle error as needed
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadEnvironmentFile();
  
  // Initialize SharedPreferences (still needed for onboarding flag and auth)
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = !(prefs.getBool('onboarding_complete') ?? false);

  // Initialize Database DAOs (Data Access Objects)
  final foodItemDao = FoodItemDao();
  final userDataDao = UserDataDao();
  final userDao = UserDao();
  
  // Initialize Services
  final foodService = FoodService();
  final authService = AuthService(prefs);
  
  // Check if user is already logged in
  // This determines whether to show login screen or main app
  final isLoggedIn = authService.isLoggedIn();
  
  // NOTE: We're NOT creating a default user automatically anymore
  // Users must register/login to use the app
  // If you need backward compatibility, uncomment the line below:
  // if (!isLoggedIn) await authService.getOrCreateDefaultUser();
  
  // Initialize Repositories
  final foodRepository = FoodRepository(foodService, foodItemDao, authService);
  final userRepository = UserRepository(userDataDao, userDao, authService);
  
  runApp(MyApp(
    showOnboarding: showOnboarding,
    isLoggedIn: isLoggedIn,
    foodRepository: foodRepository,
    userRepository: userRepository,
    authService: authService,
  ));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  final bool isLoggedIn;
  final FoodRepository foodRepository;
  final UserRepository userRepository;
  final AuthService authService;
  
  const MyApp({
    required this.showOnboarding,
    required this.isLoggedIn,
    required this.foodRepository,
    required this.userRepository,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FoodLogCubit(foodRepository)..loadDailyLog(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Calorie Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // Determine initial route based on auth state
        // If not logged in, show login screen
        // If logged in, show onboarding or main screen
        home: isLoggedIn
            ? (showOnboarding 
                ? OnboardingScreen() 
                : MainScreen(
                    authService: authService,
                    userRepository: userRepository,
                  ))
            : LoginScreen(authService: authService),
        routes: {
          '/main': (context) => MainScreen(
            authService: authService,
            userRepository: userRepository,
          ),
          '/home': (context) => HomeScreen(), 
          '/onboarding': (context) => OnboardingScreen(),
          '/settings': (context) => SettingsScreen(
            authService: authService,
            userRepository: userRepository,
          ),
          // Login and register routes with dependencies
          '/login': (context) => LoginScreen(authService: authService),
          '/register': (context) => RegisterScreen(
            authService: authService,
            userRepository: userRepository,
          ),
        },
      ),
    );
  }
}