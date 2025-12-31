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
          showBottomNav: true,
          currentIndex: 0,
          body: RefreshIndicator(
            onRefresh: () async {
              await authProvider.fetchMarcador();
              if (user?.rol == 'administrador') {
                await marcadorProvider.loadMarcadores();
              }
            },
            color: const Color(0xFF00BFFF),
            child: Stack(
              children: [
                // Background effects
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00BFFF).withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00BFFF).withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Content
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Saludo personalizado con nuevo diseño
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: const Color(0xFF00BFFF).withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00BFFF).withOpacity(0.15),
                              blurRadius: 15,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Decorative gradient circle
                            Positioned(
                              top: -20,
                              right: -20,
                              child: Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF00BFFF).withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bienvenido de nuevo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFFA0A0A0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '¡Hola,\n${user?.nombreCompleto ?? 'Usuario'}!',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Bienvenido a On-Track',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: const Color(0xFFA0A0A0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Sección: Tu Marcador
                      if (user?.rol != 'administrador' && marcadorAux != null) ...[
                        Row(
                          children: [
                            const Text(
                              'Tu Marcador',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        _buildPersonalMarcadorCard(marcadorAux),
                        const SizedBox(height: 24.0),
                      ],

                      // Panel de administrador
                      if (user?.rol == 'administrador') ...[
                        _buildAdminSection(marcadorProvider),
                        const SizedBox(height: 24.0),
                      ],

                      // Estadísticas
                      Row(
                        children: [
                          const Text(
                            'Estadísticas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      _buildStatsSection(marcadorProvider, user),
                      
                      const SizedBox(height: 24.0),
                      
                      // Quick Actions
                      _buildQuickActions(),
                      
                      const SizedBox(height: 80.0), // Padding for bottom nav
                    ],
                  ),
                ),
              ],
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
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFF00BFFF).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BFFF).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  marcador?.estaActivo == true ? Icons.play_arrow : Icons.pause,
                  color: const Color(0xFFA0A0A0),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marcador?.estaActivo == true ? 'Sesión Activa' : 'Sesión Inactiva',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tiempo restante: ${_formatTime(marcador?.tiempoRestante ?? 0)}',
                      style: const TextStyle(
                        color: Color(0xFFA0A0A0),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16.0),
          
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8.0),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Usado: ${_formatTime((marcador?.tiempoTotal ?? 0) - (marcador?.tiempoRestante ?? 0))}',
                style: const TextStyle(
                  color: Color(0xFFA0A0A0), 
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Total: ${_formatTime(marcador?.tiempoTotal ?? 0)}',
                style: const TextStyle(
                  color: Color(0xFFA0A0A0), 
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
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
            Icons.play_arrow,
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: _buildStatCard(
            'Total Corredores',
            '${marcadorProvider.marcadores.length}',
            Icons.groups,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFF00BFFF).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BFFF).withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00BFFF).withOpacity(0.1),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF00BFFF)),
          ),
          const SizedBox(height: 12.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFA0A0A0),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFF00BFFF).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BFFF).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildQuickActionItem(
            icon: Icons.leaderboard,
            title: 'Ranking Global',
            onTap: () => Navigator.pushNamed(context, '/leaderboard'),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white.withOpacity(0.05),
          ),
          _buildQuickActionItem(
            icon: Icons.emoji_events,
            title: 'Torneos',
            onTap: () => Navigator.pushNamed(context, '/tournaments'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon, 
                color: const Color(0xFFA0A0A0),
                size: 24,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFFA0A0A0),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}