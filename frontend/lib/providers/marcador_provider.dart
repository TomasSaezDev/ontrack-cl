import 'package:flutter/foundation.dart';
import '../services/marcador_time_service.dart';

class MarcadorProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _marcadores = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Map<int, DateTime> _sessionStartTimes = {};
  final Map<int, int> _sessionStartRemaining = {};

  // Getters
  List<Map<String, dynamic>> get marcadores => _marcadores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Estados de sesión activa/inactiva
  List<Map<String, dynamic>> get activePlayers {
    return _marcadores.where((marcador) {
      return marcador['isActive'] == true && 
             (marcador['timeRemaining'] ?? 0) > 0;
    }).toList();
  }

  List<Map<String, dynamic>> get inactivePlayers {
    return _marcadores.where((marcador) {
      return marcador['isActive'] != true || 
             (marcador['timeRemaining'] ?? 0) <= 0;
    }).toList();
  }

  // Obtener tiempo local para un usuario calculado en tiempo real
  int getLocalTime(int userId) {
    final marcador = _marcadores.firstWhere(
      (m) => m['userId'] == userId,
      orElse: () => {'timeRemaining': 0, 'isActive': false},
    );
    
    final isActive = marcador['isActive'] == true;
    
    // Si no está activo, devolver el tiempo guardado
    if (!isActive) {
      return marcador['timeRemaining'] ?? 0;
    }
    
    // Si está activo, calcular tiempo transcurrido
    final startTime = _sessionStartTimes[userId];
    final startRemaining = _sessionStartRemaining[userId];
    
    if (startTime == null || startRemaining == null) {
      return marcador['timeRemaining'] ?? 0;
    }
    
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    final realTime = (startRemaining - elapsed).clamp(0, startRemaining);
    
    return realTime;
  }

  // Cargar todos los marcadores
  Future<void> loadMarcadores() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔄 Iniciando carga de marcadores...');
      final marcadores = await MarcadorTimeService.getAllMarcadores();
      print('✅ Marcadores recibidos: ${marcadores.length}');
      
      _marcadores = marcadores;
      
      // Inicializar timestamps para marcadores activos
      for (var marcador in marcadores) {
        final userId = marcador['userId'];
        final isActive = marcador['isActive'] == true;
        final timeRemaining = marcador['timeRemaining'] ?? 0;
        
        if (userId != null && isActive && timeRemaining > 0) {
          _sessionStartTimes[userId] = DateTime.now();
          _sessionStartRemaining[userId] = timeRemaining;
        } else if (userId != null && !isActive) {
          // Limpiar timestamps si no está activo
          _sessionStartTimes.remove(userId);
          _sessionStartRemaining.remove(userId);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error al cargar marcadores: $e');
      String errorMsg = e.toString();
      if (errorMsg.contains('No estás autenticado')) {
        _errorMessage = 'Necesitas iniciar sesión como administrador para ver los marcadores';
      } else {
        _errorMessage = errorMsg.replaceAll('Exception: ', '');
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método de prueba de conexión
  Future<bool> testConnection() async {
    try {
      return await MarcadorTimeService.testConnection();
    } catch (e) {
      print('❌ Test de conexión falló: $e');
      return false;
    }
  }

  // Obtener marcador por usuario
  Future<Map<String, dynamic>?> getMarcadorByUser(int userId) async {
    try {
      final marcador = await MarcadorTimeService.getMarcadorByUser(userId);
      
      // Actualizar en la lista local
      final index = _marcadores.indexWhere((m) => m['userId'] == userId);
      if (index != -1) {
        _marcadores[index] = marcador;
      } else {
        _marcadores.add(marcador);
      }
      
      notifyListeners();
      return marcador;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Iniciar sesión
  Future<bool> startSession(int userId, int timeInMinutes) async {
    try {
      final updatedMarcador = await MarcadorTimeService.startSession(userId, timeInMinutes);
      
      // Actualizar en la lista local
      _updateMarcadorInList(updatedMarcador);
      
      // Inicializar timestamp
      _sessionStartTimes[userId] = DateTime.now();
      _sessionStartRemaining[userId] = updatedMarcador['timeRemaining'] ?? 0;
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Pausar/reanudar sesión
  Future<bool> toggleSession(int userId, int timeRemaining, bool isActive, int totalTime) async {
    try {
      print('\n🟢🟢🟢 [PROVIDER] ============ TOGGLE SESSION ============');
      print('🟢 [PROVIDER] userId: $userId');
      print('🟢 [PROVIDER] timeRemaining RECIBIDO del detail screen: $timeRemaining');
      print('🟢 [PROVIDER] isActive (NUEVO estado): $isActive');
      print('🟢 [PROVIDER] totalTime: $totalTime');
      print('🟢 [PROVIDER] Acción: ${isActive ? "REANUDAR" : "PAUSAR"}');
      
      // Si estamos PAUSANDO, calcular el tiempo real actual
      // Si estamos REANUDANDO, usar el tiempo recibido (que ya está calculado al pausar)
      final calculatedTime = getLocalTime(userId);
      final timeToSend = !isActive ? calculatedTime : timeRemaining;
      
      print('🟢 [PROVIDER] getLocalTime() calculado: $calculatedTime');
      print('🟢 [PROVIDER] Tiempo FINAL a enviar al backend: $timeToSend');
      print('🟢 [PROVIDER] Lógica: ${!isActive ? "PAUSANDO - usar calculado" : "REANUDANDO - usar recibido"}');
      
      final updatedMarcador = await MarcadorTimeService.toggleSession(
        userId, 
        timeToSend, 
        isActive, 
        totalTime
      );
      
      print('🟢 [PROVIDER] updatedMarcador recibido: $updatedMarcador');
      
      _updateMarcadorInList(updatedMarcador);
      
      print('🟢 [PROVIDER] Backend retornó:');
      print('🟢 [PROVIDER]   - isActive: ${updatedMarcador['isActive']}');
      print('🟢 [PROVIDER]   - timeRemaining: ${updatedMarcador['timeRemaining']}');
      print('🟢 [PROVIDER]   - totalTime: ${updatedMarcador['totalTime']}');
      
      // Manejar timestamps según el nuevo estado
      if (isActive) {
        // Reanudando - usar el tiempo que viene del backend (ya actualizado)
        _sessionStartTimes[userId] = DateTime.now();
        _sessionStartRemaining[userId] = updatedMarcador['timeRemaining'] ?? 0;
        print('🟢 [PROVIDER] ✅ REANUDADO:');
        print('🟢 [PROVIDER]   - Timestamp inicio: ${_sessionStartTimes[userId]}');
        print('🟢 [PROVIDER]   - Tiempo base: ${_sessionStartRemaining[userId]}');
      } else {
        // Pausando - limpiar timestamps y guardar el tiempo calculado en el marcador
        _sessionStartTimes.remove(userId);
        _sessionStartRemaining.remove(userId);
        print('🟢 [PROVIDER] ⏸️ PAUSADO:');
        print('🟢 [PROVIDER]   - Tiempo guardado en marcador: ${updatedMarcador['timeRemaining']}');
        print('🟢 [PROVIDER]   - Timestamps limpiados');
      }
      
      print('🟢 [PROVIDER] Marcador actualizado en lista local');
      print('🟢🟢🟢 [PROVIDER] ============ TOGGLE COMPLETADO ============\n');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ [PROVIDER] Error en toggleSession: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Agregar tiempo
  Future<bool> addTime(int userId, int additionalMinutes, int timeRemaining, bool isActive, int totalTime) async {
    try {
      final updatedMarcador = await MarcadorTimeService.addTime(
        userId,
        additionalMinutes,
        timeRemaining,
        isActive,
        totalTime
      );
      
      _updateMarcadorInList(updatedMarcador);
      
      // Si está activo, actualizar timestamp base
      if (isActive) {
        _sessionStartTimes[userId] = DateTime.now();
        _sessionStartRemaining[userId] = updatedMarcador['timeRemaining'] ?? 0;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Establecer tiempo
  Future<bool> setTime(int userId, int totalMinutes) async {
    try {
      final updatedMarcador = await MarcadorTimeService.setTime(userId, totalMinutes);
      
      _updateMarcadorInList(updatedMarcador);
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Resetear sesión
  Future<bool> resetSession(int userId, int totalTime) async {
    try {
      final updatedMarcador = await MarcadorTimeService.resetSession(userId, totalTime);
      
      _updateMarcadorInList(updatedMarcador);
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Finalizar sesión
  Future<bool> endSession(int userId, int totalTime, int timeUsed) async {
    try {
      final updatedMarcador = await MarcadorTimeService.endSession(userId, totalTime, timeUsed);
      
      _updateMarcadorInList(updatedMarcador);
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Actualizar tiempo personalizado
  Future<bool> updateTime(int userId, int timeRemaining, bool isActive, int totalTime) async {
    try {
      final updatedMarcador = await MarcadorTimeService.updateTime(
        userId,
        timeRemaining,
        isActive,
        totalTime
      );
      
      _updateMarcadorInList(updatedMarcador);
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Método auxiliar para actualizar marcador en la lista
  void _updateMarcadorInList(Map<String, dynamic> updatedMarcador) {
    final userId = updatedMarcador['userId'];
    if (userId != null) {
      final index = _marcadores.indexWhere((m) => m['userId'] == userId);
      if (index != -1) {
        _marcadores[index] = updatedMarcador;
      } else {
        _marcadores.add(updatedMarcador);
      }
    }
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Filtrar marcadores por búsqueda
  List<Map<String, dynamic>> filterMarcadores(String searchTerm) {
    if (searchTerm.isEmpty) {
      return _marcadores;
    }
    
    return _marcadores.where((marcador) {
      final name = marcador['user']?['name']?.toString().toLowerCase() ?? '';
      final email = marcador['user']?['email']?.toString().toLowerCase() ?? '';
      final search = searchTerm.toLowerCase();
      
      return name.contains(search) || email.contains(search);
    }).toList();
  }
}