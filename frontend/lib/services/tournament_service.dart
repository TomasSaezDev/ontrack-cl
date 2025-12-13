import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/tournament_model.dart';
import 'auth_service.dart';

class TournamentService {
  final _storage = const FlutterSecureStorage();

  Future<List<Tournament>> getTournaments() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return [];

      final baseUrl = AuthService.baseUrl.replaceAll('/auth', '/torneos');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'Success') {
          final List<dynamic> tournamentsJson = data['data'];
          return tournamentsJson
              .map((json) => Tournament.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching tournaments: $e');
      return [];
    }
  }

  Future<bool> createTournament(
    String nombre,
    String descripcion,
    int premio,
  ) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;

      final baseUrl = AuthService.baseUrl.replaceAll('/auth', '/torneos');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre': nombre,
          'descripcion': descripcion,
          'fechaInicio': DateTime.now()
              .toIso8601String(), // Default to now for simplicity
          'premio': premio,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating tournament: $e');
      return false;
    }
  }

  Future<bool> registerUser(int tournamentId, int userId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;

      final baseUrl = AuthService.baseUrl.replaceAll(
        '/auth',
        '/torneos/$tournamentId/inscribir',
      );

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTournamentDetails(int id) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return null;

      final baseUrl = AuthService.baseUrl.replaceAll('/auth', '/torneos/$id');

      final response = await http.get(
        Uri.parse(baseUrl),
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
      return null;
    } catch (e) {
      print('Error fetching tournament details: $e');
      return null;
    }
  }
}
