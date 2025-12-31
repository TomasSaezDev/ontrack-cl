import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../widgets/main_layout.dart';
import '../../../widgets/search_widget.dart';
import '../../../providers/marcador_provider.dart';

class MarcadoresScreen extends StatefulWidget {
  const MarcadoresScreen({super.key});

  @override
  State<MarcadoresScreen> createState() => _MarcadoresScreenState();
}

class _MarcadoresScreenState extends State<MarcadoresScreen> {
  Timer? _timer;
  Timer? _syncTimer;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadMarcadores();
    _startTimers();
  }

  void _checkAuthAndLoadMarcadores() async {
    // Verificar si hay token de autenticación
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    
    if (token == null && mounted) {
      // No hay token, mostrar mensaje y permitir navegación manual al login
      print('⚠️ No hay token de autenticación');
      _loadMarcadores(); // Intentar cargar de todas formas para mostrar el error
      return;
    }
    
    _loadMarcadores();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }

  void _loadMarcadores() {
    final marcadorProvider = Provider.of<MarcadorProvider>(context, listen: false);
    marcadorProvider.loadMarcadores();
  }

  void _startTimers() {
    // Timer para actualizar UI cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final marcadorProvider = Provider.of<MarcadorProvider>(context, listen: false);
      marcadorProvider.notifyListeners();
    });
    
    // Timer para sincronizar con backend cada 10 segundos
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final marcadorProvider = Provider.of<MarcadorProvider>(context, listen: false);
      marcadorProvider.loadMarcadores();
    });
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
    return Consumer<MarcadorProvider>(
      builder: (context, marcadorProvider, child) {
        return MainLayout(
          title: 'Gestión de Marcadores',
          body: RefreshIndicator(
            onRefresh: () => marcadorProvider.loadMarcadores(),
            child: Column(
              children: [
                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SearchWidget(
                    hintText: 'Buscar por nombre o email...',
                    onChanged: (value) {
                      setState(() {
                        _searchTerm = value;
                      });
                    },
                  ),
                ),
                
                // Mensaje de error
                if (marcadorProvider.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                marcadorProvider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => marcadorProvider.clearError(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  print('🔍 Probando conexión al backend...');
                                  final isConnected = await marcadorProvider.testConnection();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isConnected 
                                            ? '✅ Conexión exitosa' 
                                            : '❌ Error de conexión',
                                        ),
                                        backgroundColor: isConnected ? Colors.green : Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.wifi_find),
                                label: const Text('Probar Conexión'),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.login),
                                label: const Text('Ir a Login'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Indicador de carga
                if (marcadorProvider.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else
                  Expanded(
                    child: _buildMarcadoresList(marcadorProvider),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarcadoresList(MarcadorProvider marcadorProvider) {
    final filteredMarcadores = marcadorProvider.filterMarcadores(_searchTerm);
    
    if (filteredMarcadores.isEmpty) {
      // Verificar si el error es de autenticación
      final isAuthError = marcadorProvider.errorMessage?.contains('autenticado') == true ||
                         marcadorProvider.errorMessage?.contains('administrador') == true;
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAuthError ? Icons.login : Icons.hourglass_empty,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16.0),
            Text(
              isAuthError 
                ? 'Necesitas iniciar sesión'
                : 'No hay marcadores disponibles',
              style: const TextStyle(
                color: Colors.grey, 
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              isAuthError
                ? 'Inicia sesión como administrador para gestionar marcadores'
                : 'Los marcadores aparecerán aquí una vez creados',
              style: const TextStyle(
                color: Colors.grey, 
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (isAuthError) ...[
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                ),
                icon: const Icon(Icons.login),
                label: const Text('Iniciar Sesión'),
              ),
            ],
          ],
        ),
      );
    }

    // Separar jugadores activos e inactivos
    final activePlayers = filteredMarcadores.where((marcador) {
      return marcador['isActive'] == true && 
             (marcadorProvider.getLocalTime(marcador['userId']) > 0);
    }).toList();

    final inactivePlayers = filteredMarcadores.where((marcador) {
      return marcador['isActive'] != true || 
             (marcadorProvider.getLocalTime(marcador['userId']) <= 0);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Sección de jugadores activos
        if (activePlayers.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.green[900],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.play_circle, color: Colors.green),
                const SizedBox(width: 8.0),
                Text(
                  'Jugadores Activos (${activePlayers.length})',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          ...activePlayers.map((marcador) => _buildMarcadorCard(marcador, marcadorProvider, true)),
          const SizedBox(height: 24.0),
        ],
        
        // Sección de jugadores inactivos
        if (inactivePlayers.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.pause_circle, color: Colors.grey),
                const SizedBox(width: 8.0),
                Text(
                  'Jugadores Inactivos (${inactivePlayers.length})',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          ...inactivePlayers.map((marcador) => _buildMarcadorCard(marcador, marcadorProvider, false)),
        ],
      ],
    );
  }

  Widget _buildMarcadorCard(Map<String, dynamic> marcador, MarcadorProvider marcadorProvider, bool isActive) {
    final user = marcador['user'] ?? {};
    final userId = marcador['userId'];
    final timeRemaining = marcadorProvider.getLocalTime(userId);
    final totalTime = marcador['totalTime'] ?? 0;
    
    final progress = totalTime > 0 ? (totalTime - timeRemaining) / totalTime : 0.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.grey[900],
      elevation: 4.0,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/admin/marcador-detail',
            arguments: {
              ...marcador,
              'timeRemaining': timeRemaining,
            },
          );
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del usuario
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isActive ? Colors.green : Colors.grey,
                    child: Icon(
                      isActive ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['nombreCompleto'] ?? 'Usuario desconocido',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user['email'] ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ],
              ),
            
            const SizedBox(height: 16.0),
            
            // Barra de progreso
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[700],
              valueColor: AlwaysStoppedAnimation<Color>(
                isActive ? Colors.green : Colors.grey,
              ),
            ),
            
            const SizedBox(height: 8.0),
            
            // Información de tiempo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tiempo restante: ${_formatTime(timeRemaining)}',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Total: ${_formatTime(totalTime)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            // Estado actual
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: isActive ? Colors.green[800] : Colors.grey[700],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                isActive ? 'ACTIVO' : 'INACTIVO',
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}