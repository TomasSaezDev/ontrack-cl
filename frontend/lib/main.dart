import 'package:flutter/material.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/tournaments/tournaments_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/about/about_screen.dart';
import 'screens/admin/users/users_screen.dart';
import 'screens/admin/users/user_detail_screen.dart';
import 'screens/admin/admin_stats_screen.dart';
import 'screens/admin/marcadores/marcadores_screen.dart';
import 'screens/admin/marcadores/marcador_detail_screen.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/marcador_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MarcadorProvider()),
      ],
      child: MaterialApp(
        title: 'Ontrack',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.white,
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            secondary: Colors.grey,
            surface: Colors.black,
          ),
          useMaterial3: true,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
            titleLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (context) => const WelcomeScreen());
            case '/login':
              return MaterialPageRoute(builder: (context) => const LoginScreen());
            case '/register':
              return MaterialPageRoute(builder: (context) => const RegisterScreen());
            case '/home':
              return MaterialPageRoute(builder: (context) => const HomeScreen());
            case '/leaderboard':
              return MaterialPageRoute(builder: (context) => const LeaderboardScreen());
            case '/tournaments':
              return MaterialPageRoute(builder: (context) => const TournamentsScreen());
            case '/profile':
              return MaterialPageRoute(builder: (context) => const ProfileScreen());
            case '/settings':
              return MaterialPageRoute(builder: (context) => const SettingsScreen());
            case '/about':
              return MaterialPageRoute(builder: (context) => const AboutScreen());
            case '/admin/users':
              return MaterialPageRoute(builder: (context) => const UsersScreen());
            case '/admin/marcadores':
              return MaterialPageRoute(builder: (context) => const MarcadoresScreen());
            case '/admin/stats':
              return MaterialPageRoute(builder: (context) => const AdminStatsScreen());
            case '/admin/user-detail':
              final user = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => UserDetailScreen(user: user),
              );
            case '/admin/marcador-detail':
              final user = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => MarcadorDetailScreen(user: user),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: Center(
                    child: Text('Ruta no encontrada: ${settings.name}'),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
