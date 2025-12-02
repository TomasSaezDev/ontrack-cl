import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marcador_provider.dart';
import '../../widgets/main_layout.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      authProvider.fetchMarcador();
      
      final user = authProvider.user;
      if (user?.rol == 'administrador') {
        _loadMarcadores();
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadMarcadores() {
    final marcadorProvider = context.read<MarcadorProvider>();
    marcadorProvider.loadMarcadores();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final marcadorProvider = context.read<MarcadorProvider>();
      
      // Decrementar tiempo local para corredores activos
      for (var player in marcadorProvider.activePlayers) {
        final userId = player['userId'];
        if (userId != null) {
          marcadorProvider.decrementLocalTime(userId);
        }
      }
    });
  }

  void _navigateToMarcadorDetail(Map<String, dynamic> marcador) {
    Navigator.pushNamed(
      context,
      '/admin/marcador-detail',
      arguments: marcador,
    );
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, MarcadorProvider>(
      builder: (context, authProvider, marcadorProvider, child) {
        final user = authProvider.user;
        final marcadorAux = authProvider.marcador;

        return MainLayout(
          title: 'Inicio',
          body: RefreshIndicator(
            onRefresh: () async {
              await authProvider.fetchMarcador();
              if (user?.rol == 'administrador') {
                await marcadorProvider.loadMarcadores();
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo personalizado
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey[850]!, Colors.grey[900]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, ${user?.nombreCompleto ?? 'Usuario'}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Bienvenido a On-Track',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[300],
                          ),
                        ),
                        if (user?.rol == 'administrador') ...[
                          const SizedBox(height: 12.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: Colors.blue[700],
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: const Text(
                              'ADMINISTRADOR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // Información personal del marcador (para usuarios regulares)
                  if (user?.rol != 'administrador' && marcadorAux != null) ...[
                    const Text(
                      'Tu Marcador',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _buildPersonalMarcadorCard(marcadorAux),
                    const SizedBox(height: 24.0),
                  ],

                  // Panel de administrador (solo para administradores)
                  if (user?.rol == 'administrador') ...[
                    _buildAdminSection(marcadorProvider),
                    const SizedBox(height: 24.0),
                  ],

                  // Estadísticas generales
                  const Text(
                    'Estadísticas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildStatsSection(marcadorProvider, user),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonalMarcadorCard(dynamic marcador) {
    final progress = marcador?.tiempoTotal != null && marcador.tiempoTotal > 0 
        ? (marcador.tiempoTotal - marcador.tiempoRestante) / marcador.tiempoTotal 
        : 0.0;
    
    return Card(
      color: Colors.grey[900],
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: marcador?.estaActivo == true ? Colors.green : Colors.grey,
                  child: Icon(
                    marcador?.estaActivo == true ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marcador?.estaActivo == true ? 'Sesión Activa' : 'Sesión Inactiva',
                        style: TextStyle(
                          color: marcador?.estaActivo == true ? Colors.green : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tiempo restante: ${_formatTime(marcador?.tiempoRestante ?? 0)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16.0),
            
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[700],
              valueColor: AlwaysStoppedAnimation<Color>(
                marcador?.estaActivo == true ? Colors.green : Colors.grey,
              ),
            ),
            
            const SizedBox(height: 8.0),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Usado: ${_formatTime((marcador?.tiempoTotal ?? 0) - (marcador?.tiempoRestante ?? 0))}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Total: ${_formatTime(marcador?.tiempoTotal ?? 0)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSection(MarcadorProvider marcadorProvider) {
    final activePlayers = marcadorProvider.activePlayers;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Corredores Activos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                '${activePlayers.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        
        if (marcadorProvider.isLoading)
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          )
        else if (marcadorProvider.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.red[900],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    marcadorProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          )
        else if (activePlayers.isEmpty)
          Card(
            color: Colors.grey[900],
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No hay corredores activos',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          )
        else
          ...activePlayers.take(3).map((marcador) => _buildActivePlayerCard(marcador, marcadorProvider)),
        
        const SizedBox(height: 16.0),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/admin/marcadores'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
            icon: const Icon(Icons.dashboard),
            label: const Text('Ver Todos los Marcadores'),
          ),
        ),
      ],
    );
  }

  Widget _buildActivePlayerCard(Map<String, dynamic> marcador, MarcadorProvider marcadorProvider) {
    final user = marcador['user'] ?? {};
    final userId = marcador['userId'];
    final timeRemaining = marcadorProvider.getLocalTime(userId);
    final totalTime = marcador['totalTime'] ?? 0;
    final progress = totalTime > 0 ? (totalTime - timeRemaining) / totalTime : 0.0;
    
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: const Icon(Icons.play_arrow, color: Colors.white),
        ),
        title: Text(
          user['nombreCompleto'] ?? 'Usuario desconocido',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiempo restante: ${_formatTime(timeRemaining)}',
              style: const TextStyle(color: Colors.green),
            ),
            const SizedBox(height: 4.0),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[700],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          onPressed: () => _navigateToMarcadorDetail({
            ...marcador,
            'timeRemaining': timeRemaining,
          }),
        ),
        onTap: () => _navigateToMarcadorDetail({
          ...marcador,
          'timeRemaining': timeRemaining,
        }),
      ),
    );
  }

  Widget _buildStatsSection(MarcadorProvider marcadorProvider, dynamic user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Corredores Activos',
            '${marcadorProvider.activePlayers.length}',
            Icons.play_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _buildStatCard(
            'Total Corredores',
            '${marcadorProvider.marcadores.length}',
            Icons.people,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}