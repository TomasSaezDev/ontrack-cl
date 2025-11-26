import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user_model.dart';
import '../models/marcador_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Android emulator uses 10.0.2.2 to access host localhost
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/auth';
    }
    return 'http://localhost:3000/api/auth';
  }

  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['data']['token'];
        await _storage.write(key: 'jwt_token', value: token);

        // Decode token to get user info
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

        return {
          'success': true,
          'user': User.fromJson(decodedToken),
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al iniciar sesión',
          'details': data['details'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> register(
    String nombreCompleto,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombreCompleto': nombreCompleto,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al registrar usuario',
          'details': data['details'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<User?> getCurrentUser() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return User.fromJson(decodedToken);
    }
    return null;
  }



  // Obtener todos los marcadores
  Future<List<dynamic>> getMarcadores() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return [];

    try {
      final userUrl = baseUrl.replaceAll('/auth', '/user');

      final response = await http.get(
        Uri.parse('$userUrl/marcadores'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'Success') {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obtener un marcador por ID de usuario
  Future<Marcador?> getMarcador(int userId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      print('DEBUG: Token is null');
      return null;
    }

    try {
      final userUrl = baseUrl.replaceAll('/auth', '/user');
      final requestUrl = '$userUrl/detail/marcador?id=$userId';
      print('DEBUG: Requesting URL: $requestUrl');

      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'Success') {
          return Marcador.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('DEBUG: Error in getMarcador: $e');
      return null;
    }
  }
}
