import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  final _storage = const FlutterSecureStorage();

  Future<List<User>> getAllUsers() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Construct URL: replace '/auth' with '/users' from AuthService.baseUrl
      // AuthService.baseUrl is like 'http://localhost:3000/api/auth'
      // We want 'http://localhost:3000/api/users'
      final baseUrl = AuthService.baseUrl.replaceAll('/auth', '/user');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming the API returns { "status": "Success", "data": [ ... ] } or just a list
        // Based on AuthService.getMarcadores, it seems to return { "status": "Success", "data": ... }

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final List<dynamic> usersJson = data['data'];
          return usersJson.map((json) => User.fromJson(json)).toList();
        } else if (data is List) {
          return data.map((json) => User.fromJson(json)).toList();
        }

        return [];
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final baseUrl = AuthService.baseUrl.replaceAll('/auth', '/user');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return User.fromJson(data['data']);
        }
        return User.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        final message = error['message'] ?? 'Error al crear usuario';
        throw Exception(message);
      }
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }
}
