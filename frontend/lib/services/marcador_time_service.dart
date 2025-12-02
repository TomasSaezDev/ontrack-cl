import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MarcadorTimeService {
  // Configuración automática de URL según la plataforma
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter web usa localhost
      return 'http://localhost:3000/api/marcadores';
    } else if (Platform.isAndroid) {
      // Emulador Android usa 10.0.2.2
      return 'http://10.0.2.2:3000/api/marcadores';
    } else if (Platform.isIOS) {
      // Simulador iOS usa localhost
      return 'http://localhost:3000/api/marcadores';
    } else {
      // Desktop (Windows, macOS, Linux) usa localhost
      return 'http://localhost:3000/api/marcadores';
    }
  }
  
  static const storage = FlutterSecureStorage();

  // Método de prueba de conexión
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse('${baseUrl.replaceAll('/marcadores', '/marcadores/test')}');
      print('🔍 Probando conexión a: $url');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout: El servidor no responde'),
      );

      print('📊 Estado de prueba: ${response.statusCode}');
      print('📄 Respuesta de prueba: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error en test de conexión: $e');
      return false;
    }
  }

  // Obtener headers con autenticación
  static Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'jwt_token');
    
    print('🔑 Token recuperado: ${token != null ? "Sí (${token.length} chars)" : "No"}');
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    print('🔑 Headers finales: $headers');
    return headers;
  }

  // Obtener todos los marcadores
  static Future<List<Map<String, dynamic>>> getAllMarcadores() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(baseUrl);
      
      print('📡 Conectando a: $url');
      print('🔑 Headers: $headers');
      
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout: El servidor no responde'),
      );

      print('📊 Estado de respuesta: ${response.statusCode}');
      print('📄 Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else if (response.statusCode == 401) {
        throw Exception('No estás autenticado. Por favor, inicia sesión como administrador.');
      } else {
        throw Exception('Error del servidor: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error en getAllMarcadores: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        throw Exception('No se puede conectar al servidor. Verifica que el backend esté ejecutándose.');
      }
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener marcador por usuario
  static Future<Map<String, dynamic>> getMarcadorByUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Error al obtener marcador: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Iniciar sesión de juego
  static Future<Map<String, dynamic>> startSession(int userId, int timeInMinutes) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/user/$userId/start'),
        headers: headers,
        body: json.encode({
          'timeInMinutes': timeInMinutes,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Pausar/reanudar sesión
  static Future<Map<String, dynamic>> toggleSession(
    int userId,
    int timeRemaining,
    bool isActive,
    int totalTime,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/user/$userId/toggle'),
        headers: headers,
        body: json.encode({
          'timeRemaining': timeRemaining,
          'isActive': isActive,
          'totalTime': totalTime,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al pausar/reanudar');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Agregar tiempo a la sesión
  static Future<Map<String, dynamic>> addTime(
    int userId,
    int additionalMinutes,
    int timeRemaining,
    bool isActive,
    int totalTime,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/user/$userId/add-time'),
        headers: headers,
        body: json.encode({
          'additionalMinutes': additionalMinutes,
          'timeRemaining': timeRemaining,
          'isActive': isActive,
          'totalTime': totalTime,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al agregar tiempo');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Establecer tiempo total
  static Future<Map<String, dynamic>> setTime(int userId, int totalMinutes) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/user/$userId/set-time'),
        headers: headers,
        body: json.encode({
          'totalMinutes': totalMinutes,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al establecer tiempo');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Resetear sesión
  static Future<Map<String, dynamic>> resetSession(int userId, int totalTime) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/user/$userId/reset'),
        headers: headers,
        body: json.encode({
          'totalTime': totalTime,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al resetear sesión');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Finalizar sesión
  static Future<Map<String, dynamic>> endSession(
    int userId,
    int totalTime,
    int timeUsed,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/user/$userId/end'),
        headers: headers,
        body: json.encode({
          'totalTime': totalTime,
          'timeUsed': timeUsed,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al finalizar sesión');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar tiempo personalizado
  static Future<Map<String, dynamic>> updateTime(
    int userId,
    int timeRemaining,
    bool isActive,
    int totalTime,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/user/$userId/update'),
        headers: headers,
        body: json.encode({
          'timeRemaining': timeRemaining,
          'isActive': isActive,
          'totalTime': totalTime,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        final Map<String, dynamic> error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al actualizar tiempo');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}