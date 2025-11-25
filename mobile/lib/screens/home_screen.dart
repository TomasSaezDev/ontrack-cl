import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/marcador_model.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  Marcador? _userMarcador;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserMarcador();
    });
  }

  Future<void> _loadUserMarcador() async {
    print('DEBUG: _loadUserMarcador started');
    final User? user = ModalRoute.of(context)!.settings.arguments as User?;
    if (user != null) {
      print('DEBUG: User found: ${user.id}');
      try {
        final marcador = await _authService.getMarcador(user.id);
        print('DEBUG: getMarcador returned: $marcador');
        if (mounted) {
          setState(() {
            _userMarcador = marcador;
            _isLoading = false;
          });
          print('DEBUG: State updated with marcador');
        }
      } catch (e) {
        print('DEBUG: Error in _loadUserMarcador: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      print('DEBUG: User is null');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = ModalRoute.of(context)!.settings.arguments as User?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SimRacing Center'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Info Card
              if (user != null)
                Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.nombreCompleto,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              const Text(
                'Mi Rendimiento',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // User Stats Grid
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _userMarcador != null
                  ? GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildStatCard(
                          'Puntos',
                          _userMarcador!.puntos.toString(),
                          Icons.emoji_events,
                          Colors.amber,
                        ),
                        _buildStatCard(
                          'Horas',
                          '${_userMarcador!.horas}h',
                          Icons.timer,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Visitas',
                          _userMarcador!.visitas.toString(),
                          Icons.directions_car,
                          Colors.green,
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'No se encontraron datos de marcador.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

              const SizedBox(height: 48),

              // View Leaderboard Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/leaderboard');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.leaderboard),
                    SizedBox(width: 8),
                    Text(
                      'Ver Ranking Global',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}
