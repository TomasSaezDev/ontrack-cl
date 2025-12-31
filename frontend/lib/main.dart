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
          scaffoldBackgroundColor: const Color(0xFF000000),
          primaryColor: const Color(0xFF00BFFF), // Electric Bright Blue
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00BFFF), // Electric Bright Blue
            secondary: Color(0xFFA0A0A0),
            surface: Color(0xFF121212),
            background: Color(0xFF000000),
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
            fillColor: const Color(0xFF121212),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(color: Color(0xFF00BFFF), width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(color: const Color(0xFF00BFFF).withOpacity(0.2), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(color: Color(0xFF00BFFF), width: 1),
            ),
            hintStyle: const TextStyle(color: Color(0xFFA0A0A0)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              elevation: 0,
              shadowColor: const Color(0xFF00BFFF).withOpacity(0.4),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF00BFFF)),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF121212),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                color: const Color(0xFF00BFFF).withOpacity(0.2),
                width: 1,
              ),
            ),
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
