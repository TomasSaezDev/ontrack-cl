import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/marcador_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _user != null;

  AuthProvider({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepositoryImpl();

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authRepository.getCurrentUser();
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String nombreCompleto,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(nombreCompleto, email, password);
      // Opcional: Auto-login después de registro o pedir login
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    notifyListeners();
  }

  // Marker Logic
  dynamic _marcador;
  dynamic get marcador => _marcador;

  Future<void> fetchMarcador() async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _marcador = await _authRepository.getMarcador(_user!.id);
    } catch (e) {
      print('Error fetching marcador: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Leaderboard Logic
  List<Marcador> _leaderboard = [];
  List<Marcador> get leaderboard => _leaderboard;

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _authRepository.getMarcadores();
      _leaderboard = data.map((json) => Marcador.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching leaderboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
