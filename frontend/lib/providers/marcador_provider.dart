import 'package:flutter/foundation.dart';
import '../services/marcador_time_service.dart';

class MarcadorProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _marcadores = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Map<int, int> _localTimers = {};

  // Getters
  List<Map<String, dynamic>> get marcadores => _marcadores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<int, int> get localTimers => _localTimers;

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

  // Obtener tiempo local para un usuario
  int getLocalTime(int userId) {
    return _localTimers[userId] ?? 0;
  }

  // Actualizar tiempo local
  void updateLocalTime(int userId, int timeRemaining) {
    _localTimers[userId] = timeRemaining;
    notifyListeners();
  }

  // Decrementar tiempo local
  void decrementLocalTime(int userId) {
    if (_localTimers[userId] != null && _localTimers[userId]! > 0) {
      _localTimers[userId] = _localTimers[userId]! - 1;
      notifyListeners();
    }
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

      // Sincronizar timers locales con datos del servidor
      for (var marcador in marcadores) {
        final userId = marcador['userId'];
        final timeRemaining = marcador['timeRemaining'] ?? 0;
        if (userId != null) {
          _localTimers[userId] = timeRemaining;
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
      
      // Actualizar timer local
      _localTimers[userId] = marcador['timeRemaining'] ?? 0;
      
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
      
      // Actualizar timer local
      _localTimers[userId] = updatedMarcador['timeRemaining'] ?? 0;
      
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
      print('🟢 [PROVIDER] toggleSession llamado');
      print('🟢 [PROVIDER] userId: $userId');
      print('🟢 [PROVIDER] timeRemaining: $timeRemaining');
      print('🟢 [PROVIDER] isActive: $isActive');
      print('🟢 [PROVIDER] totalTime: $totalTime');
      
      final updatedMarcador = await MarcadorTimeService.toggleSession(
        userId, 
        timeRemaining, 
        isActive, 
        totalTime
      );
      
      print('🟢 [PROVIDER] updatedMarcador recibido: $updatedMarcador');
      
      _updateMarcadorInList(updatedMarcador);
      _localTimers[userId] = updatedMarcador['timeRemaining'] ?? 0;
      
      print('🟢 [PROVIDER] Marcador actualizado en lista y timer local');
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
      _localTimers[userId] = updatedMarcador['timeRemaining'] ?? 0;
      
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
      _localTimers[userId] = updatedMarcador['timeRemaining'] ?? 0;
      
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
      _localTimers[userId] = updatedMarcador['timeRemaining'] ?? 0;
      
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
      _localTimers[userId] = updatedMarcador['timeRemaining'] ?? 0;
      
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
      _localTimers[userId] = updatedMarcador['timeRemaining'] ?? 0;
      
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